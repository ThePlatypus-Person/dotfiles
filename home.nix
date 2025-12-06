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
	};
    };
    programs.starship.enable = true;
    programs.zsh = {
	enable = true;
	enableCompletion = true;
	autosuggestion.enable = true;
	syntaxHighlighting.enable = true;

	shellAliases = {
	    ll = "ls -al";
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

	rofi
	dunst
	feh
	picom
	cava
	nitrogen
	pfetch
	xfce.thunar
	(python3.withPackages(ps: with ps; [
			      psutil
			      requests
			      dbus-python
	]))
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

	zathura
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
}
