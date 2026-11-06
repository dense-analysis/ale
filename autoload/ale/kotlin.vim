" Author: Paul Meinhardt <https://github.com/pmeinhardt>
" Description: Functions for working with Kotlin projects.

" Find the root of a Gradle or Maven project.
function! ale#kotlin#FindProjectRoot(buffer) abort
    let l:gradle_root = ale#gradle#FindProjectRoot(a:buffer)

    if !empty(l:gradle_root)
        return l:gradle_root
    endif

    let l:maven_pom_file = ale#path#FindNearestFile(a:buffer, 'pom.xml')

    if !empty(l:maven_pom_file)
        return fnamemodify(l:maven_pom_file, ':h')
    endif

    return ''
endfunction
