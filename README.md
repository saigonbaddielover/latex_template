# Reusable LaTeX to PDF Template

This repository is a project-independent starting point for writing documents in LaTeX and exporting PDFs. The root template contains no university branding, dataset, or project-specific report content.

## Quick start

Requirements: Docker Engine, GNU Make, and Git (only when cloning). The first build downloads the TeX Live image, so it may be significantly slower than later builds.

1. Create a new directory from the template. Use GitHub's **Use this template** feature if enabled, or copy these files into your project: `main.tex`, `preamble.tex`, `sections/`, `Makefile`, `.vscode/settings.json`, and `.gitignore`.
2. Edit the title, author, and document structure in `main.tex`.
3. Write sections in `sections/`; change typography and packages in `preamble.tex`.
4. Build or clean from any shell in the project root:

   ```bash
   make pdf
   make clean
   ```

`make pdf` runs XeLaTeX through `latexmk` inside Docker. It writes intermediate files to `build/`, makes the compiled PDF available at `build/main.pdf`, and copies it to `main.pdf` at the project root. `make clean` removes those generated outputs.

The Docker image is `texlive/texlive:latest`. For byte-for-byte stable builds across time, replace that image reference in `Makefile` with a verified image digest and retain it in version control.

## Structure

```text
.
├── main.tex                  Entry point: document metadata and section order
├── preamble.tex              Shared packages, fonts, and page layout
├── sections/
│   ├── introduction.tex
│   ├── content.tex
│   └── conclusion.tex
├── Makefile                  Docker-based PDF build and cleanup
├── .vscode/settings.json     Optional LaTeX Workshop build recipe
├── example/                  Independent legacy examples
├── build/                    Generated auxiliary files (ignored)
└── main.pdf                  Generated output (ignored)
```

The default XeLaTeX setup uses a TeX Live font and accepts UTF-8, including Vietnamese. Add packages and language-specific typography in `preamble.tex` according to each project's needs.

## VS Code

Open the project directory in VS Code with the **LaTeX Workshop** extension installed. Use **Build LaTeX project**; the committed workspace recipe runs `make pdf`, including inside Remote-SSH sessions where Docker is available. The command-line build does not require VS Code.

## Adapting the template

- Add or remove section files, then update the corresponding `\input{...}` lines in `main.tex`.
- Put figures in a directory of your choice and reference them with `\includegraphics{...}`.
- Add citations, bibliography tools, custom classes, or mathematics packages only when the document requires them.
- Use a separate copy for each project; do not put unrelated reports into the template's root.

The `example/diabetes_report/` directory is preserved from the original repository for historical reference. It is **not** imported by the generic template and requires its own R tooling and dataset to rerun its analysis.
