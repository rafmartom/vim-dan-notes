.PHONY: all python/external/pyfiglet-latest.tar.gz python/external/pyfiglet python/external/rafpyutils clean

# Default target to build everything
all: python/external/pyfiglet python/external/rafpyutils

## pyfiglet
python/external/pyfiglet-latest.tar.gz:
	mkdir -p python/external
	curl -L -o $@ "$$(curl -s https://api.github.com/repos/pwaller/pyfiglet/releases/latest | jq -r '.tarball_url')" || { echo "Failed to download pyfiglet tarball" >&2; exit 1; }

python/external/pyfiglet: python/external/pyfiglet-latest.tar.gz
	mkdir -p python/external
	tar -xf python/external/pyfiglet-latest.tar.gz -C python/external/
	# Move extracted directory to python/external/pyfiglet
	mv python/external/pwaller-pyfiglet-* python/external/pyfiglet 2>/dev/null || true
	rm -f python/external/pyfiglet-latest.tar.gz
	# Build source and wheel distributions
	cd python/external/pyfiglet && python3 setup.py sdist bdist_wheel || { echo "Failed to build pyfiglet distributions" >&2; exit 1; }
	touch python/external/pyfiglet/.done

## rafpyutils
python/external/rafpyutils:
	mkdir -p python/external
	if [ ! -d python/external/rafpyutils ]; then git clone https://github.com/rafmartom/rafpyutils python/external/rafpyutils || { echo "Failed to clone rafpyutils" >&2; exit 1; }; fi
	touch python/external/rafpyutils/.done

clean:
	rm -rf python/external/pyfiglet
	rm -rf python/external/pyfiglet-latest.tar.gz
	rm -rf python/external/rafpyutils
