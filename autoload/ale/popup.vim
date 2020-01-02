" Author: ian-howell <ian.howell0@gmail.com>
" Description: Popup windows for showing information.

" Open a popup window and show the string in it.
function! ale#popup#Show(string, ...) abort
    echo "Called popup show"
    if !g:ale_set_popups || !(exists('*popup_atcursor'))
        return
    endif

    call popup_atcursor(split(a:string, "\n"), {
          \    'padding': [0, 1, 0, 1],
          \    'borderchars': ['━','┃','━','┃','┏','┓','┛','┗'],
          \    'border': [1, 1, 1, 1],
          \    'moved':'any',
          \})

endfunction
