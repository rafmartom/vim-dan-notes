"""
core.py
Author: rafmartom@gmail.com
Description: core functions of python/vim-dan-notes
"""
import vim

def refresh_main_toc():
    """Rebuild the Table of Contents."""

    # Checking for vim_dan loaded
    vim.eval("exists('g:loaded_vim_dan')")

    # Checking if it is a dan file
    if vim.eval('&filetype') != 'dan':
        vim.command("echom 'Warning: You are not in a .dan file'")




    print('Refreshing TOC')
    return 
