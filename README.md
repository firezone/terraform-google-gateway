# Firezone Terraform modules and examples

This repo contains Terraform modules to use for Firezone deployments on various
cloud providers.

## Table of contents:

- [examples/aws/nat-gateway](examples/aws/nat-gateway): Example Terraform
  configuration for deploying a cluster of Firezone Gateways behind a NAT
  gateway on AWS with a single egress IP.
- [examples/google-cloud/nat-gateway](examples/google-cloud/nat-gateway):
  Example Terraform configuration for deploying a cluster of Firezone Gateways
  behind a NAT gateway on GCP with a single egress IP.
- [examples/azure/nat-gateway](examples/azure/nat-gateway): Example Terraform
  configuration for deploying a cluster of Firezone Gateways behind a NAT
  gateway on Azure with a single egress IP.
- [modules/google-cloud/apps/gateway-region-instance-group](modules/google-cloud/apps/gateway-region-instance-group):
  Production-ready Terraform module for deploying regional Firezone Gateways to
  Google Cloud Compute using Regional Instance Groups.
- [modules/aws/firezone-gateway](modules/aws/firezone-gateway): Production-ready
  Terraform module for deploying Firezone Gateways to AWS using Auto Scaling
  Groups.
- [modules/azure/firezone-gateway](modules/azure/firezone-gateway):
  Production-ready Terraform module for deploying Firezone Gateways to Azure
  using Azure Orchestrated Virtual Machine Scale Sets.
