vim9script
# Author: rafmartom
# File with some functions to use on vim-dan-notes

# Get plugin root directory at script level
const plugin_root: string = expand('<sfile>:p:h:h')

# Initialize Python module
export def InitPython()
    py3 << EOF
import sys
import vim
from pathlib import Path

# Use plugin_root from Vim script
plugin_root = Path(vim.eval("g:vim_dan_notes#plugin_root"))
sys.path.insert(0, str(plugin_root / 'python'))

from vim_dan_notes.core import refresh_main_toc
EOF
enddef

# Store plugin_root in a global variable
g:vim_dan_notes#plugin_root = plugin_root

export def RefreshMainTOC()
    py3 refresh_main_toc()
enddef
