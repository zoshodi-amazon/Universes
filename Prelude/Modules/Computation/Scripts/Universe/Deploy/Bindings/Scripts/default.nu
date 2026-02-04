#!/usr/bin/env nu

# Deploy interpreter - flash, format-persist, or remote-build
# Usage: default.nu <config_path>
# Config: { mode: "flash" | "format-persist" | "remote-build", ... }

def main [config_path: string] {
  let cfg = (open $config_path)
  
  match $cfg.mode {
    "flash" => {
      let machine = $cfg.machine
      let disk = $cfg.disk
      
      print $"Unmounting ($disk)..."
      try { diskutil unmountDisk $disk } catch { }
      
      let local_iso = $"($env.HOME)/Downloads/($machine).iso"
      let iso = if ($local_iso | path exists) {
        print $"Using pre-built ISO: ($local_iso)"
        $local_iso
      } else {
        print $"Building ($machine) ISO..."
        nix build $".#($machine)-iso" --print-out-paths
        ls result/iso/*.iso | get name | first
      }
      
      let size = (ls $iso | get size | first)
      let target = if ($disk | str starts-with "/dev/disk") {
        $disk | str replace "/dev/disk" "/dev/rdisk"
      } else {
        $disk
      }
      
      print ""
      print $"WARNING: This will ERASE ALL DATA on ($disk)"
      print $"ISO:    ($iso)"
      print $"Size:   ($size)"
      print $"Target: ($target)"
      print ""
      let confirm = (input "Type 'yes' to confirm: ")
      if $confirm != "yes" {
        print "Aborted."
        exit 1
      }
      
      print $"Writing to ($target)..."
      sudo dd $"if=($iso)" $"of=($target)" bs=4m status=progress conv=fsync
      sync
      print "Done! USB is ready to boot."
    }
    "format-persist" => {
      let disk = $cfg.disk
      
      print $"WARNING: This will ERASE ALL DATA on ($disk)"
      print "Filesystem: ext4"
      print "Label:      NIXOS_PERSIST"
      print ""
      let confirm = (input "Type 'yes' to confirm: ")
      if $confirm != "yes" {
        print "Aborted."
        exit 1
      }
      
      try { diskutil unmountDisk $disk } catch { }
      sudo mkfs.ext4 -L NIXOS_PERSIST $disk
      print "Done! SD card is ready for persistence."
    }
    "remote-build" => {
      let host = $cfg.host
      let machine = $cfg.machine
      
      print $"Step 1: Syncing repo to ($host)..."
      rsync -avz --delete ~/repos/Universes/ $"($host):~/repos/Universes/"
      
      print ""
      print $"Step 2: Building ($machine) on ($host)..."
      let iso_path = (ssh $host $"source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes/Prelude && nix build .#($machine)-iso --print-out-paths" | str trim)
      
      print ""
      print $"Step 3: Copying ISO to ~/Downloads/($machine).iso..."
      scp $"($host):($iso_path)/iso/*.iso" $"($env.HOME)/Downloads/($machine).iso"
      
      print ""
      print $"Done! ISO at ~/Downloads/($machine).iso"
      ls $"($env.HOME)/Downloads/($machine).iso"
    }
  }
}
