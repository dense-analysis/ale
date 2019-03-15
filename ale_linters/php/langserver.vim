" Author: Eric Stern <eric@ericstern.com>
" Description: PHP Language server integration for ALE

call ale#Set('php_langserver_executable', 'php-language-server.php')
call ale#Set('php_langserver_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('php_langserver_project_root_manual', get(g:, 'php_langserver_project_root_manual', 0))
call ale#Set('php_langserver_project_root', get(g:, 'php_langserver_project_root', ''))
call ale#Set('php_langserver_project_root_from_git', get(g:, 'php_langserver_project_root_from_git', 1))

function! ale_linters#php#langserver#GetProjectRoot(buffer) abort
    if 1 is g:ale_php_langserver_project_root_manual
      if empty(g:ale_php_langserver_project_root)
        echomsg 'g:ale_php_langserver_project_root_manual is set, but g:ale_php_langserver_project_root is empty!'
        " TODO prevent start misconfigured langserver
      endif

      return g:ale_php_langserver_project_root
    endif

    if 1 is g:ale_php_langserver_project_root_from_git
      try
        return ale#path#findGitToplevel(bufname(a:buffer))
      catch
        echomsg v:exception
        " TODO prevent start misconfigured langserver
      endtry
    endif

    return ''
endfunction

call ale#linter#Define('php', {
\   'name': 'langserver',
\   'lsp': 'stdio',
\   'executable': {b -> ale#node#FindExecutable(b, 'php_langserver', [
\       'vendor/bin/php-language-server.php',
\   ])},
\   'command': 'php %e',
\   'project_root': function('ale_linters#php#langserver#GetProjectRoot'),
\})
