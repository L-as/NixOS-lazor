{ config, pkgs, lib, ... }:

let
  inherit (import ./sources.nix) cadmium;
in
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.overlays = [(final: prev: {
    makeModulesClosure = args:
      let old = (prev.makeModulesClosure args); in
      pkgs.runCommand "makeModulesClosure-overriden" {} ''
      	mkdir $out
      	ln -t $out -s ${old}/*
      	rm $out/lib
      	mkdir $out/lib
      	ln -t $out/lib -s ${old}/lib/*
      	rm -r $out/lib/firmware
        ln -s ${args.firmware}/lib/firmware $out/lib/firmware
      '';
    firmware-trogdor = pkgs.runCommand "firmware-trogdor" {} ''
      mkdir -p $out/lib
      cp -rT ${cadmium}/baseboard/trogdor/firmware $out/lib/firmware
    '';
    rmtfs = final.callPackage ./rmtfs.nix {};
    qmic = final.callPackage ./qmic.nix {};
    qrtr = final.callPackage ./qrtr.nix {};
  })];

  hardware.firmware = [ pkgs.firmware-trogdor ];

  boot.initrd.kernelModules = import ./kernel-modules.nix;
}
