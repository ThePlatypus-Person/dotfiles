{ inputs, config, pkgs, ... }:

let
    nvimPin = import inputs.nvim-pin {
        system = pkgs.system;
    };
    configDir = "${config.home.homeDirectory}/dotfiles/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
    # Standard .config/directory
    configs = {
        dunst = "dunst";
        kitty = "kitty";
        nvim = "nvim";
        picom = "picom";
        qtile = "qtile";
        zathura = "zathura";
        rofi = "rofi";
        typst = "typst";
        "starship.toml" = "starship.toml";
        yazi = "yazi";
        tmux = "tmux";
        bookmarks = "bookmarks";
    };
in
{
    # Pin pre-26.05 defaults explicitly (stateVersion already keeps these,
    # this just silences the "legacy default" evaluation warnings)
    gtk.gtk4.theme = config.gtk.theme;

    # Packages
    home.packages = with pkgs; [
        # System & Desktop
        playerctl brightnessctl libnotify flameshot
        networkmanagerapplet arandr udiskie polkit_gnome
        blueman betterlockscreen dconf gtk-engine-murrine

        # Window Manager & X11
        rofi dunst feh picom cava nitrogen fastfetch
        thunar unclutter dmenu shotwell nsxiv

        # Terminal & Shell Tools
        htop btop tmux fd ripgrep fzf zoxide jq asciinema asciinema-agg

        # Yazi Dependencies
        ffmpegthumbnailer unar poppler

        # Neovim Dependencies
        nil nixpkgs-fmt nodejs gcc xsel

        # PDF viewer and fonts
        zathura zathuraPkgs.zathura_pdf_mupdf
        noto-fonts noto-fonts-cjk-sans liberation_ttf dejavu_fonts

        # Media
        obs-studio ffmpeg qbittorrent

        # Communication
        keepassxc

        # Office
        onlyoffice-desktopeditors

        # Custom
        obsidian
    ];

    # Shell & Terminal
    programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
            ll = "ls -alh";
            ".." = "cd ..";
            vim = "nvim";
            conf = "vim ~/dotfiles/modules/common.nix";
            home = "vim ~/dotfiles/home/common.nix";
            rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles";
            y = "yazi";
        };

        oh-my-zsh = {
            enable = true;
            plugins = [ "git" "sudo" "docker" ];
        };

        initContent = ''
            function yazi-launcher() {
                local tmp="$(mktemp -t "yazi-cwd-.XXXXXX")"

                # Launch yazi, tell it to write last dir to tmp
                yazi "$@" --cwd-file="$tmp"

                # If tmp file exists & not empty, cd to the directory in it
                if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                    cd -- "$cwd"
                fi

                rm -f -- "$tmp"
                zle reset-prompt
            }

            zle -N yazi-launcher
            bindkey '^o' yazi-launcher

            export PATH="/usr/local/bin:$PATH"
            export PATH="$HOME/.cargo/bin:$PATH"
            unset SSH_ASKPASS
            unset GIT_ASKPASS

            export PATH="/etc/profiles/per-user/${config.home.username}/bin:$PATH"
            export SSH_AUTH_SOCK="/run/user/$(id -u)/ssh-agent"
        '';
    };
    programs.starship.enable = true;

    # Editor
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        withRuby = false;
        withPython3 = true;
        sideloadInitLua = true;
        package = nvimPin.neovim-unwrapped;
    };

    # File Manager
    programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        shellWrapperName = "yy";
    };

    # Git
    programs.git = {
        enable = true;

        settings = {
            user = {
                name = "ThePlatypus-Person";
                email = "Ornithorhynchus0920@protonmail.com";
            };

            alias = {
                cm = "commit";
                st = "status";
                lg = "log --graph --oneline --all";
            };

            init.defaultBranch = "main";
            pull.rebase = true;
            credential.helper = "${
                pkgs.git.override { withLibsecret = true; }
            }/bin/git-credential-libsecret";
            push = { autoSetupRemote = true; };
        };
    };

    programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
            navigate = true;
            light = false;
            side-by-side = true;
        };
    };

    # Browser
    programs.librewolf = {
        enable = true;
        # Enable WebGL, cookies and history
        settings = {
            "webgl.disabled" = true;
            "privacy.resistFingerprinting" = true;
            "privacy.clearOnShutdown.history" = true;
            "privacy.clearOnShutdown.cookies" = true;
            "network.cookie.lifetimePolicy" = 0;
            "network.trr.uri" = "https://dns10.quad9.net/dns-query";
            "browser.toolbars.bookmarks.visibility" = "newtab";
            "ui.systemUsesDarkMode" = 1;
            "dom.w3c_touch_events.enabled" = 1;
        };
    };

    # Media
    programs.mpv = {
        enable = true;

        package = pkgs.mpv.override {
            scripts = with pkgs.mpvScripts; [
                uosc sponsorblock
            ];
        };

        config = {
            profile = "high-quality";
            ytdl-format = "bv*[height<720]+ba/b";
            cache-default = 4000000;
        };
    };

    # Services
    services.udiskie = {
        enable = true;
        settings = {
            program_options = {
                file_manager = "${pkgs.thunar}/bin/thunar";
            };
        };
    };

    # XDG & Dotfile Symlinks
    xdg.configFile = builtins.mapAttrs (name: subpath: {
        source = create_symlink "${configDir}/${subpath}";
        recursive = true;
    }) configs;

    # Theming
    gtk = {
        enable = true;
        font = {
            name = "JetBrains";
            size = 11;
        };
        theme = {
            name = "Tokyonight-Dark";
            package = pkgs.tokyonight-gtk-theme;
        };
        iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
        };
        cursorTheme = {
            name = "Capitaine Cursors (Gruvbox) - White";
            size = 32;
            package = pkgs.capitaine-cursors-themed;
        };
        gtk3 = {
            extraConfig.gtk-application-prefer-dark-theme = true;
        };
    };
    home.pointerCursor = {
        name = "Capitaine Cursors (Gruvbox) - White";
        size = 32;
        package = pkgs.capitaine-cursors-themed;
        gtk.enable = true;
        x11.enable = true;
    };
    home.sessionVariables = {
        QT_QPA_PLATFORMTHEME = "gtk3";
    };
    xresources.properties = {
        "Xft.dpi" = 110;
        "Xft.autohint" = 0;
        "Xft.lcdfilter" = "lcddefault";
        "Xft.hintstyle" = "hintfull";
        "Xft.hinting" = 1;
        "Xft.antialias" = 1;
        "Xft.rgba" = "rgb";
    };
}
