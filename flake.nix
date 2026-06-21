{
  description = "Thyx SDDM theme";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.callPackage ./default.nix { };
          thyx = self.packages.${system}.default;
        });

      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          package = self.packages.${system}.default;

          moduleEval = nixpkgs.lib.nixosSystem {
            inherit system;

            modules = [
              self.nixosModules.default

              {
                services.displayManager.sddm.thyx.enable = true;
                services.displayManager.sddm.wayland.enable = true;
              }
            ];
          };
        in
        {
          package = package;

          nixos-module = pkgs.runCommand "thyx-nixos-module-check" { } ''
            test "${moduleEval.config.services.displayManager.sddm.theme}" = "thyx"
            test -e "${package}/share/sddm/themes/thyx/metadata.desktop"
            test -e "${package}/share/sddm/themes/thyx/theme.conf"
            test -e "${package}/share/sddm/themes/thyx/src/Main.qml"
            test -e "${package}/share/fonts/truetype/thyx/PlusJakartaSans-VariableFont_wght.ttf"

            touch "$out"
          '';
        });

      nixosModules = {
        default = import ./module.nix;
        thyx = self.nixosModules.default;
      };
    };
}