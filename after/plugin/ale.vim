if exists('g:loaded_ale_after')
    finish
endif

let g:loaded_ale_after = 1

if !g:ale_emit_conflict_warnings
    finish
endif

function! s:GetConflictingPluginWarning(plugin_name) abort
    return 'ALE conflicts with ' . a:plugin_name
    \   . '. Uninstall it, or disable this warning with '
    \   . '`let g:ale_emit_conflict_warnings = 0` in your vimrc file, '
    \   . '*before* plugins are loaded.'
endfunction

if exists('g:loaded_syntastic_plugin')
    throw s:GetConflictingPluginWarning('Syntastic')
endif

if exists('g:loaded_neomake')
    throw s:GetConflictingPluginWarning('Neomake')
endif

if exists('g:loaded_validator_plugin')
    throw s:GetConflictingPluginWarning('Validator')
endif
