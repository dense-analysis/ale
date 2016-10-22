" Author: Bjorn Neergaard <bjorn@neersighted.com>
" Description: ansible-lint for ansible-yaml files

call ale#linter#Define('ansible', {
\   'name': 'ansible',
\   'executable': 'ansible',
\   'command': g:ale#util#stdin_wrapper . ' .yml ansible-lint -p',
\   'callback': 'ale#handlers#HandlePEP8Format',
\})
