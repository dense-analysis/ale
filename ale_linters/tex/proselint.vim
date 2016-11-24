" Author: poohzrn https://github.com/poohzrn
" Description: proselint for tex

call ale#linter#Define('tex', {
            \   'name': 'proselint',
            \   'executable': 'proselint',
            \   'command': g:ale#util#stdin_wrapper . ' .tex proselint',
            \   'callback': 'ale#handlers#HandleProselintFormat',
            \})


" vim:set et sw=4 ts=4 tw=78:
