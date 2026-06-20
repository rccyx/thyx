{
  lib,
  stdenvNoCC,
  qt6,
}:

stdenvNoCC.mkDerivation {
  pname = "thyx";
  version = "1.0.0";

  src = ./.;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    theme_dir="$out/share/sddm/themes/thyx"
    font_dir="$out/share/fonts/truetype/thyx"
    license_dir="$out/share/licenses/thyx"

    mkdir -p "$theme_dir" "$font_dir" "$license_dir"

    install -Dm0644 metadata.desktop "$theme_dir/metadata.desktop"
    install -Dm0644 theme.conf "$theme_dir/theme.conf"

    cp -r backgrounds "$theme_dir/backgrounds"
    cp -r icons "$theme_dir/icons"
    cp -r presets "$theme_dir/presets"
    cp -r src "$theme_dir/src"

    install -Dm0644 fonts/*.ttf -t "$font_dir"
    install -Dm0644 LICENSE "$license_dir/LICENSE"
    install -Dm0644 fonts/OFL.txt "$license_dir/OFL.txt"

    runHook postInstall
  '';

  passthru = {
    sddmThemeName = "thyx";
    qtQmlPackages = with qt6; [
      qtdeclarative
      qtmultimedia
      qt5compat
      qtsvg
    ];
  };

  meta = {
    description = "Thyx SDDM theme";
    homepage = "https://github.com/rccyx/thyx";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
