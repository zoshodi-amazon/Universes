#!/usr/bin/env nu

# Deploy interpreter - flash, format-persist, remote-build, or remote-build-oci
# Usage: default.nu <json_config>
# Config: { mode: "flash" | "format-persist" | "remote-build" | "remote-build-oci", ... }

def main [config_json: string] {
  let cfg = ($config_json | from json)
  
  match $cfg.mode {
    "flash" => {
      let machine: string = $cfg.machine
      let disk: string = $cfg.disk
      
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
      let disk: string = $cfg.disk
      
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
      let host: string = $cfg.host
      let machine: string = $cfg.machine
      
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
    "remote-build-oci" => {
      let host: string = $cfg.host
      let machine: string = $cfg.machine
      
      print $"Step 1: Syncing repo to ($host)..."
      rsync -avz --delete ~/repos/Universes/ $"($host):~/repos/Universes/"
      
      print ""
      print $"Step 2: Building ($machine) OCI on ($host)..."
      let oci_path = (ssh $host $"source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes/Prelude && nix build .#($machine)-oci --print-out-paths" | str trim)
      
      print ""
      print $"Step 3: Copying OCI tarball to local..."
      scp $"($host):($oci_path)" $"($env.HOME)/Downloads/($machine).tar.gz"
      
      print ""
      print $"Done! OCI at ~/Downloads/($machine).tar.gz"
      print $"Load with: podman load < ~/Downloads/($machine).tar.gz"
      print $"Run with:  podman run -it ($machine):latest"
      ls $"($env.HOME)/Downloads/($machine).tar.gz"
    }
    "remote-build-vm" => {
      let host: string = $cfg.host
      let machine: string = $cfg.machine
      
      print $"Step 1: Syncing repo to ($host)..."
      rsync -avz --delete ~/repos/Universes/ $"($host):~/repos/Universes/"
      
      print ""
      print $"Step 2: Building ($machine) VM on ($host)..."
      let vm_path = (ssh $host $"source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes/Prelude && nix build .#($machine)-vm --print-out-paths" | str trim)
      
      print ""
      print $"Step 3: Copying VM to local..."
      mkdir -p $"($env.HOME)/VMs/($machine)"
      rsync -avz --progress $"($host):($vm_path)/" $"($env.HOME)/VMs/($machine)/"
      
      print ""
      print $"Done! VM at ~/VMs/($machine)"
      print $"Run with: just run-vm ($machine)"
      ls $"($env.HOME)/VMs/($machine)"
    }
  }
}
