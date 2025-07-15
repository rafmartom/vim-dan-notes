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
from vim_dan_notes.core import parse_ext_list
from vim_dan_notes.core import print_main_header
from vim_dan_notes.core import print_new_article
EOF
enddef

# Store plugin_root in a global variable
g:vim_dan_notes#plugin_root = plugin_root

export def RefreshMainTOC()
    py3 refresh_main_toc()
enddef

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
    var args_json = json_encode(final_args)

    execute 'py3 print_general_toc(' .. args_json .. ')'
enddef


export def ReplaceGeneralTOC(...args: list<any>)

    var final_args = []

    # Ensure links are parsed
    if !exists('g:output_parse_links_target')
        ParseLinksTarget()
    endif

    final_args[0] = g:output_parse_links_target
    var args_json = json_encode(final_args)

    execute 'py3 print_general_toc(' .. args_json .. ')'


    # Find start line
    var start = search('^<B=0>.*', 'nw')
    # Find end line
    var end = search('^</B>.*', 'nw')

    if start > 0 && end > 0 && end >= start
        # Delete from start to end inclusive
        silent! execute $':{start},{end}delete _'

        # Insert new lines after start - 1
        append(start - 1, g:output_print_general_toc)
    else
        echoerr 'Markers not found!'
    endif


enddef

export def ParseExtList()
    py3 parse_ext_list()
enddef


export def ReplaceMainHeader(...args: list<any>)
    var final_args = []
    ParseExtList()


    # Getting filename with no extension
    final_args[0] = expand('%:t:r')


    final_args[1] = g:output_parse_ext_list

    var args_json = json_encode(final_args)

    execute 'py3 print_main_header(' .. args_json .. ')'

    # Find end line
    var end = search('^<B=0>.*', 'nw')
    end = end - 2

    if end > 0
        silent! execute $':0,{end}delete _'

        # Insert new lines after start - 1
        append(0, g:output_print_main_header)
    else
        echoerr 'Markers not found!'
    endif
enddef


# Call it like :call vim_dan_notes#CreateNewArticle("The new world" , 105)
export def CreateNewArticle(label: string, wrap_columns: number)
    if empty(label)
        throw 'CreateNewArticle: Expected a non-empty label argument'
    endif

    var final_args: list<any> = []

    ParseLinksTarget()
    final_args = [g:output_parse_links_target, label, wrap_columns > 0 ? wrap_columns : 105]

    var args_json: string = json_encode(final_args)

    execute 'py3 print_new_article(' .. args_json .. ')'

    append('$', g:output_print_new_article)
enddef


#export def CreateNewArticle(label: string, wrap_columns: number)
##export def CreateNewArticle(args: list<any>)
#
#    if len(args) < 1
#        throw 'CreateNewArticle: Expected at least 1 argument (label)'
#    endif
#
#    var final_args = []
#
#    ParseLinksTarget()
#     
#    final_args[0] = g:output_parse_links_target
#
##    final_args[1] = args[0]
#    final_args[1] = label
#
#    # Use the second argument as wrap_columns if provided, otherwise default to 105
##    final_args[2] = len(args) > 1 ? wrap_columns : 105
#
#    final_args[2] = a:wrap_columns > 0 ? a:wrap_columns : 105
#
#    # Default arguments
##    final_args[2] = empty(args) ? 105 : args[1]
#
#    var args_json = json_encode(final_args)
#
#    execute 'py3 print_new_article(' .. args_json .. ')'
#
#    append('$', g:output_print_new_article)
#
#enddef
