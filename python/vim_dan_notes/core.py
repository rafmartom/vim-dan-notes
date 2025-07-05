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
    return 

def salute_person(person):
    print(f'Saluting {person}')


def say_something_to_person(something, person):
    print(f'Saying {something} to {person}')
