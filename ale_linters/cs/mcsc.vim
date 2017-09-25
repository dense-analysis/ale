let g:ale_cs_mcsc_options = get(g:, 'ale_cs_mcsc_options', '')
let g:ale_cs_mcsc_source = get(g:,'ale_cs_mcsc_source','')
let g:ale_cs_mcsc_assembly_path = get(g:,'ale_cs_mcsc_assembly_path',[])
let g:ale_cs_mcsc_assemblies = get(g:,'ale_cs_mcsc_assemblies',[])
function! ale_linters#cs#mcsc#GetCommand(buffer) abort
	let l:path = ale#Var(a:buffer,'cs_mcsc_assembly_path')
	if !empty(l:path)
        if type(l:path) == type('')
            let l:path = '-lib:' . l:path
        elseif type(l:path) == type([])
            let l:path = '-lib:' . join(l:path,',')
        else
            throw 'assembly path list must be string or list of path strings'
        endif
    elseif type(l:path) != type('') 
        if type(l:path) != type([])
            throw 'assembly path list must be string or list of path strings'
        endif
        let l:path =''
    endif
    let l:assemblies = ale#Var(a:buffer,'cs_mcsc_assemblies')
	if !empty(l:assemblies)
        if type(l:assemblies) == type('')
            let l:assemblies = '-r' . l:assemblies
        elseif type(l:assemblies) == type([])
            let l:assemblies = '-r:' . join(l:assemblies,',')
        else
            throw 'assembly list must be string or list of strings'
        endif
    elseif type(l:assemblies) != type('') 
        if type(l:assemblies) != type([])
            throw 'assembly list must be string or list of string'
        endif
        let l:assemblies =''
    endif
	let l:base = ale#Var(a:buffer,'cs_mcsc_source')
	let l:cwd = getcwd()
	if isdirectory(l:base)
		exe 'cd ' . l:base
	elseif empty(l:base) && ( type(l:base) == type('') )
		let l:base = '.'
	else
		throw 'ale_cs_mcs_source must point to an existing directory or empty string for current'
	endif
	let l:out = tempname()
	call ale#engine#ManageFile(a:buffer,l:out)
    let l:cmd = 'cd ' . l:base . ';'
    \    . 'mcs -unsafe' 
    \    . ' ' . ale#Var(a:buffer, 'cs_mcsc_options')
    \    . ' ' . l:path
    \    . ' ' . l:assemblies
	\    . ' -out:' . l:out
    \    . ' -t:module'
    \    . ' "' . join(glob('**/*.cs',v:false,v:true),'" "') . '"'
	exe 'cd ' . l:cwd
	return l:cmd
endfunction

function! ale_linters#cs#mcsc#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " Tests.cs(12,29): error CSXXXX: ; expected
    let l:pattern = '^\(.\+\.cs\)(\(\d\+\),\(\d\+\)): \(.\+\): \(.\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
		\   'filename': l:match[1],
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:match[4] . ': ' . l:match[5],
        \   'type': l:match[4] =~# '^error' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('cs',{
\   'name': 'mcsc',
\   'output_stream': 'stderr',
\   'executable': 'mcs',
\   'command_callback': 'ale_linters#cs#mcsc#GetCommand',
\   'callback': 'ale_linters#cs#mcsc#Handle',
\	'lint_file': 1
\})
