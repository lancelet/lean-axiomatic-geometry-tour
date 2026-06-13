{
  description = "Affine Planes — a literate Lean 4 / Verso formalization";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          # We intentionally do NOT put Lean/Lake here: the Lean version is
          # pinned by ./lean-toolchain and managed by elan, so the editor and
          # the CLI agree. Nix only supplies the surrounding tools.
          packages = [
            pkgs.elan      # installs/selects the toolchain named in ./lean-toolchain
            pkgs.gcc       # provides `cc`, which Verso's MD4Lean C dependency shells out to
            pkgs.python3   # for `python3 -m http.server` to preview the generated site
            pkgs.git       # flakes read files from the git tree

            # Live preview (./watch.sh): rebuild on change + auto-reload browser.
            pkgs.watchexec # re-runs generate-site when .lean/.tex change
            pkgs.devd      # static server with livereload + opens the browser

            # TikZ → SVG pipeline for figures. We use `lualatex` (+ fontspec) so
            # diagrams can be set in Poppins (matching the page), then
            # `dvisvgm --pdf`. The generator compiles figures/*.tex automatically.
            (pkgs.texliveSmall.withPackages (ps: with ps; [
              standalone pgf preview xcolor dvisvgm
              fontspec luatex85 unicode-math lualatex-math
            ]))
          ];

          # MD4Lean invokes a bare `cc`; export it explicitly too so any tool that
          # reads $CC (rather than searching PATH) also finds the compiler.
          shellHook = ''
            export CC="cc"
            echo "dev shell ready · lean $(lean --version 2>/dev/null | sed 's/.*version //;s/,.*//' || echo '?') · run: lake build && lake exe generate-site"
          '';
        };
      });
    };
}
