" Given some text, parse a semantic versioning string from the text
" into a triple of integeers [major, minor, patch].
"
" If no match can be performed, then an empty List will be returned instead.
function! ale#semver#Parse(text) abort
    let l:match = matchlist(a:text, '^ *\(\d\+\)\.\(\d\+\)\.\(\d\+\)')

    if empty(l:match)
        return []
    endif

    return [l:match[1] + 0, l:match[2] + 0, l:match[3] + 0]
endfunction

" Given two triples of integers [major, minor, patch], compare the triples
" and return 1 if the lhs is greater than or equal to the rhs.
function! ale#semver#GreaterOrEqual(lhs, rhs) abort
    if a:lhs[0] > a:rhs[0]
        return 1
    elseif a:lhs[0] == a:rhs[0]
        if a:lhs[1] > a:rhs[1]
            return 1
        elseif a:lhs[1] == a:rhs[1]
            return a:lhs[2] >= a:rhs[2]
        endif
    endif

    return 0
endfunction
