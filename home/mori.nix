{ inputs, config, lib, pkgs, ... }:

let
    unstable = import inputs.nixpkgs-unstable {
        system = pkgs.system;
        config.allowUnfree = true;
    };
    asyncProfilerFull = pkgs.callPackage ../apps/async-profiler.nix { };
    configDir = "${config.home.homeDirectory}/dotfiles/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
    imports = [ ./common.nix ];

    # Identity
    home.username = "mori";
    home.homeDirectory = "/home/mori";
    home.stateVersion = "25.05";

    # Mori-only packages
    home.packages = with pkgs; [
        # Typst
        unstable.tinymist unstable.typst
        (pkgs.google-fonts.override { fonts = [ "Inter" "Lato" "Roboto" ]; })

        # Development
        unstable.cargo unstable.rustc go lua typescript jdk sqlite pkg-config tailwindcss
        ant maven jetbrains.idea-oss unstable.claude-code bruno
        meson ninja cmake iconv udev android-tools mosh vegeta

        ## Python
        (python312.withPackages (ps: with ps; [
            python-dotenv packaging requests numpy
            matplotlib pandas pyyaml
        ]))

        # Containers & Infra
        unstable.fuse3 unstable.fuse3.dev docker docker-compose k6

        # Media
        gimp rmpc /* unstable.mdbook */

        # Communication
        slack zoom-us

        # Office & Productivity
        pandoc haskellPackages.pandoc-sidenote
        papers texliveFull

        # Custom & Unfree
        (callPackage ../apps/sourcetrail.nix { })
        asyncProfilerFull
    ];

    # Runs after the generated zsh setup, so compinit has already run when compdef is called
    programs.zsh.initContent = lib.mkAfter ''
        function tw() {
            local src="$1"
            if [ -z "$src" ]; then
                echo "Usage: tw <path/to/file.typ>"
                return 1
            fi

            # Strip leading src/ if present, replace extension
            local rel="''${src#src/}"
            local out="output/''${rel%.typ}.pdf"

            # Create output directory
            mkdir -p "$(dirname "$out")"

            local pkg_path="$HOME/.config/typst/packages"
            typst compile --package-path "$pkg_path" "$src" "$out" && zathura "$out" &
            typst watch --package-path "$pkg_path" "$src" "$out"
        }
        compdef '_files -g "*.typ"' tw

        bindkey -s '^k' 'rmpc\n'

        if [ -S "$SSH_AUTH_SOCK" ]; then
            if ! ssh-add -l | grep -q "ThePlatypus-Person"; then
                ssh-add ~/.ssh/github-t14-g2
            fi
        fi

        export GRB_LICENSE_FILE="$HOME/Scripts/gurobi.lic"
        export TYPST_FONT_PATHS="$HOME/.nix-profile/share/fonts"
    '';

    xdg.desktopEntries.sourcetrail = {
        name = "Sourcetrail";
        genericName = "Source Code Explorer";
        exec = "Sourcetrail";
        icon = "sourcetrail";
        terminal = false;
        categories = [ "Development" ];
    };
    # rmpc config. Merges with the shared xdg.configFile set in common.nix
    xdg.configFile.rmpc = {
        source = create_symlink "${configDir}/rmpc";
        recursive = true;
    };

    # mpd is only needed for rmpc, so it stays Mori only
    services.mpd = {
        enable = true;
        musicDirectory = "${config.home.homeDirectory}/Music";
        extraConfig = ''
            audio_output {
                type "pipewire"
                name "PipeWire"
            }
        '';
    };
    services.mpdris2.enable = true;

    home.file.".claude/config.json".text = builtins.toJSON {
        interpreter = {
            preamble = "Use caveman mode. Strip filler words. Save tokens.";
        };
    };

    home.sessionVariables = {
        PKG_CONFIG_PATH = "/etc/profiles/per-user/${config.home.username}/lib/pkgconfig";
        AP_LIB = "${asyncProfilerFull}/lib/libasyncProfiler.so";
    };
}
