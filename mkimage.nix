# This has been taken from https://github.com/thefloweringash/kevin-nix/commit/fedcf821bca2ff4798e4436b1bc5813962bea8b5,
# and modified to support a bigger kpart.

# This module creates a bootable SD card image containing the given
# NixOS configuration. The generated image is GPT formatted, with a
# kernel partition (kernel, initrd, dtbs, command line) in the first
# partition and the ext4 root in the second partition. The generated
# image is sized to fit its contents, and a boot script automatically
# resizes the root partition to fit the device on the first boot.
#
# The derivation for the SD image will be placed in
# config.system.build.sdImage

{ config, lib, inputs, pkgs, ... }:

with lib;

let
  rootfsImage = pkgs.callPackage "${inputs.nixpkgs}/nixos/lib/make-ext4-fs.nix" {
    inherit pkgs;
    inherit (config.sdImage) storePaths;
    volumeLabel = "NIXOS_SD";
  };
in
{
  options.sdImage = {
    imageName = mkOption {
      default = "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.system}.img";
      description = ''
        Name of the generated image file.
      '';
    };

    imageBaseName = mkOption {
      default = "nixos-sd-image";
      description = ''
        Prefix of the name of the generated image file.
      '';
    };

    storePaths = mkOption {
      type = with types; listOf package;
      example = literalExample "[ pkgs.stdenv ]";
      description = ''
        Derivations to be included in the Nix store in the generated SD image.
      '';
    };

    installPaths = mkOption {
      type = with types; listOf package;
      example = literalExample "[ pkgs.busybox pkgs.extlinux-config ]";
      description = ''
        Derivations to be install into the root of the generated SD image.
      '';
    };

    kpart = mkOption {
      type = types.str;
      example = literalExample "\${config.system.build.toplevel}/kpart";
      description = ''
        Kernel partition to install into the generated SD image.
      '';
    };
  };

  config = {
    boot.loader.depthcharge = {
      enable = true;
      partition = "nodev";
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };

    system.build.sdImage = pkgs.stdenv.mkDerivation {
      name = config.sdImage.imageName;

      buildInputs = with pkgs; [ e2fsprogs parted libfaketime utillinux vboot_reference xz ];

      diskUUID = "A8ABB0FA-2FD7-4FB8-ABB0-2EEB7CD66AFA";
      bootUUID = "534078AF-3BB4-EC43-B6C7-828FB9A788C6";
      rootUUID = "0340EA1D-C827-8048-B631-0C60D4478796";

      buildCommand = ''
        mkdir -p $out/nix-support $out/sd-image
        export img=$out/sd-image/${config.sdImage.imageName}

        echo "${pkgs.stdenv.system}" > $out/nix-support/system
        echo "file sd-image $img.xz" >> $out/nix-support/hydra-build-products

        # Create the image file sized to fit /, plus 20M of slack, plus a kernel partition
        kernelSizeMegs=512
        rootSizeBlocks=$(du -B 512 --apparent-size ${rootfsImage} | awk '{ print $1 }')
        imageSize=$((rootSizeBlocks * 512 + (20 + $kernelSizeMegs) * 1024 * 1024))
        truncate -s $imageSize $img

        sfdisk --no-reread --no-tell-kernel $img <<EOF
            label: gpt
            label-id: $diskUUID
            size=512m, type=FE3A2A5D-4F32-41A7-B725-ACCC3285A309, uuid=$bootUUID, name=kernel
            type=B921B045-1DF0-41C3-AF44-4C6F280D3FAE, uuid=$rootUUID, name=NIX_SD
        EOF

        cgpt add -i 1 -S 1 -T 5 -P 10 $img

        # Copy the kernel to the SD image
        eval $(partx $img -o START,SECTORS --nr 1 --pairs)
        dd conv=notrunc if=${config.sdImage.kpart} of=$img seek=$START count=$SECTORS

        # Copy the rootfs into the SD image
        eval $(partx $img -o START,SECTORS --nr 2 --pairs)
        dd conv=notrunc if=${rootfsImage} of=$img seek=$START count=$SECTORS

        xz --threads 0 $img
      '';
    };

    boot.postBootCommands = ''
      # On the first boot do some maintenance tasks
      if [ -f /nix-path-registration ]; then
        # Figure out device names for the boot device and root filesystem.
        rootPart=$(readlink -f /dev/disk/by-label/NIXOS_SD)
        bootDevice=$(lsblk -npo PKNAME $rootPart)

        # Recreate the current partition table without the length limit
        sfdisk -d $bootDevice | ${pkgs.gnugrep}/bin/grep -v '^last-lba:' | sfdisk --no-reread $bootDevice

        # Resize the root partition and the filesystem to fit the disk
        echo ",+," | sfdisk -N2 --no-reread $bootDevice
        ${pkgs.parted}/bin/partprobe
        ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

        # Register the contents of the initial Nix store
        ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

        # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
        touch /etc/NIXOS
        ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

        # Prevents this from running on later boots.
        rm -f /nix-path-registration
      fi
    '';
  };
}
