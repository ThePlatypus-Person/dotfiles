{ lib, ... }:

{
    imports = [ ./common.nix ];

    # Identity
    home.username = "jun";
    home.homeDirectory = "/home/jun";
    home.stateVersion = "26.05";

    programs.zsh.initContent = lib.mkAfter ''
        if [ -S "$SSH_AUTH_SOCK" ]; then
            if ! ssh-add -l | grep -q "ThePlatypus-Person"; then
                ssh-add ~/.ssh/github-x270
            fi
        fi
    '';
}
