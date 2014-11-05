#http://www.ruby-doc.org/stdlib-2.0/libdoc/curses/rdoc/Curses.html#method-c-cbreak
#http://www.ruby-doc.org/stdlib-2.0/libdoc/curses/rdoc/Curses/Key.html


require 'curses'


class Shell 

	attr_accessor :line
	attr_accessor :cur_x
	attr_accessor :cur_y

	def initialize
		Curses.noecho # do not show typed keys
		Curses.init_screen
		Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)		
		
		Curses.setpos(0,0)
		Curses.insch(">")
		@cur_x = 1
		@cur_y = 0
		move_cursor_right
	end

	def new_command
		@line = ""
	end
	
	def move_cursor_right
		@cur_x +=1 if @cur_x < Curses.cols
		Curses.setpos(@cur_y,@cur_x)
	end	

	def move_cursor_left
		@cur_x -=1 if @cur_x > 1	
		Curses.setpos(@cur_y,@cur_x)
	end	


	def start
		loop do
			  char = Curses.getch 
			case char
				when Curses::Key::UP		

				when Curses::Key::LEFT 
					move_cursor_left
				when Curses::Key::SLEFT 
					move_cursor_left
				when Curses::Key::RIGHT	
					move_cursor_right
				when Curses::Key::SRIGHT
					move_cursor_right
				when Curses::Key::BACKSPACE
					move_cursor_left
					Curses.delch
				else
					Curses.insch(char)
					move_cursor_right
			end
		end
	end

end

shell = Shell.new

shell.start