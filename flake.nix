{
  description = "Package and service for OmniPoly, frontend for LanguageTool and LibreTranslate";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11-small";

  outputs =
    {
      self,
      nixpkgs,
      nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;

      overlayList = [ self.overlays.default ];

      pkgsBySystem = forEachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = overlayList;
        }
      );

    in rec {
      overlays.default = final: prev: { omnipoly = final.callPackage ./package.nix { }; };

      packages = forEachSystem (system: {
        omnipoly = pkgsBySystem.${system}.omnipoly;
        default = pkgsBySystem.${system}.omnipoly;
      });

      nixosModules = import ./nixos-modules { overlays = overlayList; };
    };
}
