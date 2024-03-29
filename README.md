# New work

https://github.com/NixOS/mobile-nixos supports sc7180 now.
If it doesn't work, contribute to it, it's a much better framework than this.
Maybe you'll even get the LTE working.

# Preparing the installation

You must first set your Chromebook to developer mode. Then you can boot
from an external storage device. You can thus prepare an external storage
device with something like the approach noted below so that you can
install onto the internal eMMC.

# Set-up

Use gptfdisk as normal, have 1 partition with type ChromeOS kernel (7F00) that is
**at least** 320 MiB in size. Unfortunately the initrd is quite big right now,
mostly due to a lack of optimization on my side.
Then, make your other partitions as usual.
I personally recommend a single partition for root using LUKS and F2FS:
```bash
cryptsetup luksFormat /dev/mmcblk1p2 --type luks2
cryptsetup luksOpen /dev/mmcblk1p2 cryptroot
mkfs.f2fs /dev/mapper/cryptroot -O extra_attr,compression,inode_checksum,sb_checksum
```

You must now make two NixOS configurations: One just for booting, and one for
your system. Respectively, one that imports `boot-kpart.nix`, and one that
imports `lazor.nix`.

When you build the boot configuration, you will get a system, which you won't
actually use. You instead use just the `kpart` file from it, and do
`sudo cp ./result/kpart /dev/mmcblk1p1`. When your laptop boots,
it will first boot this "system", that just kexecs directly into the real
system before leaving the initrd. The reason it's done this way, is
that rebuilding the `kpart` is quite expensive and annoying to do every time
you want to rebuild your system.

The other configuration will be your main configuration,
and should be configured in the standard way.
To install this onto your root filesystem, simply do
`nix-build --store /mnt`, then `nix-env -p /nix/var/nix/profiles/system --set ./result`.
The initrd in the first partition will on boot `kexec` the system you have in
`/nix/var/nix/profiles/system`.

# Tips

## Building a NixOS configuration

`nix-build '<nixpkgs/nixos>' --argstr configuration /my/config.nix`

## Image for booting from SD card or USB

`nix-build -A image`

## Sound

Use Pipewire, it works much better than PulseAudio in general.

## Root filesystem

Make "/" a `tmpfs`. This is a good practice in general.

# Known issues

- Hardware decode through `mpv --hwdec=v4l2m2m_copy` doesn't work great,
  especially seeking.
- No way to choose profile to boot (but should be easy to implement honestly)
