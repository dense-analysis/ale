call ale#linter#Define('typescript', {
\   'name': 'xo',
\   'executable': {b -> ale#handlers#xo#GetExecutable(b)},
\   'command': {b -> ale#handlers#xo#GetLintCommand(b)},
\   'callback': 'ale#handlers#xo#HandleJSON',
\})
