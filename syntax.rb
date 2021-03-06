require 'singleton'
require_relative 'token/tokens'
require_relative 'token/tables'
require_relative 'tokenizer'

class Syntax
	
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
	attr_accessor :skeleton
	
	def initialize(line)
		@blocks = []
		@messages = []
		@tokenizer = Tokenizer.new(line)
		@flags_table = FlagsTable.instance
		@state = PARSE
		@skeleton = File.open("sceleton.txt","w+")
		@skeleton.write("\n#{line}\n\n")
		@skeleton.close
	end

	def no_error
		return false if @state == ERROR
		return true 
	end

	def print_messages
		@skeleton = File.open("sceleton.txt","a+")
		@messages.each { |mes| @skeleton.write(mes.text) }
		@skeleton.close
	end

	def print_blocks
		@skeleton = File.open("sceleton.txt","a+")
		@blocks.each { |command| command.print }
		puts @blocks.length
		@skeleton.close
	end

	def iterate
		command = Command.new
		loop do
			token = @tokenizer.get_next
			if token.has_key?(MESSAGE)
				@messages.push(token[MESSAGE])
				command = token[COMMAND]
				@blocks.push(command)
				@state = ERROR

			end
			if (no_error) &&  token.has_key?(COMMAND)
				command = token[COMMAND]
			end
			if (no_error) && token.has_key?(FLAG)
				if @flags_table.has_flag?(command, token[FLAG])
					command.flags.push(token[FLAG].name)
				else
					message = Message.new(true, Message.unknown_flag(token[FLAG].position,token[FLAG].name))
					@messages.push(message)
					command.error = true
					@blocks.push(command)
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
				else
					@blocks.push(token[PIPE])
					@state = PARSE
				end
				command = Command.new
			end
			if token["status"] == Tokenizer::OVER
				if (no_error)
					@blocks.push(command)
				end
				break
			end
		end
		
		print_messages
	end

end
