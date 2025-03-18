# Firezone Terraform modules and examples

This repo contains Terraform modules to use for Firezone deployments on Google
Cloud Platform.

## Examples

- [NAT Gateway](./google-cloud/nat-gateway): This example shows how to deploy
  one or more Firezone Gateways in a single GCP VPC that is configured with a
  Cloud NAT for egress. Read this if you're looking to deploy Firezone Gateways
  behind a single, shared static IP address on GCP.
