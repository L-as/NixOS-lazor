{ config, pkgs, lib, ... }:

{
  imports = [ ./kernel.nix ./stub-bootloader.nix ];

  boot.loader.stub.enable = true;
  boot.loader.generic-extlinux-compatible.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.enable = false;
  boot.kernelParams = [ "console=tty1" ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

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
      /*
#!/bin/bash


[ $(dd if="/dev/mmcblk*boot0" bs=3 skip=0 count=1 status_none) != "FSG" ] && return 1

fsg_size="$(dd if="/dev/mmcblk*boot0" bs=1 skip=4 count=8 status=none)"

[ $fsg_size -eq 0 ] && return 0 # wifi only

dd if="/dev/mmcblk*boot0" of=modem.fsg bs=512 skip=1 count=$((fsg_size / 512)) status=none

offset="$((fsg_size / 512 * 512))"
[ $((fsg_size % 512)) -ne 0 ] && dd if="/dev/mmcblk*boot0" of=modem.fsg bs=1 skip=$((offset + 512))" \
                    seek=$offset count="$((fsg_size % 512))" status=none

      */
    in {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      requires = [ "qrtr-ns.service" ];
      after = [ "qrtr-ns.service" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkgs.rmtfs}/bin/rmtfs -r -s -o ${rmtfs_firmware}";
        Restart = "always";
        RestartSec = "1";
      };
    };
  systemd.services.qrtr-ns = {
    serviceConfig = {
      ExecStart = "${pkgs.qrtr}/bin/qrtr-ns -f 1";
      Restart = "always";
    };
  };

  environment.systemPackages = [ pkgs.qrtr ];
}
