# nixos

My nixos configs repo

Setup as per <https://grahamc.com/blog/erase-your-darlings/> and <https://carjorvaz.com/posts/installing-nixos-with-root-on-tmpfs-and-encrypted-zfs-on-a-netcup-vps/>

## Laptop

### Install laptop

```bash
sudo zpool create \
    -o ashift=12 \
    -O encryption=on \
    -O keylocation=file://{keyFile} \
    -O keyformat=passphrase \
    z \
    {diskId}
```

### Update laptop

```bash
nixos-rebuild switch --use-remote-sudo --refresh --show-trace --flake github:HippocampusGirl/nixos#laptop
```

## Server

### Install server

https://carjorvaz.com/posts/installing-nixos-with-root-on-tmpfs-and-encrypted-zfs-on-a-netcup-vps/

```bash
sudo zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O atime=off \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O xattr=sa \
    -O mountpoint=none \
    -O encryption=on \
    -O keylocation=prompt \
    -O keyformat=passphrase \
    z \
    /dev/disk/by-partuuid/...

sudo zfs create z/nix
```

## Restore from backup

```bash
for dataset in z/www z/postgres z/lea z/persist; do
    first=$(zfs list -t snapshot -o name -S creation "z/server.dzo-owl.ts.net/${dataset}" | tail --lines=1)
    last=$(zfs list -t snapshot -o name -s creation "z/server.dzo-owl.ts.net/${dataset}" | tail --lines=1)
    sudo zfs send "${first}" | pv | ssh -p 22 nixos@5.45.110.175 sudo zfs recv -v -x compression "${dataset}"
    sudo zfs send -I "${first}" "${last}" | pv | ssh -p 22 nixos@5.45.110.175 sudo zfs recv -v "${dataset}"
done
```

### Reinstall server

```bash
sudo mount -t tmpfs none /mnt
sudo mkdir -p /mnt/{boot,nix,persist}
sudo mount /dev/sda1 /mnt/boot
sudo zpool import z -f
sudo zfs load-key -a

sudo zfs mount z/lea
sudo mount -t zfs z/nix /mnt/nix
sudo mount -t zfs z/persist /mnt/persist
sudo mkdir -p /mnt/etc/nixos /mnt/var/log
sudo mount -o bind /mnt/persist/var/log /mnt/var/log
sudo mount -o bind /lea /mnt/lea

sudo nixos-install --no-channel-copy --root /mnt --flake path:///lea/nixos#server --show-trace

sudo umount -Rl /mnt
sudo zpool export -a
sudo reboot

nixos-rebuild switch -L --use-remote-sudo --fast --flake /mnt/etc/nixos#server
```

### Update server

```bash
sudo nixos-rebuild switch -L --use-remote-sudo --flake path:///lea/nixos#server --show-trace --refresh
```

### LXC storage config

```
volume.zfs.block_mode: "true"
volume.size: "96GiB"
```

## Home

### Format

```bash
sudo mkfs.vfat /dev/nvme0n1p1

sudo zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O special_small_blocks=1M \
    -o encryption=on \
    -o keylocation=prompt \
    -o keyformat=passphrase \
    z mirror \
    /dev/disk/by-id/ata-*

sudo zpool add z \
    -o ashift=12 \
    special mirror \
    /dev/disk/by-id/nvme-*

sudo zfs set dedup=on z

sudo zfs create -o mountpoint=/lea z/lea
sudo zfs create -o mountpoint=legacy z/nix
sudo zfs create -o mountpoint=legacy z/persist
```

### Install home

```bash
mkdir .ssh
cat <<EOF > .ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETA8z05h0cx/Zma9WRKNcG+ckBJ1k35dGYLnAew1BXZ
EOF

sudo mount -t tmpfs none /mnt
sudo mkdir -p /mnt/{boot,nix,persist}
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo zpool import z -f
sudo zfs load-key -a

sudo zfs mount z/lea
sudo mount -t zfs z/nix /mnt/nix
sudo mount -t zfs z/persist /mnt/persist
sudo mkdir -p /mnt/etc/nixos /mnt/var/log /mnt/persist/var/log /mnt/lea
sudo mount -o bind /mnt/persist/var/log /mnt/var/log
sudo mount -o bind /lea /mnt/lea

sudo nixos-install --impure --no-channel-copy --root /mnt --flake path:///lea/nixos#home

sudo umount -Rl /mnt
sudo zpool export -a
sudo reboot

sudo nixos-rebuild switch -L --use-remote-sudo --flake path:///lea/nixos#home
```
