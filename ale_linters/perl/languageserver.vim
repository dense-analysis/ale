" Authors: ophirr33 <coghlan.ty@gmail.com> and rymdbar
" Description: Perl::LanguageServer for perl, from cpan.org

" This should have the same value as in perl.vim
call ale#Set('perl_perl_executable', 'perl')
" Please note that perl_perl_options does not exist here.

function! ale_linters#perl#languageserver#GetProjectRoot(buffer) abort
    " Makefile.PL, https://perldoc.perl.org/ExtUtils::MakeMaker
    " Build.PL, https://metacpan.org/pod/Module::Build
    " dist.ini, https://metacpan.org/pod/Dist::Zilla
    let l:potential_roots = [ 'Makefile.PL', 'Build.PL', 'dist.ini', '.git' ]

    for l:root in l:potential_roots
        let l:project_root = ale#path#FindNearestFile(a:buffer, l:root)

        if empty(l:project_root)
            let l:project_root = ale#path#FindNearestFile(
            \   a:buffer,
            \   l:root,
            \ )
        endif

        if !empty(l:project_root)
            return fnamemodify(l:project_root . '/', ':p:h:h')
        endif
    endfor

    return fnamemodify(bufname(), ':p:h')
endfunction

call ale#Set('perl_languageserver_config', {})
call ale#linter#Define('perl', {
\   'name': 'languageserver',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'perl_perl_executable')},
\   'command': '%e -MPerl::LanguageServer -ePerl::LanguageServer::run',
\   'lsp_config': {b -> ale#Var(b, 'perl_languageserver_config')},
\   'project_root': function('ale_linters#perl#languageserver#GetProjectRoot'),
\ })
