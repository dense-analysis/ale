call ale#linter#Define('typescript', {
\   'name': 'xo',
\   'executable': {b -> ale#handlers#xo#GetExecutable(b, 'typescript')},
\   'command': {b -> ale#handlers#xo#GetLintCommand(b, 'typescript')},
\   'callback': 'ale#handlers#xo#HandleJSON',
\})
