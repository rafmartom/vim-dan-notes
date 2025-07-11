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

# Add rafpyutils submodule to sys.path
plugin_root = Path(vim.eval("g:vim_dan_notes#plugin_root"))
sys.path.insert(0, str(plugin_root / 'python' / 'external' / 'rafpyutils'))
sys.path.insert(0, str(plugin_root / 'python' / 'external' / 'pyfiglet'))

# Check if vim-dan plugin is loaded
try:
    vim_dan_loaded = vim.eval("exists('g:loaded_vim_dan')")
    if vim_dan_loaded != "1":
        vim.command("echoerr 'vim-dan-notes: Required plugin vim-dan is not loaded, check https://github.com/rafmartom/vim-dan'")
        raise RuntimeError("vim-dan plugin not loaded")
except vim.error:
    vim.command("echoerr 'vim-dan-notes: Error checking for vim-dan plugin'")
    raise

# Add plugin's python/ dir to PATH
plugin_root = Path(vim.eval("g:vim_dan_notes#plugin_root"))
sys.path.insert(0, str(plugin_root / 'python'))

from vim_dan_notes.core import refresh_main_toc
from vim_dan_notes.core import parse_links_target
from vim_dan_notes.core import print_general_toc
EOF
enddef

# Store plugin_root in a global variable
g:vim_dan_notes#plugin_root = plugin_root

export def RefreshMainTOC()
    py3 refresh_main_toc()
enddef

#export def ParseLinksTarget(): list<any>
export def ParseLinksTarget()
    py3 parse_links_target()
enddef


export def PrintGeneralTOC(...args: list<any>)
    var final_args = []

    # Ensure links are parsed
    if !exists('g:output_parse_links_target')
        ParseLinksTarget()
    endif

    final_args[0] = g:output_parse_links_target

    # Default arguments
    final_args[1] = empty(args) ? 105 : args[0]

    var args_json = json_encode(final_args)

    execute 'py3 print_general_toc(' .. args_json .. ')'
enddef
