# Disk

Declarative disk partitioning, filesystem strategy, and encryption via disko.

## Structure

```
Disk/
├── Types/
│   └── NixDisk/default.nix     # layout, filesystem, encryption, devices
├── Monads/
│   └── IOMNixDisk/default.nix  # wires into disko + LUKS/ZFS + remote unlock
├── default.nix
└── README.md
```

## Type Space (NixDisk)

3 orthogonal concerns that determine the deployment shape:

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| layout | enum: single-disk, multi-disk, custom | single-disk | Disk layout strategy |
| filesystem | enum: ext4, btrfs, zfs | ext4 | Root filesystem type |
| encryption | enum: none, luks, zfs-native | none | Disk encryption method |
| remoteUnlock | bool | false | SSH-based remote unlock in initrd |
| devices | attrsOf device | {} | Disk device definitions for disko |
| swapSize | str | none | Swap partition size or none |

## Filesystem Strategy

| Filesystem | Strengths | Use Case |
|------------|-----------|----------|
| ext4 | Simple, stable, fast | Default, VMs, simple servers |
| btrfs | Snapshots, subvolumes, compression | Workstations, rollback-friendly |
| zfs | Encryption, dedup, snapshots, scrub | NAS, data integrity critical |

## Encryption Strategy

| Method | Mechanism | Remote Unlock |
|--------|-----------|---------------|
| none | No encryption | N/A |
| luks | LUKS2 on partition, passphrase at boot | SSH in initrd (port 2222) |
| zfs-native | ZFS native encryption, key-based | SSH in initrd (port 2222) |

## Exports

- `flake.modules.nixos.disk-config` — disko partitioning + encryption + remote unlock
