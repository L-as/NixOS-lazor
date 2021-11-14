{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
  {
    image = (import "${nixpkgs}/nixos" { configuration = ./image.nix; system = "aarch64-linux"; }).config.system.build.sdImage;
  };
}
