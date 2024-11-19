# Taken from https://github.com/bcosynot/prodlog/
{
  description = "Hugo servidor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    # hugo-terminal = {
    #   url = "github:panr/hugo-theme-terminal";
    #   flake = false;
    # };
    hugo-cyberscape = {
      url = "github:isaksolheim/cyberscape";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    # hugo-terminal,
    hugo-cyberscape,
    ...
  }:
    utils.lib.eachDefaultSystem
    (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages.hugo-blog = pkgs.stdenv.mkDerivation rec {
        name = "hugo-servidor";
        src = self;
        configurePhase = ''
          mkdir -p "themes/cyberspace"
          cp -r ${hugo-cyberscape}/* "themes/cyberspace"
        '';
        buildPhase = ''
          ${pkgs.hugo}/bin/hugo --minify
        '';
        installPhase = "cp -r public $out";
      };

      packages.default = self.packages.${system}.hugo-blog;

      apps = rec {
        build = utils.lib.mkApp {drv = pkgs.hugo;};
        serve = utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "hugo-serve" ''
            ${pkgs.hugo}/bin/hugo server -D
          '';
        };
        newpost = utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "new-post" ''
            ${pkgs.hugo}/bin/hugo new content posts/"$1".org
          '';
        };
        default = serve;
      };

      devShells.default = pkgs.mkShell {
        buildInputs = [pkgs.hugo];
        shellHook = ''
          mkdir -p themes
          ln -sn "${hugo-cyberscape}" "themes/cyberscape"
        '';
      };
    });
}
