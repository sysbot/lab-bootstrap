{
  description = "Lab bootstrap configs";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/release-24.05";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations = {
      bootstrap-host = nixpkgs.lib.nixosSystem {
        system  = "x86_64-linux";
        modules = [ ./hosts/bootstrap-host.nix ];
      };
      pi = nixpkgs.lib.nixosSystem {
        system  = "aarch64-linux";
        modules = [ ./hosts/pi.nix ];
      };
    };
  };
}
