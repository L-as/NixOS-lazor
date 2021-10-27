{ config, pkgs, lib, ... }:
let
  emptyRegistry = builtins.toFile "empty-registry.json" (
    builtins.toJSON {
      flakes = [];
      version = 2;
    }
  );
in
{
  imports = [ ./lazor.nix ./mkimage.nix ];
  
  sdImage.kpart = "${config.system.build.toplevel}/kpart";
  sdImage.storePaths = [ config.system.build.toplevel ];

  nix = {
    buildCores = 0;
    autoOptimiseStore = true;
    trustedUsers = [ "root" "@wheel" ];
    allowedUsers = [ "root" "@wheel" ];
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes recursive-nix ca-derivations ca-references
      builders-use-substitutes = true
      flake-registry = ${emptyRegistry}
    '';
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC";

  nixpkgs.config.allowUnfree = true;
  
  users.mutableUsers = false;
  users.users.root.password = "";
  users.users.user = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    password = "";
  };

  networking.useDHCP = true;
  networking.hostName = "nixos";
  networking.wireless.enable = true;
  networking.firewall.enable = true;

  services.journald.forwardToSyslog = false;
  services.journald.extraConfig = ''
    Storage=volatile
    ReadKMsg=false
    RuntimeMaxUse=50M
  '';
  services.journald.rateLimitBurst = 100;
  services.journald.rateLimitInterval = "30s";
}
