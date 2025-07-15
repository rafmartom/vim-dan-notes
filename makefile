#.PHONY: all python/external/pyfiglet-latest.tar.gz python/external/pyfiglet python/external/rafpyutils clean
.PHONY: help all install uninstall clean fetch-deps build-deps clean-deps 

.DEFAULT_GOAL := all

help:
	@echo "Project Build Targets:"
	@echo "  all         - Compile the project"
	@echo "  install     - Install system-wide"
	@echo "  uninstall   - Remove installed files"
	@echo "  clean       - Remove build artifacts"
	@echo ""
	@echo "Dependency Management:"
	@echo "  fetch-deps  - Download dependencies"
	@echo "  build-deps  - Build dependencies"
	@echo "  clean-deps  - Remove dependency artifacts"
	@echo ""
	@echo "Miscellaneous:"
	@echo "  help        - Show this help"
	@echo ""


## ----------------------------------------------------------------------------
# @section PROJECT_TARGETS

all: build-deps
install:
	@echo "[install] No installation steps defined yet."

uninstall:
	@echo "py[uninstall] No uninstallation steps defined yet."
clean: clean-deps


## EOF EOF EOF PROJECT_TARGETS
## ----------------------------------------------------------------------------


## ----------------------------------------------------------------------------
# @section DEPENDENCY_MANAGEMENT

PYTHON_DEP := python/external
PYFIGLET_URL := $(shell curl -s https://api.github.com/repos/pwaller/pyfiglet/releases/latest | jq -r '.tarball_url')

fetch-deps: $(PYTHON_DEP)/pyfiglet/.stamp $(PYTHON_DEP)/rafpyutils/.stamp

$(PYTHON_DEP)/pyfiglet/.stamp:
	mkdir -p $(PYTHON_DEP)
	wget -O $(PYTHON_DEP)/pyfiglet-latest.tar.gz "$(PYFIGLET_URL)" || { echo "Failed to download pyfiglet tarball" >&2; exit 1; }
	tar -xf $(PYTHON_DEP)/pyfiglet-latest.tar.gz -C $(PYTHON_DEP)
	rm -f $(PYTHON_DEP)/pyfiglet-latest.tar.gz
	mv $(PYTHON_DEP)/pwaller-pyfiglet-* $(PYTHON_DEP)/pyfiglet
	touch $(PYTHON_DEP)/pyfiglet/.stamp

$(PYTHON_DEP)/rafpyutils/.stamp:
	mkdir -p $(PYTHON_DEP)
	if [ -d $(PYTHON_DEP)/rafpyutils/.git ]; then \
		cd $(PYTHON_DEP)/rafpyutils && git pull; \
	else \
		git clone https://github.com/rafmartom/rafpyutils $(PYTHON_DEP)/rafpyutils || { echo "Failed to clone rafpyutils" >&2; exit 1; }; \
	fi
	touch $(PYTHON_DEP)/rafpyutils/.stamp

build-deps: $(PYTHON_DEP)/pyfiglet/.stamp $(PYTHON_DEP)/rafpyutils/.stamp
#	$(MAKE) -C $(PYTHON_DEP)/pyfiglet full
	cd $(PYTHON_DEP)/pyfiglet && python3 setup.py sdist bdist_wheel || { echo "Failed to build pyfiglet distributions" >&2; exit 1; }
	cp $(PYTHON_DEP)/pyfiglet/pyfiglet/fonts-contrib/* $(PYTHON_DEP)/pyfiglet/pyfiglet/fonts/
	$(MAKE) -C $(PYTHON_DEP)/rafpyutils all

clean-deps:
	rm -rf python/external/pyfiglet
	rm -rf python/external/rafpyutils

## EOF EOF EOF DEPENDENCY_MANAGEMENT
## ----------------------------------------------------------------------------


## ----------------------------------------------------------------------------
# @section REPOSITORY_MANAGEMENT


## EOF EOF EOF REPOSITORY_MANAGEMENT
## ----------------------------------------------------------------------------
