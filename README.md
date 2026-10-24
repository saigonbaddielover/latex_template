# LaTeX reports

Minimal LaTeX-to-PDF workspace: one example, any number of independent reports, and shared terminal commands. No editor extension or host TeX installation needed.

## First-time setup (Linux)

Install Git and Bash using your distribution's package manager, then clone the repository:

```bash
git clone https://github.com/saigonbaddielover/latex_template.git
cd latex_template
./scripts/setup
```

`setup` checks Docker Engine and downloads the `texlive/texlive:latest` image (about 9 GB) if necessary. If Docker is already working, it does not reinstall or reconfigure it. If Docker is missing, it offers to install Docker Engine using official package repositories on **Ubuntu, Debian, Fedora, or RHEL**. On other distributions, install Docker using the [official installation guide](https://docs.docker.com/engine/install/) and rerun `setup`.

Installing Docker requires `sudo` and confirmation. Running Docker without `sudo` may require joining the `docker` group, which **grants root-equivalent privileges**. The script asks before granting this access. After initial installation, run `newgrp docker` (or log out and back in) if prompted; on systems using systemd, Docker is started automatically. On shared machines, consider [rootless Docker](https://docs.docker.com/engine/security/rootless/) instead.

An existing Docker installation that is inaccessible or has an inactive daemon is not overwritten. Resolve existing package conflicts or daemon errors using the [Docker documentation](https://docs.docker.com/engine/install/linux-postinstall/).

## Work on a report

```bash
./scripts/report new my_report
./scripts/report build my_report
```

Edit `projects/my_report/main.tex` before building. The PDF appears at `projects/my_report/main.pdf`. Compilation intermediates stay inside `projects/my_report/build/`.

Other commands:

```bash
./scripts/report list
./scripts/report clean my_report
./scripts/report build example
```

## Layout

```text
projects/
  example/main.tex       Git-tracked starter
  <name>/main.tex        Private report (ignored by Git)
scripts/
  setup                  One-time Linux environment setup
  report                 Create, build, clean, list
```

`new` copies the example to a new project and refuses to overwrite existing work. Each project may add figures, bibliography, or more `.tex` files without affecting other reports.

Git tracks only `projects/example/` and shared tooling; all other project folders and generated PDFs are ignored. Back up private reports separately.
