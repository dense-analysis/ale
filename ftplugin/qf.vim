augroup ALEQuickfixCursorMovedEvent
    autocmd! * <buffer>
    autocmd CursorMoved <buffer> call ale#events#ParseLoclistWindowItemPosition()
augroup END
