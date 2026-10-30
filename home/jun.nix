{ inputs, lib, pkgs, ... }:

let
    unstable = import inputs.nixpkgs-unstable {
        system = pkgs.system;
        config.allowUnfree = true;
    };
in
{
    imports = [ ./common.nix ];

    # Identity
    home.username = "jun";
    home.homeDirectory = "/home/jun";
    home.stateVersion = "26.05";

    # Jun-only packages
    home.packages = with pkgs; [
	unstable.discord-ptb spotify

	prismlauncher
    ];

    # X270 panel is about 125 ppi and the T14 is about 158 ppi,
    # so T14 values are scaled by 125/158 to keep the same physical size
    xresources.properties."Xft.dpi" = lib.mkForce 87;
    home.pointerCursor.size = lib.mkForce 25;
    gtk.cursorTheme.size = lib.mkForce 25;

    programs.zsh.initContent = lib.mkAfter ''
        if [ -S "$SSH_AUTH_SOCK" ]; then
            if ! ssh-add -l | grep -q "ThePlatypus-Person"; then
                ssh-add ~/.ssh/github-x270
            fi
        fi
    '';
}
