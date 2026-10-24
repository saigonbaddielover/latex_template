# LaTeX reports

Minimal LaTeX-to-PDF workspace for independent reports. The example and shared scripts are tracked; personal reports remain local.

## First-time setup on Linux

Install Git and Bash with your system package manager, then:

```bash
git clone https://github.com/saigonbaddielover/latex_template.git
cd latex_template
./scripts/setup
```

`setup` prepares Docker Engine (Ubuntu, Debian, Fedora, and RHEL supported) and runs `scripts/test`. The test compiles `projects/example/main.tex` into a PDF, verifies the output, and fails if compilation fails. Docker automatically downloads the approximately 9 GB TeX Live image on first build.

System installation and adding your account to the `docker` group require confirmation and `sudo`. **Docker group membership grants root-equivalent privileges.** If setup prompts you, run `newgrp docker` or log out and back in before running build commands. On other distributions, follow the [official Docker installation guide](https://docs.docker.com/engine/install/) and rerun setup. For shared machines, consider [rootless Docker](https://docs.docker.com/engine/security/rootless/).

## Daily use

```bash
./scripts/new my_report
./scripts/build my_report
./scripts/clean my_report
./scripts/list
```

Write your LaTeX in `projects/my_report/main.tex`. A successful build produces `projects/my_report/main.pdf` and intermediate files in `projects/my_report/build/`.

Scripts have one responsibility each:

| Script | Responsibility |
| --- | --- |
| `setup` | Set up Docker and run the end-to-end test |
| `new <name>` | Create a project from the example |
| `build <name>` | Compile one project to PDF |
| `clean <name>` | Remove one project's generated PDF and build directory |
| `list` | List local projects |
| `test` | Rebuild and validate the example PDF |

## Repository layout

```text
projects/
  example/main.tex      Git-tracked starter template
  <name>/main.tex       Private project, ignored by Git
scripts/
  setup
  new
  build
  clean
  list
  test
```

All report source files, figures, and exported PDFs belong inside their own project directory. You may add multiple `.tex` files using `\input{...}`; the shared build script does not need to change.

`projects/example/` and the shared tooling are tracked by Git; all other project directories and generated PDFs are ignored. Back up private projects separately.
