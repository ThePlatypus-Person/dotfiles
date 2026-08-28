{
    description = "Mori's Personal NixOS Configuration";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-26.05";
        home-manager = {
            url = "github:nix-community/home-manager/release-26.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
	nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
	# Pinned to the last neovim-unwrapped release before the markdown/conceal_lines
	# treesitter crash introduced in 0.12.0 (still open upstream as of Jul 2026,
	# see neovim/neovim#39032). Remove this once that's fixed.
	nvim-pin.url = "github:NixOS/nixpkgs/832efc09b4caf6b4569fbf9dc01bec3082a00611";
    };

    outputs = { self, nixpkgs, home-manager, ... }@inputs: {
        nixosConfigurations.t14-g2 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./configuration.nix
                    home-manager.nixosModules.home-manager
                    {
                        home-manager = {
                            useGlobalPkgs = true;
                            useUserPackages = true;
			    extraSpecialArgs = { inherit inputs; };
                            users.mori = import ./home.nix;
                            backupFileExtension = "backup";
                        };
                    }
            ];
        };
    };
}
