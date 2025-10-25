{ ... }:
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      info = (builtins.fromJSON (builtins.readFile ./sources.json)).${system};

      pname = "surf";
      version = info.version;

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version;
        src = pkgs.fetchurl {
          url = info.appimage_url;
          hash = info.appimage_sha256;
        };
      };

      surf-appimage = pkgs.appimageTools.wrapType2 {
        inherit version;
        pname = "${pname}-appimage";
        src = pkgs.fetchurl {
          url = info.appimage_url;
          hash = info.appimage_sha256;
        };

        nativeBuildInputs = [ pkgs.copyDesktopItems ];
        desktopItems = [
          (pkgs.makeDesktopItem {
          })
        ];
      };

      surf = pkgs.stdenv.mkDerivation {
        inherit pname version;

        src = appimageContents;

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          patchelfUnstable
          copyDesktopItems
          makeWrapper
        ];

        buildInputs =
          (with pkgs; [
            glib
            nspr
            nss
            dbus
            cups
            cairo
            pango
            expat
            at-spi2-atk
            at-spi2-core
            alsa-lib
            libudev-zero
            gtk3
            mesa
            libxkbcommon
            libdbusmenu-gtk2
            gtk2
            dbus-glib
            gdk-pixbuf
            openssl
            vips
          ])
          ++ (with pkgs.xorg; [
            libX11
            libXcomposite
            libXdamage
            libXext
            libXfixes
            libXrandr
          ]);

        runtimeDependencies = with pkgs; [ libGL ];

        autoPatchelfIgnoreMissingDeps = [
          "libc.musl-x86_64.so.1"
        ];

        installPhase = ''
          runHook preInstall

          libExecPath="$out/lib/${pname}-bin-$version"
          mkdir -p "$libExecPath"
          cp -rv ./ "$libExecPath/"

          # Make desktop executable
          chmod +x "$libExecPath/desktop"

          mkdir -p "$out/bin"
          makeWrapper "$libExecPath/desktop" "$out/bin/${pname}" \
            --prefix LD_LIBRARY_PATH : "$rpath"

          runHook postInstall
        '';
      };
    in
    {
      packages = {
        inherit surf surf-appimage;
        default = surf;
      };
    };
}
