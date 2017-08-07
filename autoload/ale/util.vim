" Author: w0rp <devw0rp@gmail.com>
" Description: Contains miscellaneous functions

" A null file for sending output to nothing.
let g:ale#util#nul_file = '/dev/null'

if has('win32')
    let g:ale#util#nul_file = 'nul'
endif

" Return the number of lines for a given buffer.
function! ale#util#GetLineCount(buffer) abort
    return len(getbufline(a:buffer, 1, '$'))
endfunction

function! ale#util#GetFunction(string_or_ref) abort
    if type(a:string_or_ref) == type('')
        return function(a:string_or_ref)
    endif

    return a:string_or_ref
endfunction

function! ale#util#LocItemCompare(left, right) abort
    if a:left['lnum'] < a:right['lnum']
        return -1
    endif

    if a:left['lnum'] > a:right['lnum']
        return 1
    endif

    if a:left['col'] < a:right['col']
        return -1
    endif

    if a:left['col'] > a:right['col']
        return 1
    endif

    return 0
endfunction

" This function will perform a binary search to find a message from the
" loclist to echo when the cursor moves.
function! ale#util#BinarySearch(loclist, line, column) abort
    let l:min = 0
    let l:max = len(a:loclist) - 1
    let l:last_column_match = -1

    while 1
        if l:max < l:min
            return l:last_column_match
        endif

        let l:mid = (l:min + l:max) / 2
        let l:obj = a:loclist[l:mid]

        " Binary search to get on the same line
        if a:loclist[l:mid]['lnum'] < a:line
            let l:min = l:mid + 1
        elseif a:loclist[l:mid]['lnum'] > a:line
            let l:max = l:mid - 1
        else
            let l:last_column_match = l:mid

            " Binary search to get the same column, or near it
            if a:loclist[l:mid]['col'] < a:column
                let l:min = l:mid + 1
            elseif a:loclist[l:mid]['col'] > a:column
                let l:max = l:mid - 1
            else
                return l:mid
            endif
        endif
    endwhile
endfunction

" A function for testing if a function is running inside a sandbox.
" See :help sandbox
function! ale#util#InSandbox() abort
    try
        function! s:SandboxCheck() abort
        endfunction
    catch /^Vim\%((\a\+)\)\=:E48/
        " E48 is the sandbox error.
        return 1
    endtry

    return 0
endfunction

" Get the number of milliseconds since some vague, but consistent, point in
" the past.
"
" This function can be used for timing execution, etc.
"
" The time will be returned as a Number.
function! ale#util#ClockMilliseconds() abort
    return float2nr(reltimefloat(reltime()) * 1000)
endfunction

" Given a single line, or a List of lines, and a single pattern, or a List
" of patterns, return all of the matches for the lines(s) from the given
" patterns, using matchlist().
"
" Only the first pattern which matches a line will be returned.
function! ale#util#GetMatches(lines, patterns) abort
    let l:matches = []
    let l:lines = type(a:lines) == type([]) ? a:lines : [a:lines]
    let l:patterns = type(a:patterns) == type([]) ? a:patterns : [a:patterns]

    for l:line in l:lines
        for l:pattern in l:patterns
            let l:match = matchlist(l:line, l:pattern)

            if !empty(l:match)
                call add(l:matches, l:match)
                break
            endif
        endfor
    endfor

    return l:matches
endfunction

function! s:LoadArgCount(function) abort
    let l:Function = a:function

    redir => l:output
        silent! function Function
    redir END

    if !exists('l:output')
        return 0
    endif

    let l:match = matchstr(split(l:output, "\n")[0], '\v\([^)]+\)')[1:-2]
    let l:arg_list = filter(split(l:match, ', '), 'v:val !=# ''...''')

    return len(l:arg_list)
endfunction

" Given the name of a function, a Funcref, or a lambda, return the number
" of named arguments for a function.
function! ale#util#FunctionArgCount(function) abort
    let l:Function = ale#util#GetFunction(a:function)
    let l:count = s:LoadArgCount(l:Function)

    " If we failed to get the count, forcibly load the autoload file, if the
    " function is an autoload function. autoload functions aren't normally
    " defined until they are called.
    if l:count == 0
        let l:function_name = matchlist(string(l:Function), 'function([''"]\(.\+\)[''"])')[1]

        if l:function_name =~# '#'
            execute 'runtime autoload/' . join(split(l:function_name, '#')[:-2], '/') . '.vim'
            let l:count = s:LoadArgCount(l:Function)
        endif
    endif

    return l:count
endfunction

" Escape a string so the characters in it will be safe for use inside of PCRE
" or RE2 regular expressions without characters having special meanings.
function! ale#util#EscapePCRE(unsafe_string) abort
    return substitute(a:unsafe_string, '\([\-\[\]{}()*+?.^$|]\)', '\\\1', 'g')
endfunction

" Given a String or a List of String values, try and decode the string(s)
" as a JSON value which can be decoded with json_decode. If the JSON string
" is invalid, the default argument value will be returned instead.
"
" This function is useful in code where the data can't be trusted to be valid
" JSON, and where throwing exceptions is mostly just irritating.
function! ale#util#FuzzyJSONDecode(data, default) abort
    if empty(a:data)
        return a:default
    endif

    let l:str = type(a:data) == type('') ? a:data : join(a:data, '')

    try
        return json_decode(l:str)
    catch /E474/
        return a:default
    endtry
endfunction

" Write a file, including carriage return characters for DOS files.
"
" The buffer number is required for determining the fileformat setting for
" the buffer.
function! ale#util#Writefile(buffer, lines, filename) abort
    let l:corrected_lines = getbufvar(a:buffer, '&fileformat') ==# 'dos'
    \   ? map(copy(a:lines), 'v:val . "\r"')
    \   : a:lines

    call writefile(l:corrected_lines, a:filename) " no-custom-checks
endfunction
