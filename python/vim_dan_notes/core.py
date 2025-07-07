"""
core.py
Author: rafmartom@gmail.com
Description: core functions of python/vim-dan-notes
"""
import vim
import rafpyutils

def refresh_main_toc():
    """Rebuild the Table of Contents."""

    # Checking for vim_dan loaded
    vim.eval("exists('g:loaded_vim_dan')")

    # Checking if it is a dan file
    if vim.eval('&filetype') != 'dan':
        vim.command("echom 'Warning: You are not in a .dan file'")




    print('Refreshing TOC')
    rafpyutils.insert_sublist_between_markers(input_list, input_sublist, start_pattern, end_pattern)
    return 

def pass_args_from_vim_to_py(f_args):
    print(f'This is arg 0 {f_args[0]}, This is arg 1 {f_args[1]},This is arg 2 {f_args[2]}')
