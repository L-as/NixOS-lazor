{ pkgs ? <nixpkgs> }:

{
  image = (import "${pkgs}/nixos" { configuration = ./image.nix; }).config.system.build.sdImage;
}
