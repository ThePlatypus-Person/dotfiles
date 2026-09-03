{ inputs, config, pkgs, ... }:

let 
    unstable = import inputs.nixpkgs-unstable {
	system = pkgs.system;
	config.allowUnfree = true;
    };
    nvimPin = import inputs.nvim-pin {
	system = pkgs.system;
    };
    configDir = "${config.home.homeDirectory}/dotfiles/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
    asyncProfilerFull = pkgs.callPackage ./apps/async-profiler.nix { };
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
	/*"BetterDiscord/themes" = "BetterDiscord/themes";*/
	tmux = "tmux";
	bookmarks = "bookmarks";
    };
in
{
    # Identity
    home.username = "mori";
    home.homeDirectory = "/home/mori";
    home.stateVersion = "25.05";

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
	htop btop tmux fd ripgrep fzf zoxide jq

	# Yazi Dependencies
	ffmpegthumbnailer unar poppler

	# Neovim Dependencies
	nil nixpkgs-fmt nodejs gcc xsel

	# Typst
	unstable.tinymist unstable.typst zathura zathuraPkgs.zathura_pdf_mupdf
	noto-fonts noto-fonts-cjk-sans liberation_ttf dejavu_fonts
	(pkgs.google-fonts.override { fonts = [ "Inter" "Lato" "Roboto" ]; })

	# Development
	cargo rustc go lua typescript jdk sqlite pkg-config tailwindcss
	ant maven jetbrains.idea-oss unstable.claude-code bruno
	meson ninja cmake iconv udev android-tools mosh vegeta
    
	## Python
	(python312.withPackages (ps: with ps; [
	    python-dotenv packaging requests numpy
	    matplotlib pandas gurobipy pyyaml
	    # For Discord
	    discordpy
	]))

	# Containers & Infra
	unstable.fuse3 unstable.fuse3.dev docker docker-compose k6

	# Media
	obs-studio gimp spotify

	# Communication
	slack discord-ptb /*gajim*/ zoom-us keepassxc

	# Office & Productivity
	onlyoffice-desktopeditors pandoc haskellPackages.pandoc-sidenote 
	papers

	# Custom & Unfree
	gurobi
	obsidian
	(callPackage ./apps/sourcetrail.nix { })
	asyncProfilerFull
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
	    conf = "sudo vim /etc/nixos/configuration.nix";
	    home = "vim /etc/nixos/home.nix";
	    rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#t14-g2";
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

	    zle -N yazi-launcher
	    bindkey '^o' yazi-launcher

	    if [ -S "$SSH_AUTH_SOCK" ]; then
		if ! ssh-add -l | grep -q "ThePlatypus-Person"; then
		    ssh-add ~/.ssh/github-t14-g2
		fi
	    fi

	    export PATH="/usr/local/bin:$PATH"
	    export GRB_LICENSE_FILE="$HOME/Scripts/gurobi.lic"
	    unset SSH_ASKPASS
	    unset GIT_ASKPASS

	    export PATH="/etc/profiles/per-user/mori/bin:$PATH"
	    export SSH_AUTH_SOCK="/run/user/$(id -u)/ssh-agent"
	    export TYPST_FONT_PATHS="$HOME/.nix-profile/share/fonts"
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
	    ytdl-format="bv*[height<720]+ba/b";
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

    # XDG * Dotfile Symlinks
    xdg.configFile = builtins.mapAttrs (name: subpath: {
	source = create_symlink "${configDir}/${subpath}";
	recursive = true;
    }) configs;
    xdg.desktopEntries.sourcetrail = {
	name = "Sourcetrail";
	genericName = "Source Code Explorer";
	exec = "Sourcetrail";
	icon = "sourcetrail";
	terminal = false;
	categories = [ "Development" ];
    };
    home.file.".claude/config.json".text = builtins.toJSON {
	interpreter = {
	    preamble = "Use caveman mode. Strip filler words. Save tokens.";
	};
    };


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
	PKG_CONFIG_PATH = "/etc/profiles/per-user/mori/lib/pkgconfig";
	AP_LIB = "${asyncProfilerFull}/lib/libasyncProfiler.so";
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
