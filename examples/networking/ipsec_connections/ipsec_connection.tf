// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

resource oci_core_cpe "test_cpe" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "test_cpe"
  ip_address     = "189.44.2.135"
}

resource oci_core_drg "test_drg" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "test_drg"
}

resource "oci_core_ipsec" "test_ip_sec_connection" {
  #Required
  compartment_id = "${var.compartment_ocid}"
  cpe_id         = "${oci_core_cpe.test_cpe.id}"
  drg_id         = "${oci_core_drg.test_drg.id}"
  static_routes  = ["10.0.0.0/16"]

  #Optional
  cpe_local_identifier      = "189.44.2.135"
  cpe_local_identifier_type = "IP_ADDRESS"
  defined_tags              = "${map("${oci_identity_tag_namespace.tag_namespace1.name}.${oci_identity_tag.tag1.name}", "value")}"
  display_name              = "MyIPSecConnection"

  freeform_tags = {
    "Department" = "Finance"
  }
}

data "oci_core_ipsec_connections" "test_ip_sec_connections" {
  #Required
  compartment_id = "${var.compartment_ocid}"

  #Optional
  cpe_id = "${oci_core_cpe.test_cpe.id}"
  drg_id = "${oci_core_drg.test_drg.id}"
}

data "oci_core_ipsec_connection_tunnels" "test_ip_sec_connection_tunnels" {
  ipsec_id = "${oci_core_ipsec.test_ip_sec_connection.id}"
}

data "oci_core_ipsec_connection_tunnel" "test_ipsec_connection_tunnel" {
  ipsec_id  = "${oci_core_ipsec.test_ip_sec_connection.id}"
  tunnel_id = "${data.oci_core_ipsec_connection_tunnels.test_ip_sec_connection_tunnels.ip_sec_connection_tunnels.0.id}"
}

resource "oci_core_ipsec_connection_tunnel_management" "test_ipsec_connection_tunnel_management" {
  ipsec_id  = "${oci_core_ipsec.test_ip_sec_connection.id}"
  tunnel_id = "${data.oci_core_ipsec_connection_tunnels.test_ip_sec_connection_tunnels.ip_sec_connection_tunnels.0.id}"

  #Optional
  bgp_session_info {
    customer_bgp_asn      = "1587232876"
    customer_interface_ip = "10.0.0.16/31"
    oracle_interface_ip   = "10.0.0.17/31"
  }

  display_name  = "MyIPSecConnection"
  routing       = "BGP"
  shared_secret = "sharedSecret"
}

resource "oci_identity_tag_namespace" "tag_namespace1" {
  #Required
  compartment_id = "${var.tenancy_ocid}"
  description    = "Just a test"
  name           = "testexamples-tag-namespace"
}

resource "oci_identity_tag" "tag1" {
  #Required
  description      = "tf example tag"
  name             = "tf-example-tag"
  tag_namespace_id = "${oci_identity_tag_namespace.tag_namespace1.id}"
}

resource "oci_identity_tag" "tag2" {
  #Required
  description      = "tf example tag 2"
  name             = "tf-example-tag-2"
  tag_namespace_id = "${oci_identity_tag_namespace.tag_namespace1.id}"
}
