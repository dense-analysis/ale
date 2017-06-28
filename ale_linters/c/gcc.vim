" Author: w0rp <devw0rp@gmail.com>
" Description: gcc linter for c files

" Set this option to change the GCC options for warnings for C.
if !exists('g:ale_c_gcc_options')
    " let g:ale_c_gcc_options = '-Wall'
    " let g:ale_c_gcc_options = '-std=c99 -Wall'
    " c11 compatible
    let g:ale_c_gcc_options = '-std=c11 -Wall'
endif

function! ale_linters#c#gcc#GetCommand(buffer) abort
    let l:paths = ale#c#FindLocalHeaderPaths(a:buffer)

	let l:use_args = ' '
	let l:compile_commands_path = ale#path#FindNearestFile(a:buffer, 'compile_commands.json')
	if (!empty(l:compile_commands_path))
		let l:bufname = fnamemodify(bufname(a:buffer), ':p')
		let l:command = ''
		let l:file = 'none'

		for elem in readfile(l:compile_commands_path)
			let l:split = split(elem, ':')
			if (len(l:split) > 1)
				let l:key = split(l:split[0], '"')
				let l:value = split(l:split[1], '"')
				if l:key[1] == 'command'
					let l:command = l:value[1]
				elseif l:key[1] == 'file'
					let l:file = l:value[1]
				endif

				if (!empty(l:file))
					if l:file == l:bufname
						let l:use_args = join(split(l:command, ' ')[2:-4], ' ') . ' '
						break
					endif
				endif
			endif
		endfor
	endif

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return 'gcc -S -x c -fsyntax-only '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h')) . ' '
    \   . ale#c#IncludeOptions(l:paths)
	\   . l:use_args
    \   . ale#Var(a:buffer, 'c_gcc_options') . ' -'
endfunction

call ale#linter#Define('c', {
\   'name': 'gcc',
\   'output_stream': 'stderr',
\   'executable': 'gcc',
\   'command_callback': 'ale_linters#c#gcc#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
