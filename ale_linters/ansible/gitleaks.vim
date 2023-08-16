scriptencoding utf-8
" Author: Peter Benjamin <https://github.com/pbnj>
" Description: gitleaks support for ansible files.

call ale#handlers#gitleaks#DefineLinter('ansible')
