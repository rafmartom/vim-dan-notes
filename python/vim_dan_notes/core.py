"""
core.py
Author: rafmartom@gmail.com
Description: core functions of python/vim-dan-notes
"""
import vim
import re
import pyfiglet


## ----------------------------------------------------------------------------
# @section UTILS
# @description Encapsulated utilities called solely within the program

# @deprecated now using get_buffer_lines_from
def get_buffer_lines():
    """Return current buffer content as list of lines"""
    return vim.current.buffer[:]

def get_buffer_lines_from(start_line, end_line):
    """Return current buffer content as list of lines from start_line to end_line"""
    return vim.current.buffer[start_line - 1: end_line]


def parse_dan_codeblock(line):
    extension = re.search(r'(?<=```)\w+$', line)
    
    return 

def parse_dan_modeline(line):
    """
    Parse a DAN modeline string and extract the variable name and its value.

    A DAN modeline has the format:
    &@ g:dan_<varname> = "<value>" @&

    This function extracts <varname> and <value> and returns them in a list.

    Parameters:
        line (str): The modeline string to parse.

    Returns:
        list: A list containing [varname, value] if a match is found,
              otherwise an empty list.
    """
    modeline_varname_value = []
    match = re.search(r'^&@\sg:dan_([^\W0-9]\w*)\s=\s\"(.*?)\"\s@&$', line)

    if match:
        modeline_varname_value.append(match.group(1))
        modeline_varname_value.append(match.group(2))

    return modeline_varname_value

def get_next_buid(buid):
    """
    Given a DAN BUID (0-9, a-z, A-Z), returns the next BUID in sequence.
    Examples:
        'l5' -> 'l6'
        'la' -> 'lb'
        'lZ' -> 'm0'
        'ZZ' -> '000' (overflow, adds a digit)
    """
    # Define the alphanumeric characters in order
    alphanumeric = [str(d) for d in range(10)] + [chr(c) for c in range(ord('a'), ord('z')+1)] + [chr(C) for C in range(ord('A'), ord('Z')+1)]
    base = len(alphanumeric)
    char_to_value = {c: i for i, c in enumerate(alphanumeric)}

    # Convert BUID to decimal
    decimal = 0
    for char in buid:
        decimal = decimal * base + char_to_value[char]

    # Increment
    decimal += 1

    # Convert back to BUID
    if decimal == 0:
        return alphanumeric[0]

    next_buid = []
    while decimal > 0:
        decimal, remainder = divmod(decimal, base)
        next_buid.append(alphanumeric[remainder])

    return ''.join(reversed(next_buid))


def get_block_links_target(line, link_targets, line_no):
    tag_match = re.search(r'(?<=<B=)([0-9a-zA-Z]+)', line)
    if tag_match:
        label_match = re.search(r'(?<=>)([^<\n]+)', line)
        entry = {
            'label': label_match.group(1),
            'buid': tag_match.group(1),
            'iid': '',
            'line': line,
            'type': 'b',
            'line_no': line_no
        }
        link_targets.append(entry)


# @deprecated there is no current use to parse unlabeled inline links target
def get_inline_links_target(line, link_targets):
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


def get_labeled_inline_links_target(line, link_targets):
    match = re.search(r'(?<=<I=)([0-9a-zA-Z]+)#([0-9a-zA-Z]+)>(.*?)(?=</I>)', line)
    if match:
        entry = {
            'label': match.group(3) if match else '',
            'buid': match.group(1),
            'iid': match.group(2),
            'line': line,
            'type': 'i'
        }
        link_targets.append(entry)




## EOF EOF EOF UTILS 
## ----------------------------------------------------------------------------





## ----------------------------------------------------------------------------
## @section INTERNAL_ACTIONS
## @description Functions exposed to the User, not meant to be used directly 
## but triggered by the User_Actions


def parse_block_links_target(f_args): 
    start_line = f_args[0]
    end_line = f_args[1]

    links_target = []

    buffer_lines = get_buffer_lines_from(start_line, end_line)
    line_no = 1
    for line in buffer_lines:
        get_block_links_target(line, links_target, line_no)
        line_no = line_no + 1
    vim.vars["output_parse_block_links_target"] = links_target


# @deprecated there is no current use to parse unlabeled inline links target
def parse_inline_links_target(f_args): 
    start_line = f_args[0]
    end_line = f_args[1]

    links_target = []

    buffer_lines = get_buffer_lines_from(start_line, end_line)
    for line in buffer_lines:
        get_inline_links_target(line, links_target)
    vim.vars["output_parse_inline_links_target"] = links_target


def parse_labeled_inline_links_target(f_args): 
    start_line = f_args[0]
    end_line = f_args[1]

    links_target = []

    buffer_lines = get_buffer_lines_from(start_line, end_line)
    for line in buffer_lines:
        get_labeled_inline_links_target(line, links_target)
    vim.vars["output_parse_labeled_inline_links_target"] = links_target


def parse_ext_list(): 
    ext_list = []

    buffer_lines = get_buffer_lines()

    for line in buffer_lines:
        match = re.search(r'(?<=```)\w+$', line)
        if match:
            new_ext = match.group()
            if new_ext not in ext_list:
                ext_list.append(new_ext)


    vim.vars["output_parse_ext_list"] = ext_list



## EOF EOF EOF INTERNAL_ACTIONS 
## ----------------------------------------------------------------------------



## ----------------------------------------------------------------------------
## @section USER_ACTIONS
## @description Functions exposed to the User, meant to be used directly.


