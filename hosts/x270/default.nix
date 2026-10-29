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

    system.stateVersion = "26.05";
}
