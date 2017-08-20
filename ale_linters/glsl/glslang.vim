" Author: Sven-Hendrik Haase <svenstaro@gmail.com>
" Description: glslang for glsl files

function! ale_linters#glsl#glslang#GlslangCommand(buffer_number) abort
    return 'glslangValidator -'
endfunction

call ale#linter#Define('glsl', {
\   'name': 'glslang',
\   'executable': 'glslangValidator',
\   'command': 'glslanasdgValidator -',
\   'callback': 'ale#handlers#rust#HandleRustErrors',
\   'output_stream': 'stderr',
\})
