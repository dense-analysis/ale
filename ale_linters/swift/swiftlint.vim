" Author: David Mohundro <david@mohundro.com>
" Description: swiftlint for swift files

call ale#linter#Define('swiftlint', {
\   'name': 'swiftlint',
\   'executable': 'swiftlint',
\   'command': g:ale#util#stdin_wrapper . ' .swift swiftlint',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
