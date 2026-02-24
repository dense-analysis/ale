" Description: trivy for Terraform files
"
" See: https://www.terraform.io/
"      https://github.com/aquasecurity/trivy

call ale#Set('terraform_trivy_options', '')
call ale#Set('terraform_trivy_executable', 'trivy')

function! ale_linters#terraform#trivy#Handle(buffer, lines) abort
    let l:output = []
    let l:json = ale#util#FuzzyJSONDecode(a:lines, {})

    if empty(get(l:json, 'Results'))
        return l:output
    endif

    let l:fname = expand('#' . a:buffer . ':t')

    for l:result in get(l:json, 'Results', [])
        for l:misconfig in get(l:result, 'Misconfigurations', [])
            let l:severity = get(l:misconfig, 'Severity', 'MEDIUM')

            if l:severity is# 'LOW'
                let l:type = 'I'
            elseif l:severity is# 'CRITICAL' || l:severity is# 'HIGH'
                let l:type = 'E'
            else
                let l:type = 'W'
            endif

            let l:cause = get(l:misconfig, 'CauseMetadata', {})
            let l:title = get(l:misconfig, 'Title', '')
            let l:id = get(l:misconfig, 'ID', '')
            let l:desc = get(l:misconfig, 'Description', '')

            " Module findings store the location in the caller's file
            " in CauseMetadata.Occurrences. Use those when available.
            let l:occurrences = get(l:cause, 'Occurrences', [])

            if !empty(l:occurrences)
                for l:occurrence in l:occurrences
                    if get(l:occurrence, 'Filename', '') ==# l:fname
                        let l:loc = get(l:occurrence, 'Location', {})

                        call add(l:output, {
                        \   'lnum': get(l:loc, 'StartLine', 1),
                        \   'end_lnum': get(l:loc, 'EndLine', get(l:loc, 'StartLine', 1)),
                        \   'text': l:title . ' [' . l:id . ']',
                        \   'detail': l:id . ': ' . l:title . "\n" . l:desc,
                        \   'code': l:id,
                        \   'type': l:type,
                        \})
                    endif
                endfor
            elseif get(l:result, 'Target', '') ==# l:fname
                call add(l:output, {
                \   'lnum': get(l:cause, 'StartLine', 1),
                \   'end_lnum': get(l:cause, 'EndLine', get(l:cause, 'StartLine', 1)),
                \   'text': l:title . ' [' . l:id . ']',
                \   'detail': l:id . ': ' . l:title . "\n" . l:desc,
                \   'code': l:id,
                \   'type': l:type,
                \})
            endif
        endfor
    endfor

    return l:output
endfunction

" Construct command arguments to trivy with `terraform_trivy_options`.
function! ale_linters#terraform#trivy#GetCommand(buffer) abort
    let l:cmd = '%e config --format json'

    let l:opts = ale#Var(a:buffer, 'terraform_trivy_options')

    if !empty(l:opts)
        let l:cmd .= ' ' . l:opts
    endif

    let l:cmd .= ' %t'

    return l:cmd
endfunction

call ale#linter#Define('terraform', {
\   'name': 'trivy',
\   'executable': {b -> ale#Var(b, 'terraform_trivy_executable')},
\   'command': function('ale_linters#terraform#trivy#GetCommand'),
\   'callback': 'ale_linters#terraform#trivy#Handle',
\})
