{ config, pkgs, lib, ... }:
{
  imports = [ ./kernel.nix "${(import ./sources.nix).kevin-nix}/modules/depthcharge.nix" ];

  boot.loader.depthcharge = {
    enable = true;
    partition = "nodev";
  };
  boot.loader.grub.enable = false;

  boot.initrd.postMountCommands = lib.mkForce ''
    mkdir /work || fail
    mount -t overlay overlay -olowerdir=/mnt-root/nix/store,upperdir=/nix/store,workdir=/work,ro /nix/store || fail
    profile="/mnt-root/nix/var/nix/profiles/system"
    ${pkgs.kexec-tools}/bin/kexec -s -l --initrd=$profile/initrd --command-line="$(cat $profile/kernel-params) init=$(realpath $profile/init)" $profile/kernel || fail
    ${pkgs.kexec-tools}/bin/kexec -e || fail
    fail
  '';

  boot.initrd.kernelModules = [ "overlay" ];

  boot.initrd.supportedFilesystems = [ "overlay" ];
  boot.kernelParams = [ "console=tty1" "boot.shell_on_fail" ];
}
