# LaTeX reports

One LaTeX template, multiple independent reports, one command-line build script. No editor integration or locally installed TeX distribution is required.

## First-time setup on Linux

Requirements: Git, Bash, Docker Engine, internet access for the first image download, and sufficient disk space for the TeX Live image (approximately 9 GB).

### 1. Install Git and Docker Engine

For **Ubuntu**, these commands install Git, Bash, and Docker Engine from Docker's official APT repository on a supported Ubuntu release:

```bash
sudo apt update
sudo apt install -y git bash ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

If Docker or containerd is already installed, review the [Ubuntu installation prerequisites](https://docs.docker.com/engine/install/ubuntu/) for conflicting packages before running the installation commands. Do not uninstall an existing Docker installation just for this template.

On other Linux distributions, install Git and Bash with your package manager and follow the official Docker Engine guide for your system: [Debian](https://docs.docker.com/engine/install/debian/), [Fedora](https://docs.docker.com/engine/install/fedora/), [RHEL](https://docs.docker.com/engine/install/rhel/), or [other platforms](https://docs.docker.com/engine/install/). Start the Docker daemon according to your distribution's instructions.

### 2. Allow Docker commands without `sudo`

The build script invokes `docker` as your regular user. For a trusted personal Linux machine, the standard Docker group setup is:

```bash
sudo groupadd -f docker
sudo usermod -aG docker "$USER"
newgrp docker
docker info
```

The group change takes effect in the new shell opened by `newgrp`, or after fully logging out and back in (including reconnecting over SSH). **Membership in the `docker` group grants root-level privileges.** On shared or security-sensitive machines, consider [Docker rootless mode](https://docs.docker.com/engine/security/rootless/) instead. See the [official Linux post-install guide](https://docs.docker.com/engine/install/linux-postinstall/) for details.

Verify that Docker is running and accessible **without `sudo`**:

```bash
docker run --rm hello-world
```

If you see `Cannot connect to the Docker daemon`, check that the Docker service is running (on systemd systems: `sudo systemctl start docker`). If you see permission denied for the Docker socket, reconnect your shell so the new group membership takes effect.

### 3. Clone the repository and build

```bash
git clone https://github.com/saigonbaddielover/latex_template.git
cd latex_template
./scripts/report new my_report
./scripts/report build my_report
```

Edit `projects/my_report/main.tex` in any editor before or after the initial build. The PDF is written to `projects/my_report/main.pdf`; intermediate compilation files stay in `projects/my_report/build/`.

Docker automatically downloads `texlive/texlive:latest` the first time it is needed. The image is large, so the first build can take considerably longer than later builds. To download it separately first, run `docker pull texlive/texlive:latest`.

## Layout

```text
projects/
  example/main.tex       Git-tracked starter template
  <name>/main.tex        Private report source (not tracked)
scripts/report           Shared build command
```

## Commands

```bash
./scripts/report new my_report
./scripts/report build my_report
./scripts/report clean my_report
./scripts/report list
./scripts/report build example
```

`new` copies the starter `main.tex` into a new project without overwriting existing work. `build` compiles with XeLaTeX inside Docker. `clean` removes only the selected project's generated PDF and build directory. The script works from any current directory when invoked using its path.

Each report is independent. Add figures, bibliography files, or split a longer document into additional `.tex` files with `\input{...}` as needed. Keep these files within their own project directory.

Git tracks `projects/example/` and the shared tooling but ignores every other `projects/<name>/` directory, plus generated PDFs and build files. Back up private reports separately.
