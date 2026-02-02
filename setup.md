# Setup LaTeX with Docker

## 0) Mục tiêu

- VSCode LaTeX Workshop bấm **Build** chạy đúng `latexmk-docker` và xuất ra file `main.pdf`
- Build LaTeX bằng Docker image `texlive/texlive:latest`
- Copy `build/main.pdf` ra `./main.pdf`
- Output file rác vào `build/`

## 1) System packages (Ubuntu)

Cài đặt Docker và các công cụ hỗ trợ LaTeX cơ bản trên host:

```bash
sudo apt update

sudo apt install -y \
  docker.io docker-compose-plugin \
  texlive-extra-utils \
  perl \
  fontconfig \
  ttf-mscorefonts-installer

sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

**Lưu ý:** Logout/login lại (hoặc dùng `newgrp docker`) để dùng docker không cần sudo:

```bash
newgrp docker
docker version
```

## 2) Pull TeXLive docker image

```bash
docker pull texlive/texlive:latest
docker images | grep texlive
```

## 3) Cài wrapper `latexmk-docker` (global)

Tạo file `/usr/local/bin/latexmk-docker`:

```bash
sudo tee /usr/local/bin/latexmk-docker >/dev/null <<'SH'
#!/usr/bin/env bash
set -euo pipefail

IMAGE="${LATEX_DOCKER_IMAGE:-texlive/texlive:latest}"
OUTDIR="${LATEX_OUTDIR:-build}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage:
  latexmk-docker [latexmk options...] [file.tex]

Defaults:
  -outdir=build (override via -outdir=... or env LATEX_OUTDIR)
  Copies build/<file>.pdf to ./<file>.pdf after successful build.

Env:
  LATEX_DOCKER_IMAGE=...  (default: texlive/texlive:latest)
  LATEX_OUTDIR=...        (default: build)
USAGE
  exit 0
fi

args=("$@")

if (( ${#args[@]} == 0 )); then
  args=("main.tex")
else
  last="${args[-1]}"
  if [[ "$last" != -* && "$last" != *.tex ]]; then
    args[-1]="${last}.tex"
  fi
fi

cleanup=0
for a in "${args[@]}"; do
  case "$a" in
    -C|-c|-CA) cleanup=1 ;; 
  esac
done

has_outdir=0
for ((i=0;i<${#args[@]};i++)); do
  if [[ "${args[$i]}" == -outdir=* || "${args[$i]}" == "-outdir" ]]; then
    has_outdir=1
    break
  fi
done

docker_args=()
if (( has_outdir == 0 )); then
  docker_args+=("-outdir=$OUTDIR")
fi
docker_args+=("${args[@]}")

docker run --rm -i \
  -v "$(pwd)":/work -w /work \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v /usr/local/share/fonts:/usr/local/share/fonts:ro \
  -u "$(id -u):$(id -g)" \
  -e "HOME=/tmp" \
  "$IMAGE" \
  latexmk "${docker_args[@]}"

if (( cleanup == 0 )); then
  tex="${args[-1]}"
  base="${tex##*/}"
  base="${base%.tex}"
  if [[ -f "$OUTDIR/$base.pdf" ]]; then
    cp -f "$OUTDIR/$base.pdf" "./$base.pdf"
  fi
fi
SH
```

Cấp quyền thực thi:

```bash
sudo chmod +x /usr/local/bin/latexmk-docker
which latexmk-docker
latexmk-docker -h
```

## 4) Project-level build commands (root = main.tex)

Trong thư mục project:

```bash
mkdir -p build

# Build command
latexmk-docker -pdf -synctex=1 -interaction=nonstopmode -file-line-error main.tex
```

**Clean:**

```bash
latexmk-docker -C main.tex
rm -rf build
mkdir -p build
```

## 5) VSCode Remote-SSH: Extension + Workspace Settings

### 5.1 Cài extension (remote)

Cài **LaTeX Workshop** (`james-yu.latex-workshop`)

### 5.2 Thêm vào file `.vscode/settings.json`


Nội dung `.vscode/settings.json`:

```json
{
  "latex-workshop.latex.recipe.default": "latexmk-docker",
  "latex-workshop.latex.recipes": [
    {
      "name": "latexmk-docker",
      "tools": [
        "latexmk-docker-tool"
      ]
    }
  ],
  "latex-workshop.latex.tools": [
    {
      "name": "latexmk-docker-tool",
      "command": "latexmk-docker",
      "args": [
        "-pdf",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-file-line-error",
        "%DOCFILE%"
      ]
    }
  ],
  "latex-workshop.latex.autoBuild.run": "never",
  "latex-workshop.formatting.latex": "latexindent",
  "[latex]": {
    "editor.formatOnSave": true
  },
  "latex-workshop.latex.outDir": "build"
}
```

### 5.3 Trong VSCode

1. Mở folder project (Remote-SSH).
2. Mở `main.tex`.
3. Nhấn `Ctrl+Alt+B` (Build LaTeX project) hoặc click **Build** trong LaTeX Workshop sidebar.
4. **Result:** PDF output tại `build/main.pdf` và được copy ra `./main.pdf`.

## 6) Font Times New Roman (host)

Cài gói `msttcorefonts` (đã bao gồm ở bước 1). Verify:

```bash
fc-list | grep -i "Times New Roman" | head
```

> **Note:**
> - Nếu dùng `fontspec`, build engine phải là XeLaTeX hoặc LuaLaTeX. Recipe mặc định đang gọi `latexmk -pdf` (pdfLaTeX).
> - Nếu `main.tex` có `\usepackage{fontspec}` thì phải đổi lệnh build sang: `latexmk -xelatex` hoặc `-lualatex`.

## 7) Sanity Check

Chạy các lệnh sau để kiểm tra toàn bộ setup:

```bash
which docker
which latexmk-docker
docker images | grep texlive
latexmk-docker -pdf -synctex=1 -interaction=nonstopmode -file-line-error main.tex
ls -lh build/main.pdf main.pdf
```

## 8) Backup (Restore Guide)

Để restore nhanh sau sự cố, cần backup:

1.  `.vscode/settings.json` (workspace settings)
2.  `/usr/local/bin/latexmk-docker` (wrapper script)
3.  List packages đã cài:

```bash
dpkg -l | egrep 'texlive|latexmk|chktex|docker|latexindent|msttcorefonts' > _debug/restore_packages.txt
```
