" Author: w0rp <devw0rp@gmail.com>
" Description: ansible-lint for ansible-yaml files

if exists('g:loaded_ale_linters_ansible_ansiblelint')
    finish
endif

let g:loaded_ale_linters_ansible_ansiblelint = 1

call ale#linter#Define('ansible', {
\   'name': 'ansible',
\   'executable': 'ansible',
\   'command': g:ale#util#stdin_wrapper . ' .yml ansible-lint -p',
\   'callback': 'ale#handlers#HandlePEP8Format',
\})
