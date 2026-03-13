{
  description = "jwt_tool - A toolkit for testing, tweaking and cracking JSON Web Tokens";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        python = pkgs.python3.withPackages (ps: with ps; [
          termcolor
          pycryptodomex
          requests
          ratelimit
        ]);

        jwt_tool = pkgs.stdenv.mkDerivation rec {
          pname = "jwt-tool";
          version = "2.3.0";

          src = pkgs.fetchFromGitHub {
            owner = "ticarpi";
            repo = "jwt_tool";
            rev = "v${version}";
            sha256 = "sha256-hro7Big55b26BW3hyr8pE7f8vq/ley+M4Yiuk9SJObg=";
          };

          nativeBuildInputs = [ pkgs.makeWrapper ];

          dontBuild = true;

          installPhase = ''
            runHook preInstall

            # Install the main script and data files
            mkdir -p $out/share/jwt_tool
            cp jwt_tool.py $out/share/jwt_tool/
            cp jwt-common.txt $out/share/jwt_tool/
            cp common-headers.txt $out/share/jwt_tool/
            cp common-payloads.txt $out/share/jwt_tool/
            cp jwks-common.txt $out/share/jwt_tool/

            # Create the launcher script
            mkdir -p $out/bin
            makeWrapper ${python}/bin/python3 $out/bin/jwt_tool \
              --add-flags "$out/share/jwt_tool/jwt_tool.py" \
              --run 'export JWT_TOOL_DATA_DIR="'"$out"'/share/jwt_tool"'

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "A toolkit for testing, tweaking and cracking JSON Web Tokens";
            homepage = "https://github.com/ticarpi/jwt_tool";
            license = licenses.gpl3Only;
            maintainers = [ ];
            mainProgram = "jwt_tool";
            platforms = platforms.all;
          };
        };

      in {
        packages = {
          jwt_tool = jwt_tool;
          default = jwt_tool;
        };

        apps = {
          jwt_tool = flake-utils.lib.mkApp { drv = jwt_tool; name = "jwt_tool"; };
          default = flake-utils.lib.mkApp { drv = jwt_tool; name = "jwt_tool"; };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ jwt_tool ];
        };

        overlays.default = final: prev: {
          jwt_tool = jwt_tool;
        };
      }
    );
}
