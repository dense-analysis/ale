" Author rhysd https://rhysd.github.io/, Dirk Roorda (dirkroorda), Adrián González Rus (@adrigzr)
" Description: remark-lint for Markdown files

call ale#linter#Define('markdown', {
\   'name': 'remark-lint',
\   'executable_callback': 'ale#handlers#remark_lint#GetExecutable',
\   'command_callback': 'ale#handlers#remark_lint#GetCommand',
\   'callback': 'ale#handlers#remark_lint#Handle',
\   'output_stream': 'stderr',
\})
