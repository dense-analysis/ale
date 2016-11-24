" Author: poohzrn https://github.com/poohzrn
" Description: proselint for text

call ale#linter#Define('markdown', {
            \   'name': 'proselint',
            \   'executable': 'proselint',
            \   'command': g:ale#util#stdin_wrapper . ' .md proselint',
            \   'callback': 'ale#handlers#HandleProselintFormat',
            \})


" vim:set et sw=4 ts=4 tw=78:
