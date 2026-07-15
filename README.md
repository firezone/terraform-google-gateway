# Firezone Gateway module for Google Cloud Platform

Deploys one or more [Firezone](https://www.firezone.dev) Gateways as regional
managed instance groups in an existing VPC. Each instance installs the Gateway
on first boot using the official
[systemd install script](https://github.com/firezone/firezone/blob/main/scripts/gateway-systemd-install.sh)
and registers itself with your Firezone account. Instances are health-checked
and auto-healed by the instance group manager.

## Prerequisites

- A Firezone account with a Site to deploy Gateways into. Generate deploy
  tokens from the admin portal under **Sites → \<site\> → Deploy Gateway**.
- An existing VPC with a subnetwork for the instances and egress to the
  internet (Cloud NAT or public IPs) so the Gateways can reach the Firezone
  API. The instances run Ubuntu 24.04 LTS.

## Usage

```hcl
module "gateways" {
  source = "firezone/gateway/google"

  project_id = var.project_id

  # One single-owner token per Gateway instance; one instance is deployed
  # per token.
  tokens = var.tokens

  compute_network    = google_compute_network.firezone.id
  compute_subnetwork = google_compute_subnetwork.firezone.id
  compute_region     = var.region

  compute_instance_type = "n1-standard-1"
}
```

See [examples/nat-gateway](./examples/nat-gateway) for a complete working
example including the VPC, subnetwork, and Cloud NAT.

### Legacy: multi-owner token

Multi-owner tokens are considered legacy and should only be used for existing
deployments. A single token is shared by every Gateway instance, and the
instance count is set with `compute_instance_replicas`:

```hcl
module "gateways" {
  source = "firezone/gateway/google"

  project_id = var.project_id

  # A single multi-owner token shared by all Gateway instances (legacy).
  token                     = var.token
  compute_instance_replicas = 3

  compute_network    = google_compute_network.firezone.id
  compute_subnetwork = google_compute_subnetwork.firezone.id
  compute_region     = var.region

  compute_instance_type = "n1-standard-1"
}
```

## Token modes

The module supports both Firezone token types. Set exactly one of the two
variables:

| Mode | Variable | Behavior |
|------|----------|----------|
| Single-owner (default) | `tokens` | One token per instance; one single-instance managed instance group is deployed per token in the list. Each token can only be used by one connected Gateway at a time. |
| Multi-owner (legacy) | `token` | A single token shared by every Gateway instance in one managed instance group; the instance count is set with `compute_instance_replicas`. |

Single-owner tokens are the default way to deploy Gateways. Multi-owner tokens
are considered legacy and are supported for existing deployments only; new
deployments should use single-owner tokens.

With single-owner tokens, the number of Gateway instances is determined by the
length of the token list — to scale up, append tokens; to scale down, remove
tokens from the end. Do not set `compute_instance_replicas` in this mode.
Tokens are assigned to instance groups by list position: `tokens[0]` goes to
instance group `0`, and so on. A single-owner token can be reused by a
replacement instance once the previous Gateway using it has disconnected from
the portal — this is what allows auto-healing to replace an unhealthy
instance. When changing the list, replace tokens in place rather than removing
entries from the middle — removing a middle entry shifts every token after it
to a different instance group and forces those instances to be replaced.

## High availability

Deploy at least 3 replicas for high availability. Gateways in the same Site
automatically load-balance and fail over. See the
[Gateway deployment docs](https://www.firezone.dev/kb/deploy/gateways) for
sizing and architecture recommendations.

## Upgrading and instance replacement

The Firezone token and other settings are passed via cloud-init in the
instance template, so changing `vsn`, tokens, or observability settings
**replaces the instances** via a rolling update. This is safe for connectivity
as long as other Gateways in the Site remain online. Pinning `vsn` (rather
than `latest`) keeps replacements reproducible.

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | ID of a Google Cloud Project. | `string` | n/a | yes |
| `compute_network` | VPC network to deploy the Gateways in. | `string` | n/a | yes |
| `compute_subnetwork` | Subnetwork for the instances. | `string` | n/a | yes |
| `compute_region` | Region to deploy the instances in. | `string` | n/a | yes |
| `compute_instance_type` | The machine type. Gateways are lightweight; see [sizing recommendations](https://www.firezone.dev/kb/deploy/gateways#sizing-recommendations). | `string` | n/a | yes |
| `tokens` | A list of single-owner Firezone tokens, one per Gateway instance. One instance is deployed per token. Mutually exclusive with `token`. | `list(string)` | `null` | one of |
| `token` | A multi-owner Firezone token shared by all Gateway instances (legacy). Mutually exclusive with `tokens`. | `string` | `null` | one of |
| `compute_instance_replicas` | The number of Gateway instances to deploy when using `token` (legacy). Must not be set with `tokens`. | `number` | `3` | no |
| `compute_instance_availability_zones` | Zones in `compute_region` to deploy in. Empty means all available zones. | `list(string)` | `[]` | no |
| `compute_instance_architecture` | The architecture of the compute instance (`amd64` or `arm64`). | `string` | `"amd64"` | no |
| `compute_provision_public_ipv4_address` | Whether to provision a public IPv4 address for the instances. | `bool` | `true` | no |
| `compute_provision_public_ipv6_address` | Whether to provision a public IPv6 address for the instances. | `bool` | `true` | no |
| `swap_size_gb` | Size of the swap partition in GB. `0` disables swap. | `number` | `0` | no |
| `queue_count` | Number of max RX/TX queues to assign to the NIC. | `number` | `2` | no |
| `name` | Name of the application. | `string` | `"gateway"` | no |
| `labels` | Labels to add to all resources created by this module. | `map(string)` | `{}` | no |
| `max_unavailable_fixed` | Maximum number of instances unavailable during updates. | `number` | `max(1, zones)` | no |
| `max_surge_fixed` | Max extra instances during updates. | `number` | computed | no |
| `vsn` | The Gateway version to deploy. | `string` | `"latest"` | no |
| `api_url` | The Firezone API URL. | `string` | `"wss://api.firezone.dev"` | no |
| `artifact_url` | URL from which the install script downloads the Gateway binary. | `string` | `"https://www.firezone.dev/dl/firezone-gateway"` | no |
| `additional_startup_commands` | Additional shell commands to run at the end of cloud-init `runcmd`. | `list(string)` | `[]` | no |
| `health_check` | Health check used for the auto-healing policy. | `object` | see `variables.tf` | no |
| `observability_log_level` | Sets `RUST_LOG` for the Gateway process. | `string` | `"info"` | no |
| `observability_log_format` | Sets `FIREZONE_LOG_FORMAT`. Either `human` or `json`. | `string` | `"human"` | no |
| `observability_enable_flow_logs` | Sets `FIREZONE_FLOW_LOGS=true` for the Gateway when enabled. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| `service_account` | The service account attached to the instances. |
| `target_tags` | Network tags applied to the instances. |
| `instance_template` | The first instance template (legacy compatibility). |
| `instance_group` | The first instance group manager (legacy compatibility). |
| `instance_templates` | All instance templates, one per token in single-owner mode. |
| `instance_groups` | All instance group managers, one per token in single-owner mode. |

## Examples

- [NAT Gateway](./examples/nat-gateway): Deploy one or more Firezone Gateways
  in a single GCP VPC configured with a Cloud NAT for egress. Read this if
  you're looking to deploy Firezone Gateways behind a single, shared static IP
  address on GCP.

## License

See [LICENSE](./LICENSE).
