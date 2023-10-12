# nixos
My nixos configs repo.

## Deploy laptop
```bash
nixos-rebuild switch --use-remote-sudo --refresh --show-trace --flake github:HippocampusGirl/nixos#laptop
```

## Deploy server
```bash
sudo nixos-rebuild switch -L --use-remote-sudo --flake path:///lea/nixos#server --show-trace --refresh
```