require 'singleton'
require_relative 'tokens'


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

class Tokenizer
	
	COMMAND = 0
	ARGS = 1
	
	attr_accessor :line 
	attr_accessor :current_length
	attr_accessor :state
	attr_accessor :flags_table
	attr_accessor :commands_table


	def initialize(line)
		@line = line
		@current_length = 1
		@state = COMMAND
		@flags_table = FlagsTable.instance
		@commands_table = CommandTable.instance
	end

	def get_next
		out = {}
		if line.length <= 0
			out["status"] = "over"
			return out
		end
		token = line.split(" ").first
		if @state == COMMAND
			if @commands_table.command?(token)
				command = Command.new(token,@current_length)
				out["command"] = command
			else
				message = Message.new(true,"unknown command: #{@current_length}: #{token}")
				out["message"] = message
			end
			@state = ARGS
		elsif @state == ARGS
			if token.start_with?("-")
				flag = Flag.new(token,@current_length)
				out["flag"] = flag
			elsif token.start_with?("|")
				out["pipe"] = token
				@state = COMMAND
			else
				argument = Argument.new(token,@current_length)
				out["argument"] = argument
			end
		end
		@line.sub!(token,"").strip!
		@current_length += token.length+1
		return out
	end
end

tok = Tokenizer.new("Make-Object -directory dir-dir | Rename-Object -directory new_dir | Make-Object ./$_/inside.txt | Zip-Object -recursive dir-dir")

loop do
	token = tok.get_next 
	puts token
	break if token["status"] == "over"
end

