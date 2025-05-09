# flake.nix
{
  description = "System-wide packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    xc = {
      url = "github:joerdav/xc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, xc }:
    let
      nixPkgsForSystem = system: import nixpkgs {
        inherit system;
        overlays = [
          (self: super: {
            # Add xc to nixpkgs.
            xc = xc.outputs.packages.${system}.xc;
          })
        ];
      };

      pythonDeps = pkgs: ps: [
        ps.python-lsp-server
        ps.pandas
        ps.numpy
      ];

      # Development tools used.
      devTools = pkgs: [
        # Use coreutils from Nix.
        pkgs.coreutils
        pkgs.bash
        # CA certificates to access HTTPS sites.
        pkgs.cacert
        pkgs.dockerTools.caCertificates
        # Docker tools.
        pkgs.crane
        pkgs.gh
        pkgs.git
        pkgs.xc
        (pkgs.python312.withPackages (pythonDeps pkgs))
        # Useful tools.
        pkgs.curl
        pkgs.htop
        pkgs.tree
        pkgs.vim
        pkgs.wget
        pkgs.git
        # Development tools.
        pkgs.code-server
      ];

      pkgsForSystem = system:
        let
          pkgs = nixPkgsForSystem system;
        in
        pkgs.buildEnv {
          name = "dev-env";
          paths = devTools pkgs;
        };
    in
    {
      packages.x86_64-linux.default = (pkgsForSystem "x86_64-linux");
      packages.aarch64-linux.default = (pkgsForSystem "aarch64-linux");
    };
}
