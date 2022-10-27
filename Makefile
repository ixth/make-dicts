#!/usr/bin/env make

DICT_URL="https://github.com/SebastianSzturo/Dictionary-Development-Kit/archive/refs/heads/master.zip"
DICT_BUILD_TOOL_DIR=devkit
DICT_PREBUILD_DIR=prebuild
VENV_DIR=env

dicts_url=https://www.dicts.info/uddl.php?format=xdxf&l1=$(word 1,$1)&l2=$(word 2,$1)

all: Serbian-English.dictionary
all: Serbian-Russian.dictionary
all: English-Serbian.dictionary
all: Russian-Serbian.dictionary

devkit.zip:
	curl -L $(DICT_URL) -o "$@"
	tar tf "$@" &> /dev/null

$(DICT_BUILD_TOOL_DIR)/bin: devkit.zip
	-mkdir -p "$(@D)"
	tar -C "$(@D)" -xf "$<" --strip-components 1

%.xdxf:
	curl -d 'ok=on' "$(call dicts_url,$(subst -, ,$*))" -o "$@"

$(VENV_DIR):
	python3 -m venv $(VENV_DIR)
	source $(VENV_DIR)/bin/activate && \
		pip3 install lxml beautifulsoup4 pyglossary

$(DICT_PREBUILD_DIR)/%: %.xdxf $(VENV_DIR)
	-mkdir -p "$(@D)"
	source $(VENV_DIR)/bin/activate && \
		pyglossary --write-format=AppleDict "$<" "$@"

%.dictionary: $(DICT_PREBUILD_DIR)/% $(DICT_BUILD_TOOL_DIR)/bin
	-mkdir -p "$(@D)"
	make -C "$<" \
		DICT_BUILD_TOOL_DIR=$(realpath $(DICT_BUILD_TOOL_DIR)) \
		all install

clean:
	-rm -f devkit.zip
	-rm -rf "$(DICT_BUILD_TOOL_DIR)"
	-rm -rf $(VENV_DIR)
	-rm -rf *.xdxf
	-rm -rf "$(DICT_PREBUILD_DIR)"
	-rm -rf build

.PHONY: clean

