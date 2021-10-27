{ config, pkgs, lib, ... }:

{
  options = {
    boot.loader.stub.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };
  config = lib.mkIf config.boot.loader.stub.enable {
    system.build.installBootLoader = "${pkgs.coreutils}/bin/true";
    system.boot.loader.id = "stub";
  };
}
