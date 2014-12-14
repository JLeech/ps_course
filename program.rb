require_relative 'syntax'
require_relative 'semantic'
require_relative 'interpreter'

command1 = "Make-Object -directory dir-dir | Rename-Object -force new_dir | Make-Object -hidden $_/inside.txt | Zip-Object -recursive ./new_dir"
command2 = "Make-Object -directory dir-dir |accu Print-File -quiet files.txt |each Make-Object $_[0]/$_.txt | Remove-Object $_[0]$name/$_[0]"
command3 = "Diff-Files xxx zzs | Make-Object -directory dir-dir | Make-Object -directory dir-dir"

cur = command1
puts cur
sin = Syntax.new(cur)
sin.iterate
sin.print_blocks
sin.print_messages

sem = Semantic.new(sin.blocks, sin.messages)

inter = Interpreter.new(sem.types_check,sin.blocks)
inter.run
sem.print
