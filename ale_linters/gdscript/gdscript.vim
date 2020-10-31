" Author: Wilson E. Alvarez <https://github.com/Rubonnek>
" Description: Linter for the Godot game engine scripting language.

call ale#linter#Define('gdscript', {
\   'name': 'godot',
\   'lsp': 'socket',
\   'address': '127.0.0.1:6008',
\   'project_root': 'project.godot',
\})
