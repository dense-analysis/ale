" Author: Jake Zimmerman <jake@zimmerman.io>, Eddie Lebow https://github.com/elebow
" Description: eruby checker using `erubis`, instead of `erb`

function! ale_linters#eruby#erubis#GetCommand(buffer) abort
    let l:rails_root = ale#ruby#FindRailsRoot(a:buffer)

    if empty(l:rails_root)
        return 'erubis -x %t | ruby -c'
    endif

    " Rails-flavored eRuby does not comply with the standard as understood by
    " Erubis, so we'll have to do some substitution. This does not reduce the
    " effectiveness of the linter - the translated code is still evaluated.
    "
    " The graphql-client's graphql view helper does something similar, so we
    " replace that like it does internally
    return 'ruby -r erubis -e ' . ale#Escape('puts Erubis::Eruby.new($stdin.read.gsub(%{<%=},%{<%}).gsub(%{<%graphql},%{<%#})).src') . '< %t | ruby -c'
endfunction

call ale#linter#Define('eruby', {
\   'name': 'erubis',
\   'executable': 'erubis',
\   'output_stream': 'stderr',
\   'command_callback': 'ale_linters#eruby#erubis#GetCommand',
\   'callback': 'ale#handlers#ruby#HandleSyntaxErrors',
\})
