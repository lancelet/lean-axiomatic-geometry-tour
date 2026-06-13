# Axiomatic Geometry, in Lean

A literate [Lean 4](https://lean-lang.org/) formalization of axiomatic geometry,
following Eric Moorhouse's notes
[*Affine Planes: An Introduction to Axiomatic Geometry*](https://ericmoorhouse.org/handouts/affine_planes.pdf),
authored with [Verso](https://github.com/leanprover/verso) and published as a
multi-page static site.

Sources live under [`src/`](src): the book root
[`src/AxiomaticGeometry.lean`](src/AxiomaticGeometry.lean) includes one file per
chapter from [`src/AxiomaticGeometry/`](src/AxiomaticGeometry) (e.g.
`AffinePlanes.lean`); [`src/Main.lean`](src/Main.lean) is the site generator. The
Lean code in the chapters is **type-checked at build time**, so a broken proof
fails the build and the site is never published with it.

## Development environment (Nix)

Dependencies are declared in [`flake.nix`](flake.nix): `elan` (which installs the
Lean toolchain pinned by [`lean-toolchain`](lean-toolchain)), a C compiler
(`cc`, needed by Verso's `MD4Lean` dependency), `python3` (to preview the site),
and `git`.

The Nix-equivalent of a dotenv file is [`.envrc`](.envrc) (`use flake`). With
[direnv](https://direnv.net/) + [nix-direnv](https://github.com/nix-community/nix-direnv)
the dev shell loads automatically:

```sh
direnv allow      # one time, in this directory
```

Without direnv, enter the shell manually:

```sh
nix develop
```

### VSCode

Open the folder and install the recommended extensions (prompted automatically
from [`.vscode/extensions.json`](.vscode/extensions.json)):

- `leanprover.lean4` — the Lean 4 language server.
- `mkhl.direnv` — feeds the dev-shell environment (the `cc` and the elan
  toolchain) into the Lean server, so the editor builds the project the same way
  the terminal does.

After `direnv allow`, just open VSCode normally. (Alternatively, launch
`code .` from inside `nix develop` and the editor inherits the environment
without the direnv extension.)

## Build and preview locally

From inside the dev shell:

```sh
lake build              # compiles Verso + checks every proof
lake exe generate-site  # writes the multi-page site to _out/html-multi/
python3 -m http.server 8000 -d _out/html-multi
```

### Live preview

```sh
./watch.sh              # rebuilds on save + auto-reloads the browser (opens it)
```

`watch.sh` runs `lake exe generate-site` whenever a `.lean` or `figures/*.tex`
file changes and serves `_out/html-multi/` with live-reload (via `watchexec` +
`devd`, both from the dev shell), opening <http://localhost:8000>.
```

Then open <http://localhost:8000>. (A plain web server is needed rather than
`file://` so that in-page search and the KaTeX/tooltip assets load.)

> Not using the Nix shell? Any `cc` on `PATH` works. As a one-off you can borrow
> the compiler the toolchain already bundles: `lake env lake build`.

### Figures

Diagrams are standalone TikZ sources in [`figures/`](figures). `generate-site`
compiles each `figures/*.tex` to `_out/figures/*.svg` automatically (via
`latex` → `dvisvgm`; both come from the Nix dev shell). Embed one in the document
with `![alt text](figures/name.svg)`. To add a figure, drop a `.tex` in
`figures/` and reference its `.svg`.

## Publishing

Pushing to `main` builds and deploys the page to GitHub Pages via
[`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) (the `ubuntu`
runner already has `cc`, so it doesn't need Nix). Enable Pages → "GitHub
Actions" in the repository settings once.
