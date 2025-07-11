"""
core.py
Author: rafmartom@gmail.com
Description: core functions of python/vim-dan-notes
"""
import vim
import re
import pyfiglet
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

## ----------------------------------------------------------------------------
# @section HELPERS

def parse_block_links_target(line, link_targets):
    tag_match = re.search(r'(?<=<B=)([0-9a-zA-Z]+)', line)
    if tag_match:
        label_match = re.search(r'(?<=>)([^<\n]+)', line)
        entry = {
            'label': label_match.group(1),
            'buid': tag_match.group(1),
            'iid': '',
            'line': line,
            'type': 'b'
        }
        link_targets.append(entry)


def parse_inline_links_target(line, link_targets):
    tag_match = re.search(r'(?<=<I=)([0-9a-zA-Z]+)#([0-9a-zA-Z]+)', line)
    if tag_match:
        label_match = re.search(r'(?<=</I>)(.*?)(?=</I>)', line)
        entry = {
            'label': label_match.group(1) if label_match else '',
            'buid': tag_match.group(1),
            'iid': tag_match.group(2),
            'line': line,
            'type': 'i'
        }
        link_targets.append(entry)

def get_buffer_lines():
    """Return current buffer content as list of lines"""
    return vim.current.buffer[:]

## EOF EOF EOF HELPERS 
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
# @section SUBROUTINE_DECLARATIONS

def parse_links_target(): 
    links_target = []
    buffer_lines = get_buffer_lines()
    for line in buffer_lines:
        parse_block_links_target(line, links_target)
        parse_inline_links_target(line, links_target)
    vim.vars["output_parse_links_target"] = links_target


def print_general_toc(f_args):
    links_target = f_args[0] 
    wrap_columns = f_args[1]
    ####    print(f'Typeof links_target')
    ####    print(type(links_target))
    ####
    ####    for link_target in links_target:
    ####        print(f'Typeof link_target')
    ####        print(type(link_target))
    ####        print(link_target[0])
    ####        break
    output_list = []
    
    # Create the hr line
    hr_line = '=' * wrap_columns
    
    output_list.append(hr_line)
    output_list.append(r"<B=0>Table of Contents TOC")
    output_list.append(pyfiglet.figlet_format(r"TOC"))
    for link_target in links_target:
        if link_target['type'] == 'b':
            output_list.append(f"<B={link_target['buid']}>{link_target['label']}")
    
    output_list.append(r"</B><L=0>To TOC</L>")
    output_list.append(hr_line)
    vim.vars["output_print_general_toc"] = output_list

## EOF EOF EOF SUBROUTINE_DECLARATIONS 
## ----------------------------------------------------------------------------

