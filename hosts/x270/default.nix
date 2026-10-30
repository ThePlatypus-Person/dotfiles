{ pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ];

    users.users.jun = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "audio" ];
        shell = pkgs.zsh;
        packages = with pkgs; [
            tree discord-ptb spotify
        ];
    };

    boot.resumeDevice = "/dev/disk/by-uuid/a2eeab42-1252-4234-bb82-8923067d28a3";
    # No Bluetooth on this machine
    boot.blacklistedKernelModules = [ "btusb" ];
    system.stateVersion = "26.05";
}
