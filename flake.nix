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

          nixos-vm = pkgs.testers.runNixOSTest {
            name = "thyx-nixos-smoke";

            nodes.machine = { pkgs, ... }: {
              imports = [
                self.nixosModules.default
              ];

              services.displayManager.sddm.thyx.enable = true;
              services.displayManager.sddm.wayland.enable = true;

              environment.systemPackages = with pkgs; [
                dbus
                xvfb-run
              ];

              system.stateVersion = "25.11";
            };

            testScript = ''
              machine.wait_for_unit("multi-user.target")

              machine.succeed("test -f /run/current-system/sw/share/sddm/themes/thyx/metadata.desktop")
              machine.succeed("test -f /run/current-system/sw/share/sddm/themes/thyx/theme.conf")
              machine.succeed("test -f /run/current-system/sw/share/sddm/themes/thyx/src/Main.qml")
              machine.succeed("test -f /run/current-system/sw/share/sddm/themes/thyx/backgrounds/cinder.mp4")
              machine.succeed("test -f /run/current-system/sw/share/sddm/themes/thyx/presets/cinder.conf")

              machine.succeed("test -f /run/current-system/sw/share/fonts/truetype/thyx/PlusJakartaSans-VariableFont_wght.ttf")
              machine.succeed("test -f /run/current-system/sw/share/fonts/truetype/thyx/PlusJakartaSans-Italic-VariableFont_wght.ttf")

              machine.succeed("grep -q '^Current=thyx$' /etc/sddm.conf.d/00-nixos.conf")
              machine.succeed("grep -q '^ThemeDir=/run/current-system/sw/share/sddm/themes$' /etc/sddm.conf.d/00-nixos.conf")

              machine.succeed("command -v sddm")
              machine.succeed("command -v sddm-greeter-qt6 || command -v sddm-greeter")

              machine.succeed("""
                set -euo pipefail

                greeter="$(command -v sddm-greeter-qt6 || command -v sddm-greeter)"

                set +e
                xvfb-run -a -s "-screen 0 1280x720x24" \
                  timeout 8s \
                  dbus-run-session -- \
                  env QT_QPA_PLATFORM=xcb \
                  "$greeter" --test-mode --theme /run/current-system/sw/share/sddm/themes/thyx

                code="$?"
                set -e

                [ "$code" -eq 0 ] || [ "$code" -eq 124 ]
              """)
            '';
          };
        });

      nixosModules = {
        default = import ./module.nix;
        thyx = self.nixosModules.default;
      };
    };
}