" Author: David Mohundro <david@mohundro.com>
" Description: swiftlint for swift files

call ale#linter#Define('swift', {
\   'name': 'swiftlint',
\   'executable': 'swiftlint',
\   'command': 'swiftlint lint --use-stdin',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
