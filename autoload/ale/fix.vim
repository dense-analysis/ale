if !has_key(s:, 'job_info_map')
    let s:job_info_map = {}
endif

function! s:GatherOutput(job_id, line) abort
    if has_key(s:job_info_map, a:job_id)
        call add(s:job_info_map[a:job_id].output, a:line)
    endif
endfunction

" Apply fixes queued up for buffers which may be hidden.
" Vim doesn't let you modify hidden buffers.
function! ale#fix#ApplyQueuedFixes() abort
    let l:buffer = bufnr('')
    let l:data = get(g:ale_fix_buffer_data, l:buffer, {'done': 0})

    if !l:data.done
        return
    endif

    call remove(g:ale_fix_buffer_data, l:buffer)

    if l:data.changes_made
        let l:start_line = len(l:data.output) + 1
        let l:end_line = len(l:data.lines_before)

        if l:end_line >= l:start_line
            let l:save = winsaveview()
            silent execute l:start_line . ',' . l:end_line . 'd_'
            call winrestview(l:save)
        endif

        " If the file is in DOS mode, we have to remove carriage returns from
        " the ends of lines before calling setline(), or we will see them
        " twice.
        let l:lines_to_set = getbufvar(l:buffer, '&fileformat') is# 'dos'
        \   ? map(copy(l:data.output), 'substitute(v:val, ''\r\+$'', '''', '''')')
        \   : l:data.output

        call setline(1, l:lines_to_set)

        if l:data.should_save
            if empty(&buftype)
                noautocmd :w!
            else
                set nomodified
            endif
        endif
    endif

    if l:data.should_save
        let l:should_lint = g:ale_fix_on_save
    else
        let l:should_lint = l:data.changes_made
    endif

    silent doautocmd <nomodeline> User ALEFixPost

    " If ALE linting is enabled, check for problems with the file again after
    " fixing problems.
    if g:ale_enabled
    \&& l:should_lint
    \&& !ale#events#QuitRecently(l:buffer)
        call ale#Queue(0, l:data.should_save ? 'lint_file' : '')
    endif
endfunction

function! ale#fix#ApplyFixes(buffer, output) abort
    call ale#fix#RemoveManagedFiles(a:buffer)

    let l:data = g:ale_fix_buffer_data[a:buffer]
    let l:data.output = a:output
    let l:data.changes_made = l:data.lines_before != l:data.output

    if l:data.changes_made && bufexists(a:buffer)
        let l:lines = getbufline(a:buffer, 1, '$')

        if l:data.lines_before != l:lines
            call remove(g:ale_fix_buffer_data, a:buffer)
            execute 'echoerr ''The file was changed before fixing finished'''

            return
        endif
    endif

    if !bufexists(a:buffer)
        " Remove the buffer data when it doesn't exist.
        call remove(g:ale_fix_buffer_data, a:buffer)
    endif

    let l:data.done = 1

    " We can only change the lines of a buffer which is currently open,
    " so try and apply the fixes to the current buffer.
    call ale#fix#ApplyQueuedFixes()
endfunction

function! s:HandleExit(job_id, exit_code) abort
    if !has_key(s:job_info_map, a:job_id)
        return
    endif

    let l:job_info = remove(s:job_info_map, a:job_id)
    let l:buffer = l:job_info.buffer

    if g:ale_history_enabled
        call ale#history#SetExitCode(l:buffer, a:job_id, a:exit_code)
    endif

    if has_key(l:job_info, 'file_to_read')
        let l:job_info.output = readfile(l:job_info.file_to_read)
    endif

    let l:ChainCallback = get(l:job_info, 'chain_with', v:null)
    let l:ProcessWith = get(l:job_info, 'process_with', v:null)

    " Post-process the output with a function if we have one.
    if l:ProcessWith isnot v:null
        let l:job_info.output = call(
        \   ale#util#GetFunction(l:ProcessWith),
        \   [l:buffer, l:job_info.output]
        \)
    endif

    " Use the output of the job for changing the file if it isn't empty,
    " otherwise skip this job and use the input from before.
    "
    " We'll use the input from before for chained commands.
    if l:ChainCallback is v:null && !empty(split(join(l:job_info.output)))
        let l:input = l:job_info.output
    else
        let l:input = l:job_info.input
    endif

    let l:next_index = l:ChainCallback is v:null
    \   ? l:job_info.callback_index + 1
    \   : l:job_info.callback_index

    call s:RunFixer({
    \   'buffer': l:buffer,
    \   'input': l:input,
    \   'output': l:job_info.output,
    \   'callback_list': l:job_info.callback_list,
    \   'callback_index': l:next_index,
    \   'chain_callback': l:ChainCallback,
    \})
endfunction

function! ale#fix#ManageDirectory(buffer, directory) abort
    call add(g:ale_fix_buffer_data[a:buffer].temporary_directory_list, a:directory)
