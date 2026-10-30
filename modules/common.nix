{ config, lib, pkgs, ... }:

{
    # Boot & System
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.networkmanager = {
	enable = true;
	dhcp = "internal";
    };

    time.timeZone = "Asia/Jakarta";

    # Allow betterlockscreen to verify password
    security.pam.services.i3lock.enable = true;

    # Graphics & Desktop
    services.displayManager.ly.enable = true;
    services.udisks2.enable = true;

    services.xserver = {
	enable = true;
	autoRepeatDelay = 200;
	autoRepeatInterval = 35;
	windowManager.qtile = {
	    enable = true;
	    extraPackages = python3Packages: with python3Packages; [
		qtile-extras
		psutil
	    ];
	};
    };

    services.picom = {
	enable = true;
	fade = true;
	fadeDelta = 5;
	vSync = true;
    };

    # The NixOS picom module always generates its own config from `settings` and
    # ignores any "configFile" key inside it — there's no built-in passthrough.
    # Since we manage picom.conf ourselves in dotfiles, point the unit at it directly.
    systemd.user.services.picom.serviceConfig.ExecStart = lib.mkForce
	"${lib.getExe config.services.picom.package} --config %h/dotfiles/config/picom/picom.conf";

    services.libinput = {
	enable = true;
	touchpad = {
	    naturalScrolling = true;
	    tapping = true;
	    disableWhileTyping = true;
	};
    };


    # Audio
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;
	jack.enable = true;
	extraConfig.pipewire."92-low-latency" = {
	    "context.properties" = {
		"default.clock.rate" = 48000;
		"default.clock.quantum" = 1024;
	    };
	};
    };

    # Global Vim Config
    programs.vim = {
	enable = true;
	defaultEditor = true;
    };

    environment.etc."vimrc".text = ''
	set number
	set relativenumber
	syntax on
	filetype plugin indent on
	set expandtab
	set shiftwidth = 4
	set softtabstop = 4
	set tabstop = 4
	set smartindent
	set showmatch
	set backspace=indent,eol,start
    '';

    environment.etc."NetworkManager/conf.d/no-scan-rand-mac.conf".text = ''
	[device]
	wifi.scan-rand-mac-address=no
    '';

    # Packages
    nixpkgs.config.allowUnfree = true;
    # Allow installation of unfree corefonts package
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "corefonts" ];
    programs.firefox.enable = true;
    environment.sessionVariables = {
	MOZ_USE_XINPUT2 = "1";
    };

    programs.ssh.startAgent = true;
    programs.zsh.enable = true;
    # New in 26.05: gcr-ssh-agent now defaults to enabled system-wide (previously
    # gated behind GNOME/MATE/Cinnamon/etc). It conflicts with programs.ssh.startAgent
    # since only one SSH agent can own the socket — we don't use GNOME Keyring, so disable it.
    services.gnome.gcr-ssh-agent.enable = false;

    environment.systemPackages = with pkgs; [
	vim
	wget
	kitty
	git
	chromium

	# Audio Controls
	pavucontrol
	pamixer
	easyeffects

	file
	gvfs
	unzip
	jmtpfs
    ];

    programs.chromium = {
	enable = true;
	homepageLocation = "https://www.startpage.com/";
	extensions = [
	    "aapbdbdomjkkjkaonfhkkikfgjllcleb;https://clients2.google.com/service/update2/crx" # google translate
	];
	extraOpts = {
	    "WebAppInstallForceList" = [
	    {
		"custom_name" = "Youtube";
		"create_desktop_shortcut" = false;
		"default_launch_container" = "window";
		"url" = "https://youtube.com";
	    }
	    ];
	};
    };

    fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
	nerd-fonts.symbols-only
	font-awesome_6
	corefonts
    ];


    # Nix Settings
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
