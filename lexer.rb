require 'singleton'

class Position
	attr_accessor :line
	attr_accessor :position

	def initialize (line, pos)
		@line = line
		@position = pos
	end
end

class Fragment
	attr_accessor :start
	attr_accessor :finish

	def initialize(start,finish)
		@start = start
		@finish = finish
	end
end

class Message
	attr_accessor :error
	attr_accessor :text

	def initialize(error,text)
		@error = error
		@text = text
	end

	def isError?
		return error
	end
end

class CommandTable
	include Singleton

	attr_accessor :commands
	attr_accessor :file

	def initialize
		@file = "commands.txt"
		@commands = IO.readlines(@file)
		@commands.each { |command| command.chomp! }
	end
end

module LexerState
	
	COMMAND = 0
	FLAGS = 1
	ARGUMENTS = 2
	PIPE = 3

end

class Lexer
	include LexerState
	attr_accessor :pre_tokens
	attr_accessor :state
	attr_accessor :line
	attr_accessor :messages

	def initialize(line)
		@pre_tokens = line.split(" ")
		@state = COMMAND
		@tokens = []
		@messages =[]
	end

	def get_token
		@pre_tokens.each do |tok|
			puts tok
		end
	end

end

ct = CommandTable.instance
lex = Lexer.new("Make-Object -directory dir-dir | Rename-Object -directory new_dir | Make-Object  ./$_/inside.txt | Zip-Object -recursive dir-dir")
lex.get_token