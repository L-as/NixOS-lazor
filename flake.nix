{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }@inputs:
  {
    nixosModules.default = {
      imports = [
        ./lazor.nix
      ];
    };
  };
}
