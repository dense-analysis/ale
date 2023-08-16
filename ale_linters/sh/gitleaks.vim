scriptencoding utf-8
" Author: Peter Benjamin <https://github.com/pbnj>
" Description: gitleaks support for terraform files.

call ale#handlers#gitleaks#DefineLinter('sh')
