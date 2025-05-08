{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    xc = {
      url = "github:joerdav/xc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, xc }:
    let
      allLinuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      allDarwinSystems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      allSystems = allLinuxSystems ++ allDarwinSystems;

      forSystems = systems: f: nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (self: super: {
                # Add xc to nixpkgs.
                xc = xc.outputs.packages.${system}.xc;
              })
            ];
          };
          # Set the Python version for all packages.
          python = pkgs.python312;
        in
        f {
          inherit system pkgs python;
        }
      );

      # Streamlit in nixpkgs was 1.40.1 when the latest version was 1.44.1.
      # To handle scenarios like this, we can override the src.
      overriddenStreamlit = { pkgs, sl }: sl.overridePythonAttrs (old: rec {
        version = "1.44.1";
        src = pkgs.fetchPypi {
          inherit version;
          pname = "streamlit";
          hash = "sha256-xpFO1tW3aHC0YVEEdoBts3DzZCWuDmZU0ifJiCiBmNM="; # Set this to "", and nix will error after the download, giving the hash.
        };
      });

      # If the package isn't in nixpkgs at all, then you'll have to package it.
      # See https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/development/python-modules/streamlit/default.nix
      # as an example.

      pythonDeps = pkgs: ps: [
        (overriddenStreamlit { inherit pkgs; sl = ps.streamlit; })
        ps.uvicorn
        ps.python-lsp-server
        ps.pandas
        ps.watchdog
      ];

      # Development tools used.
      devTools = pkgs: [
        pkgs.crane
        pkgs.gh
        pkgs.git
        pkgs.xc
      ];

      dockerUser = pkgs: pkgs.runCommand "user" { } ''
        mkdir -p $out/etc
        echo "coder:x:1000:1000:coder:/home/coder:/bin/false" > $out/etc/passwd
        echo "coder:x:1000:" > $out/etc/group
        echo "coder:!:1::::::" > $out/etc/shadow
      '';

      # Code image is based on https://github.com/coder/images/blob/main/images/base/ubuntu.Dockerfile
      dockerImage = { name, system, pkgs, python }: pkgs.dockerTools.buildImage {
        name = name;
        tag = "latest";
        fromImageName = "codercom/enterprise-base:ubuntu";

        copyToRoot = [
          # Remove coreutils and bash for a smaller container.
          pkgs.coreutils
          pkgs.bash
          # CA certificates to access HTTPS sites.
          pkgs.cacert
          pkgs.dockerTools.caCertificates
          # Nix
          pkgs.nix
          (dockerUser pkgs)
          (devTools pkgs)
          (python.withPackages (pythonDeps pkgs))
        ];
        config = {
          User = "coder:coder";
        };
      };

      name = "ghcr.io/a-h/coder-template";
    in
    {
      devShells = forSystems allSystems ({ system, pkgs, python, ... }: {
        default = pkgs.mkShell {
          packages =
            (devTools pkgs) ++
            [
              (python.withPackages (pythonDeps pkgs))
            ];
        };
      });
      packages = forSystems allLinuxSystems
        ({ system, pkgs, python, ... }: {
          docker-image = dockerImage {
            name = name;
            system = system;
            pkgs = pkgs;
            python = python;
          };
        });
    };
}

