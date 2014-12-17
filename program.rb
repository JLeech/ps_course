require_relative 'syntax'
require_relative 'semantic'
require_relative 'interpreter'

command1 = "Change-Directory ./XXX | Make-Object -directory ./dir-dir | Rename-Object -force ./new_dir |accu Make-Object -hidden $_$path/inside.txt |accu Zip-Object ./$_[0] | Remove-Object ./$_[0]"
command2 = "Make-Object -directory ./dir-dir |accu Print-File -quiet ./files.txt |each Make-Object ./$_[0]/$_ | Remove-Object $_$path |accu Zip-Object -recursive ./$_ | Remove-Object ./$_ "

command3 = "Make-Object -directory ./dir-dir | Rename-Object -force ./$_1 "

command4 = "List-Objects ./"

cur = command4
puts cur
sin = Syntax.new(cur)
sin.iterate
sin.print_blocks
sin.print_messages

sem = Semantic.new(sin.blocks, sin.messages)

inter = Interpreter.new(sem.types_check,sin.blocks)
inter.run

