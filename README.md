# Multi-project LaTeX workspace

Write independent LaTeX reports and export each to PDF using a shared Docker-based CLI. Only `projects/example/` and the shared workspace tooling are tracked in Git.

## Directory layout

```text
latex_template/
├── projects/
│   ├── example/             Git-tracked reusable reference project
│   │   ├── main.tex
│   │   ├── preamble.tex
│   │   └── sections/
│   ├── my_report/           Local project ignored by Git
│   │   ├── main.tex
│   │   ├── preamble.tex
│   │   ├── sections/
│   │   ├── build/           Generated auxiliary files
│   │   └── main.pdf         Generated PDF
│   └── .gitkeep
├── scripts/report           Shared project and PDF CLI
├── tests/report-smoke.sh    Independent-project smoke tests
├── .vscode/tasks.json       Optional VS Code tasks
└── .gitignore
```

All report source files, assets, generated files, and PDFs are contained within each `projects/<name>/` directory. No `main.tex`, PDF, or build directory is required at the repository root.

## Requirements

- Docker Engine accessible to the current user
- Bash and standard Linux tools

The image `texlive/texlive:latest` supplies XeLaTeX and latexmk. The first build downloads the image if missing.

## Commands

```bash
./scripts/report new my_report
./scripts/report build my_report
./scripts/report list
./scripts/report clean my_report
./scripts/report build example
```

The CLI finds its workspace root automatically, regardless of the terminal's current directory. Project names may contain letters, digits, dots, underscores, and hyphens, beginning with a letter or digit.

- `new` copies only the core `main.tex`, `preamble.tex`, and `sections/` files from `projects/example/`. It refuses to overwrite an existing directory.
- `build` mounts only the selected project in Docker and writes `build/main.pdf` and `main.pdf` under that project.
- `clean` removes only the selected project's generated `build/` and `main.pdf`.
- `list` lists the projects, including `example`.

Projects may customize their own preamble, content, figures, data, and bibliographies without affecting other reports.

## Git tracking

The root `.gitignore` ignores all `projects/` children except `projects/example/`:

```gitignore
/projects/*
!/projects/.gitkeep
!/projects/example/
```

Only the example's source files are committed; generated PDF and LaTeX auxiliary files are ignored as well. Other local project directories are excluded from `git status` and `git push`. Back up private projects separately and avoid forcibly adding them to Git.

## VS Code

Open the repository root and use **Terminal → Run Task → Report: build**, then enter `example` or another project name. Tasks are also available for creating, cleaning, and listing reports.

## Tests

```bash
bash tests/report-smoke.sh
```

The smoke test creates two disposable projects, checks builds and clean isolation, verifies Git ignore rules, and removes only its own temporary directories.
