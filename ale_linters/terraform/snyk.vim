" Description: snyk for Terraform files
"
" See: https://www.terraform.io/
"      https://github.com/snyk/cli

call ale#Set('terraform_snyk_options', '')
call ale#Set('terraform_snyk_executable', 'snyk')

let s:separator = has('win32') ? '\' : '/'

function! ale_linters#terraform#snyk#Handle(buffer, lines) abort
    let l:output = []
    let l:json = ale#util#FuzzyJSONDecode(a:lines, {})

    for l:result in l:json
        if l:result.ok is# v:false
            for l:iac_issues in get(l:result, 'infrastructureAsCodeIssues')
                if l:iac_issues.severity is# 'low' || l:iac_issues.severity is# 'medium'
                    let l:type = 'W'
                elseif l:iac_issues.severity is# 'high' || l:iac_issues.severity is# 'critical'
                    let l:type = 'E'
                else
                    let l:type = 'W'
                endif

                call add(l:output, {
                \   'filename': l:result.targetFilePath,
                \   'lnum': l:iac_issues.lineNumber,
                \   'text': l:iac_issues.iacDescription.issue . ale#Pad('.') . ale#Pad(l:iac_issues.iacDescription.impact) . ale#Pad('.') . ale#Pad(l:iac_issues.iacDescription.resolve),
                \   'code': l:iac_issues.publicId,
                \   'type': l:type,
                \})
            endfor
        endif
    endfor

    return l:output
endfunction

" Construct command arguments to snyk with `terraform_snyk_options`.
function! ale_linters#terraform#snyk#GetCommand(buffer) abort
    let l:cmd = '%e iac test'

    let l:opts = ale#Var(a:buffer, 'terraform_snyk_options')

    if !empty(l:opts)
        let l:cmd .= ale#Pad(l:opts)
    endif

    let l:cmd .= ale#Pad('--json')

    return l:cmd
endfunction

call ale#linter#Define('terraform', {
\   'name': 'snyk',
\   'executable': {b -> ale#Var(b, 'terraform_snyk_executable')},
\   'cwd': '%s:h',
\   'command': function('ale_linters#terraform#snyk#GetCommand'),
\   'callback': 'ale_linters#terraform#snyk#Handle',
\})
