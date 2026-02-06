# Boot

System boot configuration capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Host / Boot |
| Purpose | Bootloader, kernel, initrd configuration |
| Targets | nixos |

## Options

| Option | Type | Default |
|--------|------|---------|
| `boot-config.enable` | bool | true |
| `boot-config.loader` | enum | "systemd-boot" |
| `boot-config.efi` | bool | true |
| `boot-config.kernelPackages` | enum | "default" |
| `boot-config.initrd.availableModules` | [str] | virtio defaults |
