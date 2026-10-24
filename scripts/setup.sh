#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

fail() {
    printf 'setup: %s\n' "$1" >&2
    exit 1
}

confirm() {
    local reply
    [[ -r /dev/tty ]] || fail "interactive terminal required for system changes"
    read -r -p "$1 [y/N] " reply </dev/tty
    [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]
}

install_docker() {
    [[ -r /etc/os-release ]] || fail "cannot identify Linux distribution"
    . /etc/os-release
    local distro="${ID:-}"
    case "$distro" in
        ubuntu|debian)
            command -v apt-get >/dev/null || fail "apt-get not available"
            local codename="${VERSION_CODENAME:-}"
            if [[ "$distro" == ubuntu ]]; then
                codename="${UBUNTU_CODENAME:-$codename}"
            fi
            [[ -n "$codename" ]] || fail "Linux release codename unavailable"
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL "https://download.docker.com/linux/$distro/gpg" -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc
            sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/$distro
Suites: $codename
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io
            ;;
        fedora|rhel)
            command -v dnf >/dev/null || fail "dnf not available"
            sudo dnf -y install dnf-plugins-core
            if [[ "$distro" == fedora ]]; then
                sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
            else
                sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
            fi
            sudo dnf -y install docker-ce docker-ce-cli containerd.io
            ;;
        *)
            fail "automatic installation unsupported on $distro; see https://docs.docker.com/engine/install/"
            ;;
    esac
    sudo systemctl enable --now docker
}

[[ "$#" -eq 0 ]] || fail "usage: ./scripts/setup.sh"
[[ "$(id -u)" -ne 0 ]] || fail "run as your regular user, not root"

if docker info >/dev/null 2>&1; then
    printf 'Docker is ready.\n'
    "$ROOT/scripts/test.sh"
    printf 'Setup complete. Run ./scripts/new.sh my_report\n'
    exit 0
fi

command -v sudo >/dev/null 2>&1 || fail "sudo is required to configure Docker"

if ! command -v docker >/dev/null 2>&1; then
    printf 'Docker is not installed. Installation modifies system packages and requires sudo.\n'
    confirm 'Install Docker Engine from the official Docker repository?' || fail "installation cancelled"
    install_docker
else
    printf 'Docker is installed but not accessible in this shell.\n'
fi

sudo docker info >/dev/null 2>&1 || fail "Docker daemon unavailable; check sudo systemctl status docker"

if ! id -nG | tr ' ' '\n' | grep -qx docker; then
    if id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
        printf 'Docker group membership is not active in this shell.\n'
    else
        printf 'The docker group grants root-equivalent access to this machine.\n'
        confirm "Add $USER to the docker group?" || fail "group access required to run ./scripts/build.sh without sudo"
        sudo groupadd -f docker
        sudo usermod -aG docker "$USER"
    fi
fi

if docker info >/dev/null 2>&1; then
    "$ROOT/scripts/test.sh"
    printf 'Setup complete. Run ./scripts/new.sh my_report\n'
else
    sudo -u "$USER" -g docker "$ROOT/scripts/test.sh"
    printf 'Setup complete. Run: newgrp docker\nThen run: ./scripts/new.sh my_report\n'
fi