def print_general_toc(f_args):
    links_target = f_args[0] 
    output_list = []

    output_list.append(r"<B=0>Table of Contents TOC")

    # Get the ASCII art as a string with linebreaks
    pyfiglet_string = pyfiglet.figlet_format("TOC")

    # Split into lines and remove any trailing whitespace/linebreaks
    lines = [line.rstrip() for line in pyfiglet_string.split('\n')]
    lines.pop()

    # Append to your output list (assuming output_list exists)
    output_list.extend(lines)

    for link_target in links_target:
        if link_target['type'] == 'b':
            output_list.append(f"- <L={link_target['buid']}>{link_target['label']}</L>")
    
    output_list.append(r"</B><L=0>To TOC</L>")
    vim.vars["output_print_general_toc"] = output_list


def print_main_header(f_args):
    filename_noext = f_args[0] 
    ext_list = f_args[1] 
    output_list = []

    pyfiglet_string = pyfiglet.figlet_format("vim-dan" , font="univers")

    #pyfiglet_string = pyfiglet.figlet_format("vim-dan")

    # Split into lines and remove any trailing whitespace/linebreaks
    lines = [line.rstrip() for line in pyfiglet_string.split('\n')]
    lines.pop()
    lines.pop()

    # Append to your output list (assuming output_list exists)
    output_list.extend(lines)

    # Print ext list
    output_list.append(f'&@ The following lines are used by vim-dan, do not modify them! @&')

    output_str = ','
    output_str = output_str.join(ext_list)
    output_list.append(f'&@ g:dan_ext_list = "{output_str}" @&')


    # Parsing the dan keywords from the dan modeline

    ## Check if it already exists, parse the current varname_value for each line
    modeline_varname_value_list = []
    match = re.search(r'^&@ The following lines are used by vim-dan, do not modify them! @&$', vim.eval(f'getline(11)'))
    if match:
        for i in range(13, 26):
            modeline_varname_value_list.append(parse_dan_modeline(vim.eval(f'getline({i})')))
    ## Building the default modeline varname list
    else:
        default_varname = ['kw_question_list', 'kw_nontext_list','kw_linenr_list','kw_warningmsg_list','kw_colorcolumn_list','kw_underlined_list','kw_preproc_list','kw_comment_list','kw_identifier_list','kw_ignore_list','kw_statement_list','kw_cursorline_list','kw_tabline_list']
        j = 0 
        for i in range(13, 26):
            modeline_varname_value_list.append([ default_varname[j], ''])
            j = j + 1

    ## Writting the values to the list
    j = 0
    for i in range(13, 26):
        output_list.append(f'&@ g:dan_{modeline_varname_value_list[j][0]} = "{modeline_varname_value_list[j][1]}" @&')
        j = j + 1

    output_list.append(f'')

    pyfiglet_string = pyfiglet.figlet_format(filename_noext)

    # Split into lines and remove any trailing whitespace/linebreaks
    lines = [line.rstrip() for line in pyfiglet_string.split('\n')]
    lines.pop()

    # Append to your output list (assuming output_list exists)
    output_list.extend(lines)


    output_list.append(f'Vim-dan-notes documentation file:')


    match = re.search(r'^- Description :(.*?)$', vim.eval('getline(34)'))
    if match:
        output_list.append(f'- Description :{match.group(1)}')
    else:
        output_list.append(f'- Description :')

    match = re.search(r'^- Tags :(.*?)$', vim.eval('getline(35)'))
    if match:
        output_list.append(f'- Tags :{match.group(1)}')
    else:
        output_list.append(f'- Tags :')

    vim.vars["output_print_main_header"] = output_list



def print_new_article(f_args):
    links_target = f_args[0] 

    label = f_args[1]
    wrap_columns = int(f_args[2])

    output_list = []

    hr_line = '=' * wrap_columns

    buid = get_next_buid(links_target[-1]['buid'])

    output_list.append(hr_line)
    output_list.append(f"<B={buid}>{label}")

    # Get the ASCII art as a string with linebreaks
    pyfiglet_string = pyfiglet.figlet_format(label)

    # Split into lines and remove any trailing whitespace/linebreaks
    lines = [line.rstrip() for line in pyfiglet_string.split('\n')]
    lines.pop()

    # Append to your output list (assuming output_list exists)
    output_list.extend(lines)

    # Article TOC Tag
    output_list.append(f"<T>")

    output_list.append(f"")
    output_list.append(f"")

    output_list.append(f"</B><L=0>To TOC</L> | <L={buid}>Back to Article Top</L>")

    vim.vars["output_print_new_article"] = output_list




def print_article_toc(f_args):
    links_target = f_args[0] 
    buid = f_args[1] 
    label = f_args[2] 

    output_list = []


    output_list.append(f"<B={buid}>{label}")


    # Get the ASCII art as a string with linebreaks
    pyfiglet_string = pyfiglet.figlet_format(label)

    # Split into lines and remove any trailing whitespace/linebreaks
    lines = [line.rstrip() for line in pyfiglet_string.split('\n')]
    lines.pop()

    # Append to your output list (assuming output_list exists)
    output_list.extend(lines)

    output_list.append(f"")

    for link_target in links_target:
        if link_target['type'] == 'i':
            output_list.append(f"- <L={link_target['buid']}#{link_target['iid']}>{link_target['label']}</L>")

    # Article TOC Tag
    output_list.append(f"<T>")


    vim.vars["output_print_article_toc"] = output_list


## EOF EOF EOF USER_ACTIONS 
## ----------------------------------------------------------------------------
