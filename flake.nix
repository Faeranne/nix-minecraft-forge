{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  outputs = inputs@{ self, nixpkgs, ... }:
  {
    nixosModules.minecraftForge = import ./modules/minecraft-forge self;
  };
}
