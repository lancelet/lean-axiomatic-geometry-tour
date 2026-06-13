import VersoManual
import AxiomaticGeometry

open Verso.Genre Manual

/-- Custom CSS layered on top of the Manual theme (injected after it, so these
rules win without `!important`):

* a syntax-highlight palette for Lean code — the theme classifies tokens
  (`keyword`/`const`/`var`/`sort`/`literal`/`unknown`) but colours them all
  black, so we supply colours via the `--verso-code-*` variables and direct
  rules for the classes the theme doesn't back with a variable;
* a subtle code-block card (background, border, padding) plus the bottom margin
  the theme omits, so spacing around blocks is symmetric;
* light inline-code chips and slightly softened body text. -/
def extraCss : String := r#"
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap');

:root {
  --canva-purple: #6a21cc;   /* brand purple — every highlight (headings, links, bold) */
  --canva-purple-dark: #4a1791;   /* deeper purple — navigation (prev/next, title-page TOC) */
  --canva-ink:    #15171c;   /* near-black — reserved for the book title ONLY */
  --canva-body:   #2b2533;   /* body text: a deep plum-grey, tinted toward the brand */
  --canva-muted:  #6b7280;
  --canva-tint:   #f5f0fd;  /* code-block background — a touch lighter, lets syntax pop */
  --canva-line:   #e4daf7;  /* card borders + h2 underline */

  /* Fonts: Poppins (Canva-like) for headings and body, IBM Plex Mono for code.
     (Canva's own "Canva Sans" is proprietary and can't be embedded on the web;
     Poppins is the standard free stand-in.) */
  --verso-text-font-family:      "Poppins", system-ui, sans-serif;
  --verso-structure-font-family: "Poppins", sans-serif;
  --verso-code-font-family:      "IBM Plex Mono", ui-monospace, "SFMono-Regular", monospace;
  --verso-text-color:      var(--canva-body);
  --verso-structure-color: var(--canva-ink);
  --color-accent:          var(--canva-purple);

  /* Lean syntax palette (kept). */
  --verso-code-color:         #1f2328;
  --verso-code-keyword-color: #0e7490;  /* def, structure, where, theorem, by — cool teal */
  --verso-code-const-color:   #6a21cc;  /* defined names: Collinear, Meets … — brand purple */
  --verso-code-var-color:     #4a4458;  /* bound / section variables — deep plum-slate */
}

/* Absolute type scale (px). Each value is an independent knob. */
body {
  color: var(--canva-body);
  background: #ffffff;
  line-height: 1.7;
  font-size: 16px;
}

/* Heading hierarchy: every level is the brand purple, differentiated only by
   size/weight (h5/h6 become uppercase small-caps). The book title is the lone
   exception — see the .titlepage/.header-title/.toc-title override below. */
h1, h2, h3, h4, h5, h6 {
  font-family: "Poppins", sans-serif;
  line-height: 1.25;
  color: var(--canva-purple);   /* all headings share the (slightly darkened) brand purple */
}
h1 {
  font-weight: 700;
  font-size: 36px;
  line-height: 1.15;
}
/* The book title "Axiomatic Geometry" — shown on the cover (.titlepage) and
   repeated in the top bar (.header-title) and sidebar (.toc-title) on every
   page — is the ONLY black element; everything else is purple. */
