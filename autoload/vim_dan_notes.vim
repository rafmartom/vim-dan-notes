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
from vim_dan_notes.core import parse_block_links_target
from vim_dan_notes.core import parse_inline_links_target
from vim_dan_notes.core import parse_labeled_inline_links_target
from vim_dan_notes.core import print_general_toc
from vim_dan_notes.core import parse_ext_list
from vim_dan_notes.core import print_main_header
from vim_dan_notes.core import print_new_article
from vim_dan_notes.core import print_article_toc


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
# @param start_line {lnum} line number where to start the search
# @param end_line {lnum} line number where to finnish the search
# Side effect: Updates the {@code output_parse_block_links_target} Variable.
# Example: :call vim_dan_notes#ParseBlockLinksTarget(20 , 80)
export def ParseBlockLinksTarget(start_line: number, end_line: number)
    var final_args = []
    final_args[0] = start_line
    final_args[1] = end_line

    var args_json = json_encode(final_args)
    execute 'py3 parse_block_links_target(' .. args_json .. ')'

enddef

##
# @param start_line {lnum} line number where to start the search
# @param end_line {lnum} line number where to finnish the search
# Side effect: Updates the {@code output_parse_labeled_inline_links_target} Variable.
# Example: :call vim_dan_notes#ParseInlineLinksTarget(20 , 80)
export def ParseInlineLinksTarget(start_line: number, end_line: number)
    var final_args = []
    final_args[0] = start_line
    final_args[1] = end_line

    var args_json = json_encode(final_args)
#    execute 'py3 parse_inline_links_target(' .. args_json .. ')'
    execute 'py3 parse_labeled_inline_links_target(' .. args_json .. ')'

enddef


##
# Side effect: Updates the {@code output_parse_ext_list} Variable.
export def ParseExtList()
    py3 parse_ext_list()
enddef


## Get the BUID of the Article for a given {lnum}
# @param {lnum} Line number
# @return list [BUID of the Article, {lnum} of <B=>]
# @throws OutOfDanBlock if no BUID is found
# Example: :echo vim_dan_notes#GetBuidLnum(1500)
export def GetBuidLnum(lnum: number): list<any>
    var current_lnum = lnum
    # Ensure the line number is valid
    if current_lnum < 1 || current_lnum > line('$')
        throw 'OutOfDanBlock: Invalid line number'
    endif

    # Search backward for the pattern ^<B=([[:alnum:]]\+)>.*$
    while current_lnum >= 1
        var line = getline(current_lnum)
        var match = matchlist(line, '^<B=\([[:alnum:]]\+\)>.*$')
        if !empty(match)
            return [match[1], current_lnum] # Return the BUID and line number
        endif
        current_lnum -= 1
    endwhile

    throw 'OutOfDanBlock: No OpenBlockTag <B=> found'
enddef


## Get the line number of the next closing Block Tag </B>
# @param {lnum} Line number
# @return {lnum} of the next </B>
# @throws OutOfDanBlock if no </B> is found
# Example: :echo vim_dan_notes#GetCloseBTagLnum(1500)
export def GetCloseBTagLnum(lnum: number): number
    var current_lnum = lnum
    # Ensure the line number is valid
    if current_lnum < 1 || current_lnum > line('$')
        throw 'OutOfDanBlock: Invalid line number'
    endif

    # Search forward for the pattern ^<\/B>
    while current_lnum >= 1
        var line = getline(current_lnum)
        var match = matchlist(line, '^<\/B>')
        if !empty(match)
            return current_lnum # Return the line number
        endif
        current_lnum += 1
    endwhile

    throw 'OutOfDanBlock: No CloseBlockTag </B> found'
enddef


## Get the line number of the next TOC Tag <T>
# @param {lnum} Line number
# @return {lnum} of the next <T>
# @throws OutOfDanBlock if no <T> is found
# Example: :echo vim_dan_notes#GetTocTagLnum(6981)
export def GetTocTagLnum(lnum: number): number
    var current_lnum = lnum
    # Ensure the line number is valid
    if current_lnum < 1 || current_lnum > line('$')
        throw 'OutOfDanBlock: Invalid line number'
    endif

    # Search forward for the pattern ^<TB>
    while current_lnum >= 1
        var line = getline(current_lnum)
        var match = matchlist(line, '^<T>')
        if !empty(match)
            return current_lnum # Return the line number
        endif
        current_lnum += 1
    endwhile

    throw 'OutOfDanBlock: No TOC Tag <T> found'
enddef
 


## Given a line number it will return the label of the Block Tag 
# @param {lnum} Line number
# @return label {sting} of the sourronding <B=>
# Example: :echo vim_dan_notes#GetBlockLabelFromLnum(800)
export def GetBlockLabelFromLnum(lnum: number): string

    # Parse All the Block Links Target for the Document
    ParseBlockLinksTarget(1, line('$'))
    
    var blocks: list<dict<any>> = g:output_parse_block_links_target
    var result: string = ''

    for block in blocks
        if block.line_no <= lnum
            result = block.label
        else
            break
        endif
    endfor

    return result

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

    # Parse All the Block Links Target for the Document
    ParseBlockLinksTarget(1, line('$'))

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

    # Parse All the Block Links Target for the Document
    ParseBlockLinksTarget(1, line('$'))
    final_args = [g:output_parse_block_links_target, label, wrap_columns > 0 ? wrap_columns : 105]

    var args_json: string = json_encode(final_args)

    execute 'py3 print_new_article(' .. args_json .. ')'

    append('$', g:output_print_new_article)
enddef




## Replace the Article TOC for the Article in which the lnum is located 
# @param {lnum} Line number
# Example: :call vim_dan_notes#ReplaceArticleTOC(6992)
export def ReplaceArticleTOC(lnum: number)
    
    ## Getting the Boundaries of the Article
    var buid_start_lnum = GetBuidLnum(lnum)
    var buid = buid_start_lnum[0]
    var start_lnum = buid_start_lnum[1]
    var close_lnum = GetCloseBTagLnum(lnum)

    ## Parsing all the Links Target for those Boundaries
    ParseInlineLinksTarget(start_lnum, close_lnum)


    var final_args = []
    final_args[0] = g:output_parse_labeled_inline_links_target
    final_args[1] = buid 
    # @todo this below can be just a pattern to that start_lnum , with the <B>
    # pattern to get the label rather than activating all of this subroutine
    final_args[2] = GetBlockLabelFromLnum(lnum)

    var args_json = json_encode(final_args)

    execute 'py3 print_article_toc(' .. args_json .. ')'


    # Find start line
    var start = start_lnum
    # Find end line
    var end = GetTocTagLnum(start_lnum)

    if start > 0 && end > 0 && end >= start
        # Delete from start to end inclusive
        silent! execute $':{start},{end}delete _'

        # Insert new lines after start - 1
        append(start - 1, g:output_print_article_toc)
    else
        echoerr 'Markers not found!'
    endif




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
