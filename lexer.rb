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
	end
end