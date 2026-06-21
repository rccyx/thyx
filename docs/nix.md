# NixOS

Use the theme as a flake:

```nix
{
  inputs = {
    thyx.url = "github:rccyx/thyx";
  };

  outputs = { nixpkgs, thyx, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        thyx.nixosModules.default

        {
          services.displayManager.sddm.thyx.enable = true;
          services.displayManager.sddm.wayland.enable = true;
        }
      ];
    };
  };
}
```

Then rebuild.

```bash
sudo nixos-rebuild switch --flake .#host
```
