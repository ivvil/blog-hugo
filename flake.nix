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
          cp -r ${hugo-cyberscape}/* "themes/cyberscape"
        '';
        buildPhase = ''
          ${pkgs.hugo}/bin/hugo --minify
          ${pkgs.tailwindcss}/bin/tailwindcss -i themes/cyberscape/assets/main.css -o themes/cyberscape/assets/style.css
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
          #   &
          #   ${pkgs.tailwindcss}/bin/tailwindcss -i themes/cyberscape/assets/main.css -o themes/cyberscape/assets/style.css --watch
          # '';
        };
        newpost = utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "new-post" ''
            ${pkgs.hugo}/bin/hugo new content posts/"$1".org
          '';
        };
        default = serve;
      };

      devShells.default = pkgs.mkShell {
        buildInputs = [pkgs.hugo pkgs.nodejs];
        shellHook = ''
          mkdir -p themes
          ln -sn "${hugo-cyberscape}" "themes/cyberscape"
        '';
      };
    });
}