.titlepage h1,
.header-title h1,
.toc-title h1 {
  color: var(--canva-ink);
}
h2 {
  font-weight: 700;
  font-size: 26px;
  border-bottom: 2px solid var(--canva-line);
  padding-bottom: 0.2em;
}
h3 {
  font-weight: 600;
  font-size: 20px;
}
h4 {
  font-weight: 600;
  font-size: 17px;
}
h5, h6 {
  font-weight: 600;
  font-size: 14px;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

a { color: var(--canva-purple); text-decoration-color: rgba(125, 42, 232, 0.4); }
strong { color: var(--canva-purple); }

/* Hide the full-text search box. Verso v4.30.0 emits the search assets into every
   page's <head> unconditionally (the `features` flag only gates asset generation,
   not these head references), so turning the feature off leaves dangling 404s.
   We keep the feature on and hide the JS-injected box (#search-wrapper) instead. */
#search-wrapper { display: none; }

/* Navigation accents → purple, like every other highlight. Covers the prev/next
   ("back"/"forward") buttons and the title-page table of contents. The left-hand
   sidebar TOC (everything under #toc) is intentionally left black. */
.prev-next-buttons a { color: var(--canva-purple-dark); }
main .section-toc a, main .section-toc a:visited { color: var(--canva-purple-dark); }

/* List items wrap their text in <p>, which inherits the paragraph bottom-margin
   and spreads bullets a full line apart. Drop that margin and give items just a
   small gap. */
li > p { margin: 0; }
li + li { margin-top: 0.25em; }

/* Lean syntax colours not backed by a variable. */
.hl.lean .sort    { color: #116329; }   /* Type, Prop */
.hl.lean .literal { color: #0550ae; }   /* numeric / string literals */
.hl.lean .unknown { color: #6e7781; }   /* punctuation and operators */

/* IBM Plex Mono for all code (blocks, inline, and hover tooltips). */
code, .hl.lean { font-family: var(--verso-code-font-family); }

/* Code blocks as soft, rounded Canva-style cards. */
.hl.lean.block {
  margin: 0 0 1.25em;
  background: var(--canva-tint);
  border: 2px solid var(--canva-line);
  border-radius: 12px;
  padding: 1em 1.2em;
  box-shadow: 0 2px 10px rgba(125, 42, 232, 0.06);
  overflow-x: auto;
  font-size: 14px;
}

/* Inline code chips in the brand tint. */
p code:not(.hl), li code:not(.hl) {
  background: #f3effe;
  color: #6420c9;
  border-radius: 6px;
  padding: 0.12em 0.4em;
  font-size: 14px;
}

/* Figures (compiled from TikZ to SVG) — centered and responsive. */
img { display: block; max-width: 100%; height: auto; margin: 0.5em auto 1.25em; }
"#

/-- Copy a file by reading and rewriting its bytes. -/
def copyFile (src dst : System.FilePath) : IO Unit := do
  IO.FS.writeBinFile dst (← IO.FS.readBinFile src)

/-- Try to compile one `figures/<stem>.tex` (standalone TikZ) to
`figOut/<stem>.svg` via `lualatex` (so figures can use the vendored fonts via
fontspec) → `dvisvgm --pdf`. Returns `true` only if the SVG was produced. A
missing tool (exception) or any non-zero exit yields `false`, so the caller can
fall back to a committed copy. Aux files go to a gitignored `.figbuild/`. -/
def compileFigure (texPath aux figOut : System.FilePath) (stem : String) : IO Bool := do
  try
    let latex ← IO.Process.output
      { cmd := "lualatex"
        args := #["-interaction=nonstopmode", "-halt-on-error",
                  "-output-directory=" ++ aux.toString, texPath.toString] }
    if latex.exitCode != 0 then
      IO.eprintln s!"[figures] lualatex failed for {stem}.tex:\n{latex.stdout}"
      return false
    let conv ← IO.Process.output
      { cmd := "dvisvgm"
        args := #["--pdf", "--font-format=woff2",
                  "--output=" ++ (figOut / (stem ++ ".svg")).toString,
                  (aux / (stem ++ ".pdf")).toString] }
    if conv.exitCode != 0 then
      IO.eprintln s!"[figures] dvisvgm failed for {stem}:\n{conv.stderr}"
      return false
    return true
  catch e =>
    IO.eprintln s!"[figures] LaTeX toolchain unavailable for {stem} ({e})"
    return false

/-- Put every `figures/*.tex` figure into `<outDir>/figures/*.svg`. Where the
LaTeX toolchain is present (the Nix dev shell) each figure is recompiled and the
committed copy under `figures/svg/` is refreshed; where it is absent or fails
(e.g. CI without a full TeX install) we fall back to that committed copy. So the
published figures keep working without a LaTeX toolchain in CI — the committed
SVGs are the source of truth there, regenerated locally whenever a `.tex`
changes. -/
def buildFigures (outDir : System.FilePath) : IO Unit := do
  let srcDir : System.FilePath := "figures"
  unless (← srcDir.pathExists) do return
  let figOut := outDir / "figures"
  let committedDir := srcDir / "svg"
  let aux : System.FilePath := ".figbuild"
  IO.FS.createDirAll figOut
  IO.FS.createDirAll aux
  for entry in (← srcDir.readDir) do
    if entry.path.extension != some "tex" then continue
    let stem := entry.path.fileStem.getD "figure"
    -- Underscore-prefixed files (e.g. `_preamble.tex`) are shared partials that
    -- other figures `\input`, not standalone documents — don't compile them.
    if stem.startsWith "_" then continue
    let outSvg := figOut / (stem ++ ".svg")
    let committed := committedDir / (stem ++ ".svg")
    if (← compileFigure entry.path aux figOut stem) then
      -- Keep the committed fallback in step with the fresh build.
      IO.FS.createDirAll committedDir
      try copyFile outSvg committed catch _ => pure ()
      IO.println s!"[figures] built figures/{stem}.svg"
    else if (← committed.pathExists) then
      copyFile committed outSvg
      IO.println s!"[figures] used committed figures/svg/{stem}.svg (no fresh build)"
    else
      IO.eprintln s!"[figures] {stem}: no fresh build and no committed SVG — it will be missing"

/-- Generate the multi-page site (into `_out/html-multi/`) and compile the TikZ
figures. Custom CSS is added the blessed way — an inline `<style>` in every
page's `<head>` via `config.extraHead`. `htmlDepth := 1` gives one page per `#`
chapter with deeper headings inline (no nested sub-pages). Figure paths need no
fixing: Verso emits a per-page relative `<base href>`, so plain `figures/…` URLs
resolve on every page and on GitHub Pages subpaths alike. -/
def main (args : List String) : IO UInt32 := do
  let styleTag : Verso.Output.Html := .tag "style" #[] (.text false extraCss)
  let rc ← manualMain (%doc AxiomaticGeometry)
    -- `features` stays at its default `.all` (KaTeX + search): in v4.30.0 the
    -- search asset <script>/<link> tags are emitted into every page's <head>
    -- unconditionally, so disabling the feature only yields dangling 404s. We
    -- keep the assets and hide the (extraneous) search box via CSS instead.
    (config := { extraHead := #[styleTag], htmlDepth := 1 })
    (options := args)
  if rc == 0 then
    buildFigures ("_out" / "html-multi")
  return rc
