#!/usr/bin/env -S zsh -i

snapshots=($(sudo zfs list -t snapshot -o name -H z/work | tac))

set -x
for snapshot in "${snapshots[@]}"; do
  sudo mount -t zfs "$snapshot" /mnt/snapshot

  if [[ -f /mnt/snapshot/zsh-history ]]; then
    builtin fc -R -I /mnt/snapshot/zsh-history
    sudo umount /mnt/snapshot
  else
    sudo umount /mnt/snapshot
    break
  fi
done

builtin fc -W "$HISTFILE"
