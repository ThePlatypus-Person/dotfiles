{ config, lib, pkgs, ... }:

{
    imports =
	[
	./hardware-configuration.nix
	];

    # Boot & System
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "t14-g2";
    networking.networkmanager.enable = true;

    time.timeZone = "Asia/Jakarta";
    # Hibernation
    boot.resumeDevice = "/dev/disk/by-uuid/1bdc033c-a4e8-44f6-b4e4-b37af9739a91";
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
	settings.vsync = true;
	fade = true;
	fadeDelta = 5;
    };

    services.libinput = {
	enable = true;
	touchpad = {
	    naturalScrolling = true;
	    tapping = true;
	    disableWhileTyping = true;
	};
    };


    # Audio
    security.rtkit.enable = true;
    services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;
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
	set shiftwidth=4
	set softtabstop = 4
	set tabstop = 4
	set smartindent
	set showmatch
	set backspace=indent,eol,start
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
    environment.systemPackages = with pkgs; [
	vim
	wget
	kitty
	git
	chromium

	# Audio Controls
	pavucontrol
	pamixer

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
    ];

    fonts.fonts = with pkgs; [
	corefonts
    ];


    # User
    users.users.mori = {
	isNormalUser = true;
	extraGroups = [ "wheel" "networkmanager" ];
	shell = pkgs.zsh;
	packages = with pkgs; [
	    tree
	];
    };


    # Docker
    virtualisation.docker.enable = true;
    virtualisation.docker.rootless = {
	enable = true;
	setSocketVariable = true;
    };


    # Nix Settings
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "25.05";
}
