" Author: Bjorn Neergaard <bjorn@neersighted.com>
" Description: ansible-lint for ansible-yaml files

call ale#linter#Define('ansible', {
\   'name': 'ansible',
\   'executable': 'ansible',
\   'command': 'ansible-lint -p %t',
\   'callback': 'ale#handlers#HandlePEP8Format',
\})
