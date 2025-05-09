{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    xc = {
      url = "github:joerdav/xc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    version = {
      url = "github:a-h/version";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, xc, version }:
    let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (self: super: {
                xc = xc.outputs.packages.${system}.xc;
                version = version.outputs.packages.${system}.default;
              })
            ];
          };
        in
        f {
          inherit system pkgs;
        }
      );

      # Development tools used.
      devTools = pkgs: [
        pkgs.crane
        pkgs.gh
        pkgs.git
        pkgs.version
        pkgs.xc
      ];
    in
    {
      devShells = forAllSystems ({ system, pkgs, ... }: {
        default = pkgs.mkShell {
          packages = (devTools pkgs);
        };
      });
    };
}

