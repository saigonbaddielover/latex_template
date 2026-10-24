# LaTeX reports

One LaTeX template, multiple independent reports, one command-line build script. No editor integration or locally installed TeX distribution is required.

## Layout

```text
projects/
  example/main.tex       Tracked starter template
  <name>/main.tex        Private report source (not tracked)
scripts/report           Shared build command
```

## Usage

Requires Docker and Bash. From the repository root:

```bash
./scripts/report new my_report
./scripts/report build my_report
./scripts/report clean my_report
./scripts/report list
```

`new` copies the starter `main.tex` to a new, untracked project directory without overwriting existing work. Edit it in any editor. `build` runs XeLaTeX inside the `texlive/texlive:latest` Docker image and produces `projects/my_report/main.pdf`. Intermediate files stay in `projects/my_report/build/`. `clean` removes only those generated outputs.

To test the tracked example, run `./scripts/report build example`.

Each report is independent. Add figures, bibliography files, or split a larger document into additional `.tex` files using `\input{...}` as needed. All such files belong inside that project's directory.

Git tracks `projects/example/` and the shared tooling but ignores every other `projects/<name>/` directory, plus generated PDFs and build files. Back up private reports separately.
