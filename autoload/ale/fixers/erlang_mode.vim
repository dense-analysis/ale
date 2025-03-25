" Author: Dmitri Vereshchagin <dmitri.vereshchagin@gmail.com>
" Description: Indent with the Erlang mode for Emacs

call ale#Set('erlang_erlang_mode_emacs_executable', 'emacs')
call ale#Set('erlang_erlang_mode_indent_level', 4)
call ale#Set('erlang_erlang_mode_icr_indent', 'nil')
call ale#Set('erlang_erlang_mode_indent_guard', 2)
call ale#Set('erlang_erlang_mode_argument_indent', 2)
call ale#Set('erlang_erlang_mode_indent_tabs_mode', 'nil')

let s:variables = {
\   'erlang-indent-level': 'erlang_erlang_mode_indent_level',
\   'erlang-icr-indent': 'erlang_erlang_mode_icr_indent',
\   'erlang-indent-guard': 'erlang_erlang_mode_indent_guard',
\   'erlang-argument-indent': 'erlang_erlang_mode_argument_indent',
\   'indent-tabs-mode': 'erlang_erlang_mode_indent_tabs_mode',
\}

function! ale#fixers#erlang_mode#Fix(buffer) abort
    let l:emacs_executable =
    \   ale#Var(a:buffer, 'erlang_erlang_mode_emacs_executable')

    let l:exprs = [
    \   '(setq enable-local-variables :safe)',
    \   s:SetqDefault(a:buffer, s:variables),
    \   '(erlang-mode)',
    \   '(font-lock-fontify-region (point-min) (point-max))',
    \   '(indent-region (point-min) (point-max))',
    \   '(funcall (if indent-tabs-mode ''tabify ''untabify)'
    \         . ' (point-min) (point-max))',
    \   '(save-buffer 0)',
    \]

    let l:command = ale#Escape(l:emacs_executable)
    \   . ' --batch'
    \   . ' --find-file=%t'
    \   . join(map(l:exprs, '" --eval=" . ale#Escape(v:val)'), '')

    return {'command': l:command, 'read_temporary_file': 1}
endfunction

function! s:SetqDefault(buffer, variables) abort
    let l:args = []

    for [l:emacs_name, l:ale_name] in items(a:variables)
        let l:args += [l:emacs_name, ale#Var(a:buffer, l:ale_name)]
    endfor

    return '(setq-default ' . join(l:args) . ')'
endfunction
