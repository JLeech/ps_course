require_relative 'sintax'
require_relative 'semantic'

command1 = "Make-Object -directory dir-dir | Rename-Object -directory new_dir | Make-Object ./$_/inside.txt | Zip-Object -recursive dir-dir"
command2 = "Make-Object -directory dir-dir |accu Print-File -quiet files.txt |each Make-Object $_[0]/$_.txt | Remove-Object $_[0]$name/$_[0]" 
command3 = "Diff-Files xxx"
sin = Sintax.new(command2)
sin.iterate
#sin.print_blocks
#sin.print_messages
sem = Semantic.new(sin.blocks, sin.messages)
sem.types_check
sem.print