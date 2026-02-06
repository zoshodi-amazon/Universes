# SSH Module

SSH client and server configuration.

## Structure

```
SSH/
├── Options/index.nix      # port, forwardAgent, hosts
├── Env/index.nix          # SSH_* vars
├── Bindings/index.nix     # ssh-connect, ssh-copy-id-helper
├── Instances/index.nix    # homeManager, nixos, darwin
└── index.nix
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| port | 22 | SSH port |
| forwardAgent | false | Forward SSH agent |
| compression | true | Enable compression |
| serverAliveInterval | 60 | Keep-alive interval |
| serverAliveCountMax | 3 | Keep-alive count |
| hosts | {} | Host configurations |

## Host Config

```nix
{
  ssh.enable = true;
  ssh.hosts = {
    myserver = {
      hostname = "192.168.1.100";
      user = "admin";
      port = 22;
      identityFile = "~/.ssh/id_ed25519";
    };
  };
}
```

## Bindings

- `ssh-connect` - gum-based host selector
- `ssh-copy-id-helper` - copy key to selected host

## Instances

- **homeManager** - ~/.ssh/config
- **nixos** - openssh server + firewall
- **darwin** - uses built-in ssh
