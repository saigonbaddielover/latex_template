# Multi-project LaTeX workspace

Write and export independent LaTeX reports from one workspace. The framework and examples are versioned; reports under `projects/` are private to the local checkout and are not tracked by Git.

## Layout

```text
latex_template/
├── example/
│   ├── basic/                Reusable minimal document
│   │   ├── main.tex
│   │   ├── preamble.tex
│   │   └── sections/
│   └── diabetes_report/      Original reference report
├── projects/                 Entirely gitignored except .gitkeep
│   ├── .gitkeep
│   └── <name>/
│       ├── main.tex
│       ├── preamble.tex
│       ├── sections/
│       ├── build/           Generated when building
│       └── main.pdf         Generated when building
├── scripts/report           Shared build and project CLI
├── tests/report-smoke.sh    Independent-project smoke tests
└── .vscode/tasks.json       Optional VS Code tasks
```

There is no root-level `main.tex` or project-specific PDF. Every report's source, assets, and build outputs stay inside its own directory.

## Requirements

- Docker Engine running and accessible to the current user.
- Bash, GNU coreutils, and Git.
- TeX Live is provided by the Docker image `texlive/texlive:latest`; the image is downloaded on first use.

## Commands

From the workspace root:

```bash
./scripts/report new research_notes
./scripts/report build research_notes
./scripts/report list
./scripts/report clean research_notes
./scripts/report build example/basic
```

These commands can also be called with an absolute script path from any working directory.

The `new` command copies only the files in `example/basic/`. It refuses to overwrite an existing project and restricts names to letters, numbers, dots, underscores, and dashes (starting with a letter or number). Edit `projects/research_notes/main.tex`, the associated `preamble.tex`, and its `sections/` as needed.

`build` mounts only the selected project into Docker and runs `latexmk` with XeLaTeX. LaTeX auxiliary files go to `<project>/build/`. The final PDF is copied to `<project>/main.pdf`. Builds do not run code in other projects. `clean` removes only the selected project's generated `build/` and `main.pdf`; it does not delete project source.

Add images, tables, code, data, and bibliographies under each project's own directory. Each project maintains its own `preamble.tex` and can customize layout without affecting others. The shared CLI only handles project creation and LaTeX compilation.

## Version control and examples

Only the CLI, template, VS Code tasks, tests, and examples belong in Git. `projects/` is ignored (including source, datasets, and PDFs); do not force-add private work. Back up local projects separately because pushing this repository does not protect them.

`example/basic/` is safe to use as a sample build target. `example/diabetes_report/` is retained as a reference for statistical reporting; its R dependencies and dataset are not part of the generic build workflow.
The CLI refuses to overwrite or clean Git-tracked example PDFs and build artifacts, preserving the original diabetes example.

## VS Code

Open the repository root in VS Code and use **Terminal → Run Task → Report: build** (or the default build task). Enter the project name, or `example/basic`. Additional tasks support creating, cleaning, and listing projects. The CLI works the same way over Remote-SSH.

## Verify

```bash
bash tests/report-smoke.sh
```

The test creates two disposable projects under `projects/`, builds them, checks their PDFs and isolation, cleans them, and removes only the test directories. It requires the Docker image and takes longer the first time.