endfunction

function! ale#fix#RemoveManagedFiles(buffer) abort
    if !has_key(g:ale_fix_buffer_data, a:buffer)
        return
    endif

    " We can't delete anything in a sandbox, so wait until we escape from
    " it to delete temporary files and directories.
    if ale#util#InSandbox()
        return
    endif

    " Delete directories like `rm -rf`.
    " Directories are handled differently from files, so paths that are
    " intended to be single files can be set up for automatic deletion without
    " accidentally deleting entire directories.
    for l:directory in g:ale_fix_buffer_data[a:buffer].temporary_directory_list
        call delete(l:directory, 'rf')
    endfor

    let g:ale_fix_buffer_data[a:buffer].temporary_directory_list = []
endfunction

function! s:CreateTemporaryFileForJob(buffer, temporary_file, input) abort
    if empty(a:temporary_file)
        " There is no file, so we didn't create anything.
        return 0
    endif

    let l:temporary_directory = fnamemodify(a:temporary_file, ':h')
    " Create the temporary directory for the file, unreadable by 'other'
    " users.
    call mkdir(l:temporary_directory, '', 0750)
    " Automatically delete the directory later.
    call ale#fix#ManageDirectory(a:buffer, l:temporary_directory)
    " Write the buffer out to a file.
    call ale#util#Writefile(a:buffer, a:input, a:temporary_file)

    return 1
endfunction

function! s:RunJob(options) abort
    let l:buffer = a:options.buffer
    let l:command = a:options.command
    let l:input = a:options.input
    let l:output_stream = a:options.output_stream
    let l:read_temporary_file = a:options.read_temporary_file
    let l:ChainWith = a:options.chain_with
    let l:read_buffer = a:options.read_buffer

    if empty(l:command)
        " If there's nothing further to chain the command with, stop here.
        if l:ChainWith is v:null
            return 0
        endif

        " If there's another chained callback to run, then run that.
        call s:RunFixer({
        \   'buffer': l:buffer,
        \   'input': l:input,
        \   'callback_index': a:options.callback_index,
        \   'callback_list': a:options.callback_list,
        \   'chain_callback': l:ChainWith,
        \   'output': [],
        \})

        return 1
    endif

    let [l:temporary_file, l:command] = ale#command#FormatCommand(
    \   l:buffer,
    \   '',
    \   l:command,
    \   l:read_buffer,
    \)
    call s:CreateTemporaryFileForJob(l:buffer, l:temporary_file, l:input)

    let l:command = ale#job#PrepareCommand(l:buffer, l:command)
    let l:job_options = {
    \   'mode': 'nl',
    \   'exit_cb': function('s:HandleExit'),
    \}

    let l:job_info = {
    \   'buffer': l:buffer,
    \   'input': l:input,
    \   'output': [],
    \   'chain_with': l:ChainWith,
    \   'callback_index': a:options.callback_index,
    \   'callback_list': a:options.callback_list,
    \   'process_with': a:options.process_with,
    \}

    if l:read_temporary_file
        " TODO: Check that a temporary file is set here.
        let l:job_info.file_to_read = l:temporary_file
    elseif l:output_stream is# 'stderr'
        let l:job_options.err_cb = function('s:GatherOutput')
    elseif l:output_stream is# 'both'
        let l:job_options.out_cb = function('s:GatherOutput')
        let l:job_options.err_cb = function('s:GatherOutput')
    else
        let l:job_options.out_cb = function('s:GatherOutput')
    endif

    if get(g:, 'ale_emulate_job_failure') == 1
        let l:job_id = 0
    elseif get(g:, 'ale_run_synchronously') == 1
        " Find a unique Job value to use, which will be the same as the ID for
        " running commands synchronously. This is only for test code.
        let l:job_id = len(s:job_info_map) + 1

        while has_key(s:job_info_map, l:job_id)
            let l:job_id += 1
        endwhile
    else
        let l:job_id = ale#job#Start(l:command, l:job_options)
    endif

    let l:status = l:job_id ? 'started' : 'failed'

    if g:ale_history_enabled
        call ale#history#Add(l:buffer, l:status, l:job_id, l:command)
    endif

    if l:job_id == 0
        return 0
    endif

    let s:job_info_map[l:job_id] = l:job_info

    if get(g:, 'ale_run_synchronously') == 1
        " Run a command synchronously if this test option is set.
        let l:output = systemlist(
        \   type(l:command) is v:t_list
        \   ?  join(l:command[0:1]) . ' ' . ale#Escape(l:command[2])
        \   : l:command
        \)

        if !l:read_temporary_file
            let s:job_info_map[l:job_id].output = l:output
        endif

        call l:job_options.exit_cb(l:job_id, v:shell_error)
    endif

    return 1
