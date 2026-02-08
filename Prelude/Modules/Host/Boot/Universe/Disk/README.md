# Disk

Declarative disk partitioning capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Boot |
| Purpose | Declarative disk layout for nixos-anywhere and reproducible installs |
| Binding | disko (nix-community/disko) |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | auto | Enable disk partitioning |
| `devices` | attrsOf device | {} | Disk device definitions |

### Device Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `device` | str | — | Block device path |
| `tableType` | enum | "gpt" | gpt, mbr |
| `partitions` | listOf partition | [] | Partition definitions |

### Partition Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `name` | str | — | Partition label |
| `size` | str | "100%" | Size (512M, 100%) |
| `type` | enum | — | efi, swap, root, persist, home |
| `filesystem` | enum | "ext4" | vfat, ext4, btrfs, xfs, swap |
| `mountpoint` | str? | null | Mount point |

## Usage

```nix
boot-config.disk = {
  enable = true;
  devices.main = {
    device = "/dev/sda";
    tableType = "gpt";
    partitions = [
      { name = "ESP"; size = "512M"; type = "efi"; filesystem = "vfat"; mountpoint = "/boot"; }
      { name = "swap"; size = "4G"; type = "swap"; filesystem = "swap"; }
      { name = "root"; size = "100%"; type = "root"; filesystem = "ext4"; mountpoint = "/"; }
    ];
  };
};
```
