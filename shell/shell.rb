#http://www.ruby-doc.org/stdlib-2.0/libdoc/curses/rdoc/Curses.html#method-c-cbreak
#http://www.ruby-doc.org/stdlib-2.0/libdoc/curses/rdoc/Curses/Key.html


require 'curses'
require_relative 'sintax'

class Shell 

	attr_accessor :line
	attr_accessor :cur_x
	attr_accessor :cur_y
	attr_accessor :command_line_start
	attr_accessor :command_line_end

	def initialize
		Curses.noecho # do not show typed keys
		Curses.init_screen
		Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)		
		
		Curses.setpos(0,0)
		Curses.insch(">")
		@cur_x = 1
		@cur_y = 0
		move_cursor_right
		@line = ""
		@command_line_start = 0
		@command_line_end = 0
	end

	def new_command
		Curses.setpos(@cur_y+1,0)
		Curses.insch(">")
		@cur_x = 1
		@cur_y += 1
		move_cursor_right
		@line = ""
	end
	
	def move_cursor_right
		if @cur_x < Curses.cols
			@cur_x += 1 
		else
			@cur_y += 1
			@cur_x = 0 
		end
		Curses.setpos(@cur_y,@cur_x)
	end	

	def move_cursor_left
		if @cur_x > 1
			@cur_x -= 1
		else
			@cur_x = Curses.cols
			@cur_y -= 1 if @cur_y >=0
		end
		
		Curses.setpos(@cur_y,@cur_x)
	end	


	def start
		loop do
			  char = Curses.getch 
			case char		

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
					Curses.doupdate
				when Curses::Key::UP
					line = ""
					Curses.cols.times do 
						line += Curses::keyname(Curses.inch)
						@cur_x -= 1
						Curses.setpos(@cur_y,@cur_x)
					end
					sin = Sintax.new(line.reverse)
					new_command
					sin.iterate
				else
					Curses.insch(char)
					@line += Curses::keyname(char)
					move_cursor_right
			end
		end
	end

end

shell = Shell.new

shell.start