endfunction

function! s:RunFixer(options) abort
    let l:buffer = a:options.buffer
    let l:input = get(a:options, 'input', g:ale_fix_buffer_data[l:buffer].lines_before)
    let l:index = a:options.callback_index
    let l:callback_list = a:options.callback_list
    let l:ale_fix_buffer_data = get(g:ale_fix_buffer_data, l:buffer)
    let l:ChainCallback = get(a:options, 'chain_callback', v:null)

    while len(l:callback_list) > l:index
        let l:Function = l:ChainCallback isnot v:null
        \   ? ale#util#GetFunction(l:ChainCallback)
        \   : a:options.callback_list[l:index]

        if l:ChainCallback isnot v:null
            " Chained commands accept (buffer, output, [input])
            let l:result = ale#util#FunctionArgCount(l:Function) == 2
            \   ? call(l:Function, [l:buffer, a:options.output])
            \   : call(l:Function, [l:buffer, a:options.output, copy(l:input)])
        else
            " Chained commands accept (buffer, [input])
            let l:result = ale#util#FunctionArgCount(l:Function) == 1
            \   ? call(l:Function, [l:buffer])
            \   : call(l:Function, [l:buffer, copy(l:input)])
        endif

        if type(l:result) is v:t_number && l:result == 0
            " When `0` is returned, skip this item.
            let l:index += 1
        elseif type(l:result) is v:t_list
            let l:input = l:result
            let l:index += 1
        else
            let l:ChainWith = get(l:result, 'chain_with', v:null)
            " Default to piping the buffer for the last fixer in the chain.
            let l:read_buffer = get(l:result, 'read_buffer', l:ChainWith is v:null)

            let l:options = {
            \   'buffer': l:buffer,
            \   'command': l:result.command,
            \   'input': l:input,
            \   'output_stream': get(l:result, 'output_stream', 'stdout'),
            \   'read_temporary_file': get(l:result, 'read_temporary_file', 0),
            \   'read_buffer': l:read_buffer,
            \   'chain_with': l:ChainWith,
            \   'callback_list': l:callback_list,
            \   'callback_index': l:index,
            \   'process_with': get(l:result, 'process_with', v:null),
            \}

            let l:fixer_index = get(l:ale_fix_buffer_data, 'fixer_index')
            let l:current_fixer = get(l:ale_fix_buffer_data['callbacks_fixers'], l:fixer_index)

            if !get(l:ale_fix_buffer_data['initialized_fixers'], l:current_fixer)
                let l:pre_init_function = ale#fix#registry#PreInit(l:current_fixer)

                if len(l:pre_init_function)
                    let l:options = call (ale#util#GetFunction(l:pre_init_function), [l:options])
                endif

                let l:ale_fix_buffer_data['initialized_fixers'][l:current_fixer] = 1
                let l:ale_fix_buffer_data['fixer_index'] += 1
            endif

            let l:job_ran = s:RunJob(l:options)

            if !l:job_ran
                " The job failed to run, so skip to the next item.
                let l:index += 1
            else
                " Stop here, we will handle exit later on.
                return
            endif
        endif
    endwhile

    call ale#fix#ApplyFixes(l:buffer, l:input)
endfunction

function! s:AddSubCallbacks(full_list, callbacks) abort
    if type(a:callbacks) is v:t_string
        call add(a:full_list, a:callbacks)
    elseif type(a:callbacks) is v:t_list
        call extend(a:full_list, a:callbacks)
    else
        return 0
    endif

    return 1
endfunction

function! s:GetFixerCallbacks(fixer) abort
    let l:callback_list = []

    call s:AddSubCallbacks(l:callback_list, a:fixer)

    if empty(l:callback_list)
        return []
    endif

    let l:corrected_list = []
    let l:functions_names = []

    " Variables with capital characters are needed, or Vim will complain about
    " funcref variables.
    for l:Item in l:callback_list
        if type(l:Item) is v:t_string
            let l:Func = ale#fix#registry#GetFunc(l:Item)

            if !empty(l:Func)
                call add(l:functions_names, l:Func)
                let l:Item = l:Func
            endif
        endif

        try
            call add(l:corrected_list, ale#util#GetFunction(l:Item))
        catch /E475/
            " Rethrow exceptions for failing to get a function so we can print
            " a friendly message about it.
            throw 'BADNAME ' . v:exception
        endtry
    endfor

    return [l:corrected_list, l:functions_names]
endfunction

function! s:ProcessFixerList(fixer_list) abort
    let l:callback_list = []
    let l:callbacks_fixers = []

    try
        for l:index in range(0, len(a:fixer_list) - 1, 1)
            if type(a:fixer_list[l:index]) == v:t_string
                let l:fixer = a:fixer_list[l:index]
                let [l:corrected_list, l:functions_names] = s:GetFixerCallbacks(l:fixer)

                if !empty(l:corrected_list)
                    for l:function in l:functions_names
                        call add(l:callbacks_fixers, l:fixer)
                    endfor

                    for l:Callback in l:corrected_list
                        call add(l:callback_list, l:Callback)
                    endfor
                endif
            else
                let l:Callback = ale#util#GetFunction(a:fixer_list[l:index])
                call add(l:callback_list, l:Callback)
                call add(l:callbacks_fixers, '?')
            endif
        endfor
    catch /E700\|E475\|BADNAME/
        let l:function_name = join(split(split(v:exception, ':')[3]))
        let l:echo_message = printf(
        \   'There is no fixer named `%s`. Check :ALEFixSuggest',
        \   l:function_name,
        \)

        throw 'INVALIDFIXER ' . l:echo_message
    endtry

    return [l:callback_list, l:callbacks_fixers]
endfunction

function! s:MapCallbacksToFixers(fixers) abort
    let l:callback_list = []
    let l:callbacks_fixers = []

    if type(a:fixers) == v:t_list
        return s:ProcessFixerList(a:fixers)
    else
        for l:sub_type in split(&filetype, '\.') + ['*']
            let l:fixer_list = get(a:fixers, l:sub_type, [])

            let [l:c_l, l:c_f] = s:ProcessFixerList(l:fixer_list)
            call extend(l:callback_list, l:c_l)
            call extend(l:callbacks_fixers, l:c_f)
        endfor
    endif

    return [l:callback_list, l:callbacks_fixers]
endfunction

function! ale#fix#InitBufferData(buffer, fixing_flag, ...) abort
    let l:optional_fixers = get(a:000, 0, [])
    let l:fixers = empty(l:optional_fixers) ? ale#Var(a:buffer, 'fixers') : l:optional_fixers

    " The 'done' flag tells the function for applying changes when fixing
    " is complete.
    let l:buffer_data = {
    \   'lines_before': getbufline(a:buffer, 1, '$'),
    \   'done': 0,
    \   'should_save': a:fixing_flag is# 'save_file',
    \   'temporary_directory_list': [],
    \   'callbacks_fixers': [],
    \   'fixers_callbacks': [],
    \   'fixer_index': 0,
    \   'last_error': '',
    \   'initialized_fixers': {}
    \}
    " Always initialize the buffer data object
    let l:exit_status = 1

    try
        let [l:callback_list, l:callbacks_fixers] = s:MapCallbacksToFixers(l:fixers)

        let l:buffer_data = extend(l:buffer_data,
        \   {
        \     'callbacks_fixers': l:callbacks_fixers,
        \     'fixers_callbacks': l:callback_list
        \   }
        \ )
    catch /INVALIDFIXER/
        let l:buffer_data = extend(l:buffer_data, { 'last_error': v:exception } )
        let l:exit_status = 0
    endtry

    let g:ale_fix_buffer_data[a:buffer] = l:buffer_data

    return l:exit_status
endfunction

" Accepts an optional argument for what to do when fixing.
" Returns 0 if no fixes can be applied, and 1 if fixing can be done.
function! ale#fix#Fix(buffer, fixing_flag, ...) abort
    if a:fixing_flag isnot# '' && a:fixing_flag isnot# 'save_file'
        throw "fixing_flag must be either '' or 'save_file'"
    endif

    for l:job_id in keys(s:job_info_map)
        call remove(s:job_info_map, l:job_id)
        call ale#job#Stop(l:job_id)
    endfor

    " Clean up any files we might have left behind from a previous run.
    call ale#fix#RemoveManagedFiles(a:buffer)
    " In case fixers have been selected as fargs for the command, pass them on
    call ale#fix#InitBufferData(a:buffer, a:fixing_flag, a:000)
    let l:ale_fix_buffer_data = g:ale_fix_buffer_data[a:buffer]


    if empty(l:ale_fix_buffer_data.fixers_callbacks) && empty(a:fixing_flag)
        " Prioritize error messages before the default one
        if !empty(l:ale_fix_buffer_data.last_error)
            execute 'echom l:ale_fix_buffer_data.last_error'
        else
            execute 'echom ''No fixers have been defined. Try :ALEFixSuggest'''
        endif

        return 0
    endif

    silent doautocmd <nomodeline> User ALEFixPre

    call s:RunFixer({
    \   'buffer': a:buffer,
    \   'input': l:ale_fix_buffer_data.lines_before,
    \   'callback_index': 0,
    \   'callback_list': l:ale_fix_buffer_data.fixers_callbacks
    \})

    return 1
endfunction

" Set up an autocmd command to try and apply buffer fixes when available.
augroup ALEBufferFixGroup
    autocmd!
    autocmd BufEnter * call ale#fix#ApplyQueuedFixes()
augroup END
