ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
IMAGE := texlive/texlive:latest
LATEXMK_FLAGS := -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -outdir=build

.PHONY: pdf clean

pdf:
	@command -v docker >/dev/null 2>&1 || { printf '%s\n' 'Docker is required to run make pdf.' >&2; exit 1; }
	@mkdir -p "$(ROOT)/build"
	docker run --rm --user "$$(id -u):$$(id -g)" --mount "type=bind,source=$(ROOT),target=/work" --workdir /work --env HOME=/tmp "$(IMAGE)" latexmk $(LATEXMK_FLAGS) main.tex
	cp "$(ROOT)/build/main.pdf" "$(ROOT)/main.pdf"

clean:
	rm -rf "$(ROOT)/build" "$(ROOT)/main.pdf"
