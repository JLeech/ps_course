require_relative 'sintax'
require_relative 'semantic'

command1 = "Make-Objecct -directory dir-dir | Rename-Object -directory new_dir | Make-Object ./$_/inside.txt | Zip-Object -recursive dir-dir"
command2 = "Make-Object -directory dir-dir | Print-File -quiet list.txt |each Make-Object dir-dir/$_.txt | New-Command -bla"

sin = Sintax.new(command1)
sin.iterate
#sin.print_blocks
sin.print_messages
sem = Semantic.new(sin.blocks, sin.messages)
sem.test