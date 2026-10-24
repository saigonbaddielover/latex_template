# LaTeX reports

A minimal Linux LaTeX-to-PDF workspace with two reusable examples. Keep each real report in its own directory; Git tracks the examples and shared scripts, not personal projects.

## First-time setup

Install Git and Bash, then:

```bash
git clone https://github.com/saigonbaddielover/latex_template.git
cd latex_template
./scripts/setup
```

`setup` prepares Docker Engine (automatic installation supported on Ubuntu, Debian, Fedora and RHEL) and runs `scripts/test` to compile **both** examples end-to-end. Docker downloads the TeX Live image (approximately 9 GB) on first use. Installation and Docker group membership changes require confirmation and `sudo`; membership grants root-equivalent privileges. Run `newgrp docker` or log out and back in if prompted. Other distributions: [Docker installation instructions](https://docs.docker.com/engine/install/).

## Choose a starting point

| Example | Contents | Recommended use |
| --- | --- | --- |
| `projects/example/` | One self-contained `main.tex` | Notes and short reports |
| `projects/example-full/` | Main entry point, preamble, chapters, appendices, diagrams, tables and bibliography | Research papers, technical reports and long documents |

Create a project from either:

```bash
./scripts/new quick_notes
./scripts/new thesis example-full
```

`new` defaults to `example` and copies the chosen template without generated PDFs or build files. Project names must be unique. Each project keeps its own `main.tex` as the build entry point, even when the document spans hundreds of pages.

## Build and manage reports

```bash
./scripts/build quick_notes
./scripts/build thesis
./scripts/clean thesis
./scripts/list
./scripts/test
```

Edit `projects/<name>/main.tex` and supporting files in the same project directory. The final PDF is written to `projects/<name>/main.pdf`, with intermediates in `projects/<name>/build/`. The shared build script uses XeLaTeX and latexmk in Docker; no TeX installation or editor integration is needed on the host.

The long-form example demonstrates chapter organization (`\input`), a preamble, equations, cross-references, a TikZ diagram, a reusable table, BibTeX citations and an appendix. Replace all illustrative text and values before publishing. For large projects, add chapters, figures and source files without changing the build script.

## Layout and Git tracking

```text
projects/
  example/
    main.tex
  example-full/
    main.tex
    preamble.tex
    chapters/
    appendices/
    figures/
    tables/
    references.bib
  <name>/                 Private report directory, ignored by Git
scripts/
  setup                   Prepare Docker, run E2E tests
  new                     Create report using either example
  build                   Compile a report
  clean                   Remove generated outputs
  list                    List projects
  test                    Build and validate both examples
```

`.gitignore` tracks only `projects/example/`, `projects/example-full/` and the shared scripts; it ignores other project directories, PDFs and build artifacts. Back up private reports separately.
