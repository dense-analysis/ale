" Author: Andrey Popp <8mayday@gmail.com>
" Description: LSP SymbolKind utils

let s:file = 1
let s:module = 2
let s:namespace = 3
let s:package  = 4
let s:class = 5
let s:method = 6
let s:property = 7
let s:field = 8
let s:constructor = 9
let s:enum = 10
let s:interface = 11
let s:function = 12
let s:variable = 13
let s:constant = 14
let s:string = 15
let s:number = 16
let s:boolean = 17
let s:array = 18
let s:object = 19
let s:key = 20
let s:null = 21
let s:enummember = 22
let s:struct = 23
let s:event = 24
let s:operator = 25
let s:typeparameter = 26

let s:to_string = {
\    s:file: 'file',
\    s:module: 'module',
\    s:namespace: 'namespace',
\    s:package:  'package',
\    s:class: 'class',
\    s:method: 'method',
\    s:property: 'property',
\    s:field: 'field',
\    s:constructor: 'constructor',
\    s:enum: 'enum',
\    s:interface: 'interface',
\    s:function: 'func',
\    s:variable: 'variable',
\    s:constant: 'constant',
\    s:string: 'string',
\    s:number: 'number',
\    s:boolean: 'bool',
\    s:array: 'array',
\    s:object: 'object',
\    s:key: 'key',
\    s:null: 'null',
\    s:enummember: 'enummember',
\    s:struct: 'struct',
\    s:event: 'event',
\    s:operator: 'operator',
\    s:typeparameter: 'typeparam',
\}

function! ale#lsp#symbol_kind#Show(kind) abort
    return get(s:to_string, a:kind, v:null)
endfunction
