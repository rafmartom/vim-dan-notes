.PHONY: install

install:
	mkdir -p autoload/lh
	curl -L "https://raw.githubusercontent.com/LucHermitte/lh-vim-lib/master/autoload/lh/python.vim" -o "autoload/lh/python.vim"
