" Author: Peter Edge <pedge@uber.com>
" Description: run the prototool linter

call ale#Set('proto_prototool_command', 'all')

function! ale_linters#proto#prototool#GetCommand(buffer) abort
    let l:command = ale#Var(a:buffer, 'proto_prototool_command')
    if l:command ==? 'all'
      " Compile the file, then do generation, then lint
      return 'prototool all --disable-format --dir-mode %s'
    elseif l:command ==? 'compile'
      " Compile the file only, doing no generation
      return 'prototool compile --dir-mode %s'
    elseif l:command ==? 'lint'
      " Compile the file and then lint, doing no generation
      return 'prototool lint --dir-mode %s'
    else
      " Sensible default, would be better if we could return error
      " Is there a way to return error?
      return 'prototool all --disable-format --dir-mode %s'
    endif
endfunction

call ale#linter#Define('proto', {
    \   'name': 'prototool',
    \   'lint_file': 1,
    \   'output_stream': 'stdout',
    \   'executable': 'prototool',
    \   'command_callback': 'ale_linters#proto#prototool#GetCommand',
    \   'callback': 'ale#handlers#unix#HandleAsError',
    \})

" TODO: not sure how to integrate the below properly, see PR description

function! PrototoolEnable() abort
    silent! let g:prototool_format_enable = 1
endfunction

function! PrototoolDisable() abort
    silent! unlet g:prototool_format_enable
endfunction

function! PrototoolFormatToggle() abort
    if exists('g:prototool_format_enable')
        call PrototoolDisable()
        execute 'echo "prototool format DISABLED"'
    else
        call PrototoolEnable()
        execute 'echo "prototool format ENABLED"'
    endif
endfunction

function! PrototoolFormat() abort
    if exists('g:prototool_format_enable')
        silent! execute '!prototool format -w %'
        silent! edit
    endif
endfunction

autocmd BufEnter,BufWritePost *.proto :call PrototoolFormat()

"nnoremap <silent> <leader>f :call PrototoolFormatToggle()<CR>
