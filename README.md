# jwt_tool Nix Flake

Nix flake for packaging and distributing [jwt_tool](https://github.com/ticarpi/jwt_tool) (v2.3.0) by [@ticarpi](https://github.com/ticarpi) on NixOS systems and Nix environments.

jwt_tool is a toolkit for validating, forging, scanning, and manipulating JSON Web Tokens (JWT).

## Requirements

- [Nix](https://nixos.org/download/) with flakes support enabled.

To enable flakes, make sure you have the following in your configuration:

```nix
# /etc/nixos/configuration.nix or ~/.config/nix/nix.conf
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

## Quick Start

### Run without installing

```bash
nix run github:soy-oreocato/jwt_tool_nix -- <JWT_TOKEN>
```

### Run from the local directory

```bash
nix run .#jwt_tool -- --help
```

### Decode a token

```bash
nix run .#jwt_tool -- eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpbiI6InRpY2FycGkifQ.aqNCvShlNT9jBFTPBpHDbt2gBB1MyHiisSDdp8SQvgw
```

### Enter a dev shell with jwt_tool available

```bash
nix develop .
jwt_tool --help
```

### Install to your user profile

```bash
nix profile install .#jwt_tool
```

## NixOS Integration

### As an input in your system flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jwt_tool.url = "github:soy-oreocato/jwt_tool_nix";
  };

  outputs = { nixpkgs, jwt_tool, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # change to your system (e.g. aarch64-linux, aarch64-darwin)
      modules = [
        ({ pkgs, system, ... }: {
          environment.systemPackages = [
            jwt_tool.packages.${system}.jwt_tool
          ];
        })
      ];
    };
  };
}
```

### Using the overlay

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jwt_tool.url = "github:soy-oreocato/jwt_tool_nix";
  };

  outputs = { nixpkgs, jwt_tool, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # change to your system (e.g. aarch64-linux, aarch64-darwin)
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ jwt_tool.overlays.default ];
          environment.systemPackages = [ pkgs.jwt_tool ];
        })
      ];
    };
  };
}
```

### With Home Manager

```nix
{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.jwt_tool.packages.${pkgs.system}.jwt_tool
  ];
}
```

## Flake Structure

| Output | Description |
|---|---|
| `packages.<system>.jwt_tool` | Main package |
| `packages.<system>.default` | Alias for `jwt_tool` |
| `apps.<system>.jwt_tool` | Executable application via `nix run` |
| `apps.<system>.default` | Alias for `jwt_tool` |
| `devShells.<system>.default` | Development shell with jwt_tool |
| `overlays.<system>.default` | Overlay for nixpkgs |

## Packaged Dependencies

The flake automatically resolves the following Python dependencies:

| Package | Purpose |
|---|---|
| `termcolor` | Colored terminal output |
| `pycryptodomex` | RSA/ECDSA/PSS signatures and verification |
| `requests` | Sending tokens to web applications |
| `ratelimit` | Rate limiting for attacks |

It also includes the project's data files:

- `jwt-common.txt` - Dictionary of common secrets
- `common-headers.txt` - Common headers for fuzzing
- `common-payloads.txt` - Common payloads for fuzzing
- `jwks-common.txt` - Common JWKS keys

## jwt_tool Usage Examples

```bash
# Decode a token
jwt_tool <TOKEN>

# Tamper with a token
jwt_tool <TOKEN> -T

# Exploit alg:none
jwt_tool <TOKEN> -X a

# Dictionary attack
jwt_tool <TOKEN> -C -d /path/to/wordlist.txt

# Playbook scan against a URL
jwt_tool -t https://target.com/ -rc "jwt=<TOKEN>" -M pb

# Verify signature with public key
jwt_tool <TOKEN> -V -pk public.pem
```

For complete jwt_tool documentation, consult the [official wiki](https://github.com/ticarpi/jwt_tool/wiki).

## Notes

- On first execution, jwt_tool generates a configuration file (`jwtconf.ini`) and an RSA/EC key pair in `~/.jwt_tool/`.
- The packaged version is **v2.3.0** (latest stable release).
- Supports all platforms that Nix supports via `flake-utils.eachDefaultSystem`.

## License

This flake distributes jwt_tool which is licensed under [GPL-3.0](https://github.com/ticarpi/jwt_tool/blob/master/LICENSE).
