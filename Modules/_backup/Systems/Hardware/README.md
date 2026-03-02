# Hardware

Hardware profile detection, GPU drivers, firmware, audio, and peripherals.

## Structure

```
Hardware/
├── Types/
│   └── NixHardware/default.nix     # profile, gpu, firmware, audio, bluetooth, printing
├── Monads/
│   └── IOMNixHardware/default.nix  # wires into NixOS hardware modules
├── default.nix
└── README.md
```

## Type Space (NixHardware)

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| profile | enum: generic, laptop, desktop, server, vm, rpi | generic | Hardware profile class |
| gpu | enum: none, intel, amd, nvidia, apple | none | GPU vendor for driver selection |
| firmware | bool | true | Enable non-free firmware blobs |
| audio | enum: none, pipewire, pulseaudio | none | Audio subsystem |
| bluetooth | bool | false | Enable Bluetooth support |
| printing | bool | false | Enable CUPS printing |

## Hardware Profiles

| Profile | Enables | Use Case |
|---------|---------|----------|
| generic | Firmware only | Minimal, unknown hardware |
| laptop | fwupd, thermald, power management | Portable machines |
| desktop | fwupd | Workstations |
| server | Minimal, no GUI peripherals | Headless servers |
| vm | Virtio drivers | Virtual machines |
| rpi | Device tree, ARM firmware | Raspberry Pi |

## Exports

- `flake.modules.nixos.hardware-config` — GPU, audio, bluetooth, firmware, profile defaults
