" Title:        vim-dan-notes
" Description:  Simple note taking plugin based on .dan files functionalities
" Created:  07 July 2025
" Maintainer:   Rafael Martinez Tomas <https://github.com/rafmartom>

" Allow user to disable and prevent duplicate loading
if exists("g:loaded_vim_dan_notes") || &cp
  finish
endif
let g:loaded_vim_dan_notes = 1

if !has('python3')
    echoerr "vim-dan-notes: Python3 support missing (needed for advanced features)"
    finish
endif


" Save and restore 'compatible' option
let s:save_cpo = &cpo
set cpo&vim

" Initialize Python on plugin load
call vim_dan_notes#InitPython()


" User Command
command! -nargs=0 DanRefreshMainTOC call vim_dan_notes#RefreshMainTOC()
command! -nargs=0 DanParseLinksTarget call vim_dan_notes#ParseLinksTarget()
command! -nargs=* DanPrintGeneralTOC call vim_dan_notes#PrintGeneralTOC(<f-args>)
command! -nargs=* DanReplaceGeneralTOC call vim_dan_notes#ReplaceGeneralTOC(<f-args>)
"command! -nargs=* DanCreateNewArticle call vim_dan_notes#CreateNewArticle(<f-args>)



" Restore 'compatible' option
let &cpo = s:save_cpo
unlet s:save_cpo

" vim:ts=2:sw=2:et:
