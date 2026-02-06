# Network

System-level networking configuration.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Host / Network |
| Purpose | Firewall, DHCP, SSH daemon, wireless |
| Targets | nixos |

## Options

| Option | Type | Default |
|--------|------|---------|
| `network-config.enable` | bool | true |
| `network-config.dhcp` | bool | true |
| `network-config.firewall.enable` | bool | true |
| `network-config.firewall.allowedTCPPorts` | [port] | [22] |
| `network-config.ssh.enable` | bool | true |
| `network-config.wireless.enable` | bool | false |
