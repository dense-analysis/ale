" Author: rymdbar <https://rymdbar.x20.se/>

function! ale#handlers#perl#GetProjectRoot(buffer) abort
    " Makefile.PL, https://perldoc.perl.org/ExtUtils::MakeMaker
    " Build.PL, https://metacpan.org/pod/Module::Build
    " dist.ini, https://metacpan.org/pod/Dist::Zilla
    let l:potential_roots = [ 'Makefile.PL', 'Build.PL', 'dist.ini' ]

    for l:root in l:potential_roots
        let l:project_root = ale#path#FindNearestFile(a:buffer, l:root)

        if !empty(l:project_root)
            return fnamemodify(l:project_root . '/', ':p:h:h')
        endif
    endfor

    let l:project_root = ale#path#FindNearestFileOrDirectory(a:buffer, '.git')

    if !empty(l:project_root)
        return fnamemodify(l:project_root . '/', ':p:h:h')
    endif

    return fnamemodify(expand('#' . a:buffer . ':p:h'), ':p:h')
endfunction
