" Author: keith <k@keith.so>
" Description: pylint for python files

call ale#linter#Define('python', {
\   'name': 'pylint',
\   'executable': 'pylint',
\   'command': g:ale#util#stdin_wrapper . ' .py pylint --output-format text --msg-template="{path}:{line}:{column}: {msg_id} {msg}" --reports n',
\   'callback': 'ale#handlers#HandlePEP8Format',
\})
