{
  description = "Neovim configuration with Lua LSP";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            name = "nvim-config";
            packages = with pkgs; [
              # Lua LSP
              lua-language-server

              # Neovim for testing
              neovim

              # Additional useful tools
              stylua # Lua formatter
              selene # Lua linter
              ripgrep # For telescope
            ];

            shellHook = ''
              echo "📝 Neovim config development environment"
              echo "Available tools:"
              echo "  - lua-language-server (Lua LSP)"
              echo "  - nvim (Neovim)"
              echo "  - stylua (Lua formatter)"
              echo "  - selene (Lua linter)"
              echo "  - rg (ripgrep)"
            '';
          };

          # You can also add packages, apps, etc. here
        };
    };
}
