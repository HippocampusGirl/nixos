# nixos
My nixos configs repo

Setup as per <https://grahamc.com/blog/erase-your-darlings/> and <https://carjorvaz.com/posts/installing-nixos-with-root-on-tmpfs-and-encrypted-zfs-on-a-netcup-vps/>

## Laptop

### Update laptop
```bash
nixos-rebuild switch --use-remote-sudo --refresh --show-trace --flake github:HippocampusGirl/nixos#laptop
```

## Server

### Install server

```bash
sudo mount -t tmpfs none /mnt
sudo mkdir -p /mnt/{boot,nix,persist}
sudo mount /dev/vda3 /mnt/boot
sudo zpool import z -f
sudo zfs load-key -a

sudo zfs mount z/lea
sudo mount -t zfs z/nix /mnt/nix
sudo mount -t zfs z/persist /mnt/persist
sudo mkdir -p /mnt/etc/nixos /mnt/var/log
sudo mount -o bind /mnt/persist/var/log /mnt/var/log

sudo nixos-install --impure --no-channel-copy --root /mnt --flake /lea/machines/nixos#server

sudo umount -Rl /mnt
sudo zpool export -a
sudo reboot

nixos-rebuild switch -L --use-remote-sudo --fast --flake /mnt/etc/nixos#server
```

### Update server

```bash
sudo nixos-rebuild switch -L --use-remote-sudo --flake path:///lea/nixos#server --show-trace --refresh
```

## Home

### Format
```bash
sudo mkfs.vfat /dev/nvme0n1p1

sudo zfs create -o mountpoint=legacy zyy/nix
sudo zfs create -o mountpoint=legacy zyy/persist
```

### Install home
```bash
sudo mount -t tmpfs none /mnt
sudo mkdir -p /mnt/{boot,nix,persist}
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo zpool import z -f
sudo zfs load-key -a

sudo zfs mount zyy/lea
sudo mount -t zfs zyy/nix /mnt/nix
sudo mount -t zfs zyy/persist /mnt/persist
sudo mkdir -p /mnt/etc/nixos /mnt/var/log /mnt/persist/var/log
sudo mount -o bind /mnt/persist/var/log /mnt/var/log

sudo nixos-install --impure --no-channel-copy --root /mnt --flake /lea/machines/nixos#server

sudo umount -Rl /mnt
sudo zpool export -a
sudo reboot

nixos-rebuild switch -L --use-remote-sudo --fast --flake /mnt/etc/nixos#server
```