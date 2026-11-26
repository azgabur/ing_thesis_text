# Builds thesis.pdf inside the official TeX Live container image, so no local
# TeX installation is needed. Intermediate files are kept in $(BUILD_DIR).

IMAGE     ?= docker.io/texlive/texlive:latest
ENGINE    ?= $(shell command -v podman >/dev/null 2>&1 && echo podman || echo docker)
BUILD_DIR ?= build

# Rootless podman maps the container's root user to the invoking user, so the
# generated files are owned by the user. Docker needs the user set explicitly.
ifeq ($(notdir $(ENGINE)),docker)
USER_ARGS := --user $(shell id -u):$(shell id -g) -e HOME=/tmp
endif

SOURCES := thesis.tex thesis-terms-abbrs.tex thesis.bib latexmkrc fithesis4.cls \
           $(shell find fithesis -type f) $(wildcard markdown.*)

.PHONY: all clean

all: thesis.pdf

thesis.pdf: $(SOURCES)
	$(ENGINE) run --rm $(USER_ARGS) -v "$(CURDIR)":/thesis:z -w /thesis $(IMAGE) \
		latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=$(BUILD_DIR) thesis.tex
	cp $(BUILD_DIR)/thesis.pdf $@

clean:
	rm -rf $(BUILD_DIR) thesis.pdf
