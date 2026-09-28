#!/usr/bin/env bash
set -euo pipefail

# TeX Live + the toolchain LazyVim's lang.tex extra expects: vimtex compiles with
# latexmk and views in zathura (vimtex_view_method = "zathura_simple"); texlab
# comes from Mason on first nvim start.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/run-as-root.sh"

run_as_root apt-get install -y \
    texlive-base texlive-latex-base texlive-latex-recommended texlive-latex-extra \
    texlive-fonts-recommended texlive-fonts-extra texlive-luatex texlive-xetex \
    texlive-pictures texlive-science texlive-plain-generic texlive-extra-utils \
    texlive-lang-greek biber latexmk chktex \
    zathura zathura-pdf-poppler

printf 'LaTeX toolchain installed.\n'
