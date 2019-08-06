// ---------- AWS VPN Connection setup ----------

data "aws_vpc" "selected" {
  id = var.aws-vpc-id
}

data "aws_subnet_ids" "all" {
  vpc_id = var.aws-vpc-id
}

data "aws_subnet" "subnets" {
  count = length(data.aws_subnet_ids.all.ids)
  id    = tolist(data.aws_subnet_ids.all.ids)[count.index]
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.aws-vpc-id]
  }
}

resource "aws_vpn_gateway" "aws-vpn-gw" {
  vpc_id = var.aws-vpc-id
}

resource "aws_customer_gateway" "aws-cgw" {
  bgp_asn    = 65000
  ip_address = google_compute_address.gcp-vpn-ip.address
  type       = "ipsec.1"

  tags = {
    "Name" = "aws-customer-gw"
  }
}

resource "aws_vpn_gateway_route_propagation" "example" {
  vpn_gateway_id = aws_vpn_gateway.aws-vpn-gw.id
  route_table_id = data.aws_vpc.selected.main_route_table_id
}


resource "aws_vpn_connection" "aws-vpn-connection1" {
  vpn_gateway_id      = aws_vpn_gateway.aws-vpn-gw.id
  customer_gateway_id = aws_customer_gateway.aws-cgw.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    "Name" = "aws-vpn-connection1"
  }
}

# Allow traffic from the VPN subnets.
resource "aws_security_group" "aws-allow-vpn" {
  name        = "aws-allow-vpn"
  description = "Allow all traffic from vpn resources"
  vpc_id      = var.aws-vpc-id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.google_compute_subnetwork.gcp-subnetwork.ip_cidr_range]
  }
}

// ----------GCP VPN Connection setup----------

data "google_compute_network" "my-network" {
  name = var.gcp-network-name
}

data "google_compute_subnetwork" "gcp-subnetwork" {
  name   = var.gcp-subnet1-name
  region = var.gcp_region
}

resource "google_compute_address" "gcp-vpn-ip" {
  name   = "gcp-vpn-ip"
  region = var.gcp_region
}

resource "google_compute_vpn_gateway" "gcp-vpn-gw" {
  name    = "gcp-vpn-gw-${var.gcp_region}"
  network = var.gcp-network-name
  region  = var.gcp_region
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.gcp-vpn-ip.address
  target      = google_compute_vpn_gateway.gcp-vpn-gw.self_link
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500-500"
  ip_address  = google_compute_address.gcp-vpn-ip.address
  target      = google_compute_vpn_gateway.gcp-vpn-gw.self_link
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500-4500"
  ip_address  = google_compute_address.gcp-vpn-ip.address
  target      = google_compute_vpn_gateway.gcp-vpn-gw.self_link
}

/*
 * ----------VPN Tunnel1----------
 */

resource "google_compute_vpn_tunnel" "gcp-tunnel1" {
  name          = "gcp-tunnel1"
  peer_ip       = aws_vpn_connection.aws-vpn-connection1.tunnel1_address
  shared_secret = aws_vpn_connection.aws-vpn-connection1.tunnel1_preshared_key
  ike_version   = 1

  target_vpn_gateway = google_compute_vpn_gateway.gcp-vpn-gw.self_link

  router = google_compute_router.gcp-router1.name

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_router" "gcp-router1" {
  name    = "gcp-router1"
  region  = var.gcp_region
  network = var.gcp-network-name

  bgp {
    asn = aws_customer_gateway.aws-cgw.bgp_asn
  }
}

resource "google_compute_router_peer" "gcp-router1-peer" {
  name            = "gcp-to-aws-bgp1"
  router          = google_compute_router.gcp-router1.name
  region          = google_compute_router.gcp-router1.region
  peer_ip_address = aws_vpn_connection.aws-vpn-connection1.tunnel1_vgw_inside_address
  peer_asn        = var.GCP_TUN1_VPN_GW_ASN
  interface       = google_compute_router_interface.router_interface1.name
}

resource "google_compute_router_interface" "router_interface1" {
  name       = "gcp-to-aws-interface1"
  router     = google_compute_router.gcp-router1.name
  region     = google_compute_router.gcp-router1.region
  ip_range   = "${aws_vpn_connection.aws-vpn-connection1.tunnel1_cgw_inside_address}/${var.GCP_TUN1_CUSTOMER_GW_INSIDE_NETWORK_CIDR}"
  vpn_tunnel = google_compute_vpn_tunnel.gcp-tunnel1.name
}

/*
 * ----------VPN Tunnel2----------
 */

resource "google_compute_vpn_tunnel" "gcp-tunnel2" {
  name          = "gcp-tunnel2"
  peer_ip       = aws_vpn_connection.aws-vpn-connection1.tunnel2_address
  shared_secret = aws_vpn_connection.aws-vpn-connection1.tunnel2_preshared_key
  ike_version   = 1

  target_vpn_gateway = google_compute_vpn_gateway.gcp-vpn-gw.self_link

  router = google_compute_router.gcp-router2.name

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_router" "gcp-router2" {
  name    = "gcp-router2"
  region  = var.gcp_region
  network = var.gcp-network-name

  bgp {
    asn = aws_customer_gateway.aws-cgw.bgp_asn
  }
}

resource "google_compute_router_peer" "gcp-router2-peer" {
  name            = "gcp-to-aws-bgp2"
  router          = google_compute_router.gcp-router2.name
  region          = google_compute_router.gcp-router2.region
  peer_ip_address = aws_vpn_connection.aws-vpn-connection1.tunnel2_vgw_inside_address
  peer_asn        = var.GCP_TUN2_VPN_GW_ASN
  interface       = google_compute_router_interface.router_interface2.name
}

resource "google_compute_router_interface" "router_interface2" {
  name       = "gcp-to-aws-interface2"
  router     = google_compute_router.gcp-router2.name
  region     = google_compute_router.gcp-router2.region
  ip_range   = "${aws_vpn_connection.aws-vpn-connection1.tunnel2_cgw_inside_address}/${var.GCP_TUN2_CUSTOMER_GW_INSIDE_NETWORK_CIDR}"
  vpn_tunnel = google_compute_vpn_tunnel.gcp-tunnel2.name
}

# Allow traffic from the VPN subnets.
resource "google_compute_firewall" "gcp-allow-vpn" {
  name    = "${var.gcp-network-name}-gcp-allow-vpn"
  network = var.gcp-network-name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = data.aws_subnet.subnets.*.cidr_block
}

