vim9script
# Author: rafmartom
# File with the vim functions exposed by vim-dan-notes
#
# Note: Most of the functionalities are written in python
#   But are launched in vim, they will be documented first where they show up
#   If functions are exposed via a command Example: would be refering that
#   Command
#   Functions passed to python dont have an explicit return statement, but set
#   a vim var instead , it will be documented as 
#   Side effect: Updates the {@code <varName>} Variable.

## ----------------------------------------------------------------------------
## @section PLUGIN_LAUNCHER
## @description All functionalities regarding to the plugin initiation,
## and code sourcing 


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


# Imports of all the python functions
from vim_dan_notes.core import parse_links_target
from vim_dan_notes.core import parse_block_links_target
from vim_dan_notes.core import parse_inline_links_target
from vim_dan_notes.core import print_general_toc
from vim_dan_notes.core import parse_ext_list
from vim_dan_notes.core import print_main_header
from vim_dan_notes.core import print_new_article

EOF
enddef

# Store plugin_root in a global variable
g:vim_dan_notes#plugin_root = plugin_root


## EOF EOF EOF PLUGIN_LAUNCHER 
## ----------------------------------------------------------------------------





## ----------------------------------------------------------------------------
## @section INTERNAL_ACTIONS
## @description Functions exposed to the User, not meant to be used directly 
## but triggered by the User_Actions


##
# Side effect: Updates the {@code output_parse_links_target} Variable.
# @deprecated For efficiency you either parse BlockLinks or InlineLinks
export def ParseLinksTarget()
    py3 parse_links_target()
enddef

##
# Side effect: Updates the {@code output_parse_block_links_target} Variable.
export def ParseBlockLinksTarget()
    py3 parse_block_links_target()
enddef

##
# Side effect: Updates the {@code output_parse_inline_links_target} Variable.
export def ParseInlineLinksTarget()
    py3 parse_inline_links_target()
enddef

##
# Side effect: Updates the {@code output_print_general_toc} Variable.
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

##
# Side effect: Updates the {@code output_parse_ext_list} Variable.
export def ParseExtList()
    py3 parse_ext_list()
enddef

## EOF EOF EOF INTERNAL_ACTIONS 
## ----------------------------------------------------------------------------





## ----------------------------------------------------------------------------
## @section USER_ACTIONS
## @description Functions exposed to the User, meant to be used directly.


## Replace the General TOC of the .dan file
#   In between <B=0> to </B=0> , updates all the Block Targets as Link Sources
# Example: :DanReplaceGeneralTOC
# @todo add parameter, wrap_columns
export def ReplaceGeneralTOC(...args: list<any>)
    var final_args = []

    ParseBlockLinksTarget()

    final_args[0] = g:output_parse_block_links_target
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


## Replace the Main Header of the .dan file
#  That is from line 0 to the TOC opening tag <B=0>
#  This includes all the dan modeline variables
# Example: :DanReplaceGeneralTOC
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

## Create the Title and Boundaries of a New Article
# @param label
# @param wrap_columns
# Example: :call vim_dan_notes#CreateNewArticle("My New Article" , 105)
# @todo Make a command :CreateNewArticle "My New Article" 105
# @todo Make wrap_columns an optional param
export def CreateNewArticle(label: string, wrap_columns: number)
    if empty(label)
        throw 'CreateNewArticle: Expected a non-empty label argument'
    endif

    var final_args: list<any> = []

    ParseBlockLinksTarget()
    final_args = [g:output_parse_block_links_target, label, wrap_columns > 0 ? wrap_columns : 105]

    var args_json: string = json_encode(final_args)

    execute 'py3 print_new_article(' .. args_json .. ')'

    append('$', g:output_print_new_article)
enddef


## EOF EOF EOF USER_ACTIONS 
## ----------------------------------------------------------------------------


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
