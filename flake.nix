{
  description = "Nix development shell for graphmath-native";
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs }:
    let
      version = builtins.substring 0 8 self.lastModifiedDate;
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      pname = "test-exs";
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          inherit (pkgs.lib) optional optionals;
        in
        with pkgs;
        {
          default = mkShell {
            buildInputs = [
              elixir_1_16
              elixir_ls
              glibcLocales
            ] ++ optional stdenv.isLinux inotify-tools
            ++ optional stdenv.isDarwin terminal-notifier
            ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
              CoreFoundation
              CoreServices
            ]);
          };
        });
    };
}
