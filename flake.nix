{
  description = "Smarter Tailnet peer availability checker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.tailnet-ping = pkgs.stdenv.mkDerivation {
          name = "tailnet-ping";
          src = ./.;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildPhase = "true";
          installPhase = ''
            mkdir -p $out/bin
            cp tailnet-ping.sh $out/bin/tailnet-ping
            chmod +x $out/bin/tailnet-ping
            wrapProgram $out/bin/tailnet-ping \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.jq pkgs.tailscale pkgs.iputils ]}
          '';
        };

        apps.tailnet-ping = {
          type = "app";
          program = "${self.packages.${system}.tailnet-ping}/bin/tailnet-ping";
        };
      });
}
