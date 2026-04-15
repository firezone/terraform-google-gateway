# Firezone Terraform Modules for Google Cloud Platform

This repo contains Terraform modules to use for Firezone deployments on Google
Cloud Platform.

## Examples

- [NAT Gateway](./examples/nat-gateway): This example shows how to deploy one or
  more Firezone Gateways in a single GCP VPC that is configured with a Cloud NAT
  for egress. Read this if you're looking to deploy Firezone Gateways behind a
  single, shared static IP address on GCP.

## Gateway Customization

The module supports enabling Gateway flow logs directly with
`observability_enable_flow_logs = true`, which exports
`FIREZONE_FLOW_LOGS=true` during installation.

To run your own bootstrap logic on every instance replacement, set
`additional_startup_commands` with one or more shell snippets. These commands
run at the end of cloud-init `runcmd`, after the Firezone Gateway and Google
Cloud Ops Agent installation steps.

```hcl
module "gateways" {
  source = "firezone/gateway/google"

  # ...

  observability_enable_flow_logs = true

  additional_startup_commands = [
    <<-EOT
    curl -fsSL https://example.com/install-monitoring-agent.sh -o /tmp/install-monitoring-agent.sh
    bash /tmp/install-monitoring-agent.sh
    EOT
  ]
}
```
