require_relative 'syntax'
require_relative 'semantic'
require_relative 'interpreter'

command1 = "Make-Object -directory ./dir-dir | Rename-Object -force ./new_dir | Make-Object -hidden $_$path/inside.txt | Zip-Object -recursive ./new_dir | Remove-Object ./new_dir"
command2 = "Make-Object -directory ./dir-dir |accu Print-File -quiet ./files.txt |each Make-Object ./$_[0]/$_ | Remove-Object $_$path |accu Zip-Object -recursive ./$_ | Remove-Object ./$_ "

command3 = "Make-Object -directory ./dir-dir | Rename-Object -force ./$_1 "

cur = command1
puts cur
sin = Syntax.new(cur)
sin.iterate
sin.print_blocks
sin.print_messages

sem = Semantic.new(sin.blocks, sin.messages)

inter = Interpreter.new(sem.types_check,sin.blocks)
inter.run

