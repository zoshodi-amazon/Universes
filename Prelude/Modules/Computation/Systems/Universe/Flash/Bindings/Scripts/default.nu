#!/usr/bin/env nu

# Flash NixOS images to devices
# Usage: flash [--profile <profile>] [--format <format>] [--device <device>]

def main [
  --profile: string  # Profile: minimal, headless, workstation, sovereignty
  --format: string   # Format: iso, raw-efi, sd-card, vm
  --device: string   # Target device (e.g., /dev/sda, /dev/mmcblk0)
  --dry-run          # Show what would be done without executing
] {
  let profiles = ["minimal" "headless" "workstation" "sovereignty"]
  let formats = ["iso" "raw-efi" "sd-card" "vm"]
  
  # Interactive mode if no args
  let selected_profile = if ($profile | is-empty) {
    print "Select profile:"
    $profiles | enumerate | each { |it| print $"  ($it.index + 1). ($it.item)" }
    let choice = (input "Choice [1-4]: " | into int) - 1
    $profiles | get $choice
  } else { $profile }
  
  let selected_format = if ($format | is-empty) {
    print "\nSelect format:"
    $formats | enumerate | each { |it| print $"  ($it.index + 1). ($it.item)" }
    let choice = (input "Choice [1-4]: " | into int) - 1
    $formats | get $choice
  } else { $format }
  
  # VM doesn't need device
  if $selected_format == "vm" {
    print $"\nBuilding and running ($selected_profile)-vm..."
    if not $dry_run {
      nix run $".#($selected_profile)-vm"
    }
    return
  }
  
  let selected_device = if ($device | is-empty) {
    print "\nAvailable devices:"
    lsblk -d -o NAME,SIZE,MODEL | print
    input "\nDevice (e.g., /dev/sda): "
  } else { $device }
  
  # Safety check
  print $"\nWARNING: This will ERASE ALL DATA on ($selected_device)"
  let confirm = (input "Type 'yes' to confirm: ")
  if $confirm != "yes" {
    print "Aborted."
    return
  }
  
  # Build image
  let image_name = $"($selected_profile)-($selected_format)"
  print $"\nBuilding ($image_name)..."
  
  if $dry_run {
    print $"[DRY RUN] Would run: nix build .#($image_name)"
    print $"[DRY RUN] Would flash to: ($selected_device)"
    return
  }
  
  nix build $".#($image_name)"
  
  # Flash based on format
  let image_path = match $selected_format {
    "iso" => "./result/iso/*.iso" 
    "raw-efi" => "./result"
    "sd-card" => "./result/sd-image/*.img"
    _ => "./result"
  }
  
  print $"\nFlashing to ($selected_device)..."
  
  # Unmount if mounted
  try { umount $"($selected_device)*" }
  
  # Flash with dd
  sudo dd if=(glob $image_path | first) of=$selected_device bs=4M status=progress conv=fsync
  
  print $"\nDone! You can now boot from ($selected_device)"
}
