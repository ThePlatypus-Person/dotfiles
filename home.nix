{ config, pkgs, ... }:

let 
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
	"starship.toml" = "starship.toml";
	yazi = "yazi";
	"BetterDiscord/themes" = "BetterDiscord/themes";
	tmux = "tmux";
	bookmarks = "bookmarks";
    };
in
{
    home.username = "mori";
    home.homeDirectory = "/home/mori";
    home.stateVersion = "25.05";

    programs.git = {
	enable = true;
	userName = "ThePlatypus-Person";
	userEmail = "Ornithorhynchus0920@protonmail.com";

	delta = {
	    enable = true;
	    options = {
		navigate = true;
		light = false;
		side-by-side = true;
	    };
	};

	aliases = {
	    cm = "commit";
	    st = "status";
	    lg = "log --graph --oneline --all";
	};

	extraConfig = {
	    init.defaultBranch = "main";
	    pull.rebase = true;
	    credential.helper = "${
		pkgs.git.override { withLibsecret = true; }
	    }/bin/git-credential-libsecret";
	    push = { autoSetupRemote = true; };
	};
    };
    programs.starship.enable = true;
    programs.zsh = {
	enable = true;
	enableCompletion = true;
	autosuggestion.enable = true;
	syntaxHighlighting.enable = true;

	shellAliases = {
	    ll = "ls -alh";
	    ".." = "cd ..";
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

	    zle -N yazi-launcher
	    bindkey '^o' yazi-launcher
	'';
    };

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

    home.packages = with pkgs; [
	playerctl
	brightnessctl
	libnotify
	flameshot
	networkmanagerapplet
	arandr
	udiskie
	polkit_gnome
	blueman
	htop
	btop

	rofi
	dunst
	feh
	picom
	cava
	nitrogen
	pfetch
	xfce.thunar
	unclutter
	dmenu
	nsxiv

	betterlockscreen
	dconf
	gtk-engine-murrine

	# Yazi
	ffmpegthumbnailer
	unar
	jq
	poppler
	fd
	ripgrep
	fzf
	zoxide

	# Neovim
	ripgrep
	cargo
	rustc
	nil
	nixpkgs-fmt
	nodejs
	gcc
	xsel

	zathura
	zathuraPkgs.zathura_pdf_mupdf

	slack
	discord-ptb
	keepassxc
	zoom-us
	typst
	bruno
	tmux
	onlyoffice-desktopeditors
	(callPackage ./apps/sourcetrail.nix { })

	openjdk21
	jetbrains.idea-community
	sqlite

	# For XDN
	(python312.withPackages (ps: with ps; [
				 python-dotenv
				 packaging
	]))

	fuse3
	docker_28
	docker-compose
	pkg-config

	go

	ant
	#openjdk21
	#rustc
	#cargo
    ];


    programs.neovim = {
	enable = true;
	defaultEditor = true;
    };

    programs.yazi = {
	enable = true;
	enableZshIntegration = true;
	enableBashIntegration = true;
    };

    services.udiskie = {
	enable = true;
	settings = {
	    program_options = {
		file_manager = "${pkgs.xfce.thunar}/bin/thunar";
	    };
	};
    };

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


    home.pointerCursor = {
	name = "Capitaine Cursors (Gruvbox) - White";
	size = 32;
	package = pkgs.capitaine-cursors-themed;
	gtk.enable = true;
	x11.enable = true;
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


    programs.mpv = {
	enable = true;

	package = (
	    pkgs.mpv-unwrapped.wrapper {
		scripts = with pkgs.mpvScripts; [
		    uosc
		    sponsorblock
		];

		mpv = pkgs.mpv-unwrapped.override {
		    waylandSupport = true;
		};
	    }
	);

	config = {
	    profile = "high-quality";
	    ytdl-format="bv*[height<720]+ba/b";
	    cache-default = 4000000;
	};
    };
}
