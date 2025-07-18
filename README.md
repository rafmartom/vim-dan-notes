# vim-dan-notes

Simple note taking plugin for vim, with syntax highlighting and placeholders allowing for quick navigation jumps between topics.
This plugin follows the syntax of the `.dan` filetype used on the the vim plugin [vim-dan](https://github.com/rafmartom/vim-dan), using the same structure but for your own notes.
Operate with big documents of notes easily thanks to the `.dan` link functionalities, that allows for an interactive `TOC` section at the beginninge document, you can then follow the links to each `topic` within the document.
Drop *link targets* in any part of the document, and recall them from any other part of the document with a *link source*.

## Installation

This plugin have some dependencies as `git submodules` so you need to use some equivalent to `git clone --recurse-submodules`, for the case of [vim-plug](https://github.com/junegunn/vim-plug)


```
Plug 'rafmartom/vim-dan-notes', { 'do': 'make' }
```

Or if just cloning or using a traditional one rule directive on the .vimrc 

```
Plug 'rafmartom/vim-dan-notes'
```

```
cd ~.vim/plugged/vim-dan-notes
make
```
