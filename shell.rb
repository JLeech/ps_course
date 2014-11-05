require 'curses'

Curses.noecho # do not show typed keys
Curses.init_screen
Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)


line = ""
@cur_x = 0
@cur_y = 0

def move_cursor_right
	@cur_x +=1 if @cur_x < Curses.cols
	Curses.setpos(@cur_y,@cur_x)
end

def move_cursor_left
	@cur_x -=1 if @cur_x > 0	
	Curses.setpos(@cur_y,@cur_x)
end

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