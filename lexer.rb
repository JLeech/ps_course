require 'singleton'
require_relative 'tokens'
require_relative 'tables'
require_relative 'tokenizer'

class Lexer

	ERROR = 0
	PARSE = 1

	COMMAND = Tokenizer::COMMAND
	MESSAGE = Tokenizer::MESSAGE
	FLAG = Tokenizer::FLAG
	PIPE = Tokenizer::PIPE
	ARGUMENT = Tokenizer::ARGUMENT	


	attr_accessor :blocks
	attr_accessor :messages
	attr_accessor :tokenizer
	attr_accessor :flags_table
	attr_accessor :state
	
	def initialize(line)
		@blocks = []
		@messages = []
		@tokenizer = Tokenizer.new(line)
		@flags_table = FlagsTable.instance
		@state = PARSE
	end

	def no_error
		return false if @state == ERROR
		return true 
	end

	def print_messages
		@messages.each { |mes| puts mes.text }
	end


	def iterate
		command = Command.new
		loop do
			token = @tokenizer.get_next 
			if token.has_key?(MESSAGE)
				@messages.push(token[MESSAGE])
				@state = ERROR
			end
			if (no_error) &&  token.has_key?(COMMAND)
				command = token[COMMAND]	
			end
			if (no_error) && token.has_key?(FLAG)
				if @flags_table.has_flag?(command, token[FLAG])
					command.flags.push(token[FLAG].name)
				else
					message = Message.new(true,"#{token[FLAG].position} : unknown flag #{token[FLAG].name}")
					@messages.push(message)
					@state = ERROR
				end
			end
			if  (no_error) && token.has_key?(ARGUMENT)
				command.arguments.push(token[ARGUMENT])
			end
			if token.has_key?(PIPE)
				if (no_error)
					@blocks.push(command)
					@blocks.push(token[PIPE])
					command.print
					@blocks.last.print
				else
					@state = PARSE
				end
				command = Command.new
			end
			if token["status"] == Tokenizer::OVER
				if (no_error)
					command.print
					@blocks.push(command)
				end
				break
			end
		end
	end
end


command1 = "Make-Object -directory dir-dir | Rename-Object -directory new_dir | Make-Object ./$_/inside.txt | Zip-Object -recursive dir-dir"
command2 = "Make-Object -directory dir-dir | Print-File -quiet list.txt |each Make-Object dir-dir/$_.txt"

lex = Lexer.new(command1)
lex.iterate
#lex.blocks.each { |command| puts command.name }
