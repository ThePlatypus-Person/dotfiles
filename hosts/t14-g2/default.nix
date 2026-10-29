{ config, lib, pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ];

    # Hibernation
    boot.resumeDevice = "/dev/disk/by-uuid/1bdc033c-a4e8-44f6-b4e4-b37af9739a91";

    networking.hosts = {
        "127.0.0.1" = [ "restkv.xdnapp.com" ];
    };

    security.sudo.extraRules = [
        {
            users = [ "mori" ];
            commands = [
                {
                    command = "/run/current-system/sw/bin/chmod";
                    options = [ "NOPASSWD" ];
                }
                {
                    command = "/home/mori/Work/xdn-pb-test/fuselogv2";
                    options = [ "NOPASSWD" "SETENV" ];
                }
                {
                    command = "/run/wrappers/bin/fusermount3";
                    options = [ "NOPASSWD" ];
                }
            ];
        }
    ];

    # Enable Dynamic Linking
    programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
            fuse3
        ];
    };
    environment.etc."fuse.conf".text = ''
        # Managed by NixOS
        user_allow_other
    '';

    # User
    users.users.mori = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "docker" "audio" "adbusers" ];
        shell = pkgs.zsh;
        packages = with pkgs; [
            tree
        ];
    };

    # Docker
    virtualisation.docker = {
        enable = true;
        daemon.settings = {
            userland-proxy = false;
        };
    };

    system.stateVersion = "25.05";
}
