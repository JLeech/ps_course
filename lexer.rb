require 'singleton'

class Command

	attr_accessor :name
	attr_accessor :flags
	attr_accessor :arguments

	def initialize(token)

	end

end

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

class FlagsTable
	include Singleton

	attr_accessor :flags
	attr_accessor :file

	def initialize
		@file = "flags.txt"
		@flags = {}
		lines = IO.readlines(@file)
		lines.each { |line| line.chomp! }
		lines.each do |line|
			words = line.split(" ")
			@flags[words.first] = words.drop(1)
		end
	end

	def has_flag?(command,flag)
		return true if @flags[command].include?(flag)
		return false
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

	def command?(token)
		if @commands.include?(token)
			return true
		else
			return false
		end
	end
end

class Lexer
	attr_accessor :pre_tokens
	attr_accessor :state
	attr_accessor :line
	attr_accessor :messages

	COMMAND = 0
	ARGS = 1

	def initialize(line)
		@pre_tokens = line.split(" ")
		@state = COMMAND
		@tokens = []
		@messages =[]
	end

	def parse_tokens

	end

	def get_token
		@pre_tokens.each do |tok|
			puts tok
		end
	end

end

ft = FlagsTable.instance
lex = Lexer.new("Make-Object -directory dir-dir | Rename-Object -directory new_dir | Make-Object ./$_/inside.txt | Zip-Object -recursive dir-dir")
puts ft.has_flag?("Make-Object","-directory")



