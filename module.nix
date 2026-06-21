{ config, lib, pkgs, ... }:

let
  cfg = config.services.displayManager.sddm.thyx;
  package = cfg.package;
  themeName = package.passthru.sddmThemeName or "thyx";
  qtQmlPackages = package.passthru.qtQmlPackages or (with pkgs.qt6; [
    qtdeclarative
    qtmultimedia
    qt5compat
    qtsvg
  ]);
in
{
  options.services.displayManager.sddm.thyx = {
    enable = lib.mkEnableOption "Thyx SDDM theme";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./default.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./default.nix { }";
      description = "Thyx SDDM theme package.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];

    fonts.packages = [ package ];

    services.displayManager.sddm = {
      enable = true;
      theme = themeName;
      extraPackages = [ package ] ++ qtQmlPackages;
    };
  };
}
