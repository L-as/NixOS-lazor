{ config, pkgs, lib, ... }:

{
  imports = [ ./kernel.nix ./stub-bootloader.nix ];

  boot.loader.stub.enable = true;
  boot.loader.generic-extlinux-compatible.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.enable = false;
  boot.kernelParams = [ "console=tty1" ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  hardware.enableAllFirmware = true; # FIXME: is this needed?

  systemd.services.rmtfs =
    let
      # This isn't good, we should use the real firmware instead of stubs.
      rmtfs_firmware = pkgs.runCommand "rmtfs-firmware" {} ''
        mkdir $out
        dd if=/dev/zero bs=1M count=2 of=$out/modem_fs1
        dd if=/dev/zero bs=1M count=2 of=$out/modem_fs2
        dd if=/dev/zero bs=1M count=2 of=$out/modem_fsg
        dd if=/dev/zero bs=1M count=2 of=$out/modem_fsc
      '';
    in {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkgs.rmtfs}/bin/rmtfs -r -s -o ${rmtfs_firmware}";
      };
    };
}
