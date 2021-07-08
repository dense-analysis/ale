call ale#linter#Define('racket', #{
\   name: 'racket-langserver',
\   lsp: 'stdio',
\   executable: 'racket',
\   command: '%e -l racket-langserver',
\   project_root: function('ale#racket#FindProjectRoot'),
\})
