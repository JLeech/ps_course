require 'singleton'
require_relative 'tokens'
require_relative 'tables'


class Tokenizer
	
	LF_COMMAND = 0
	LF_ARGS = 1
	OVER = 2

	COMMAND = "command"
	MESSAGE = "message"
	FLAG = "flag"
	PIPE = "pipe"
	ARGUMENT = "argument"

	attr_accessor :line 
	attr_accessor :current_length
	attr_accessor :state
	attr_accessor :commands_table


	def initialize(line)
		@line = line
		@current_length = 1
		@state = LF_COMMAND
		@commands_table = CommandTable.instance
	end

	def get_next
		out = {}
		if line.length <= 0
			out["status"] = OVER
			return out
		end
		token = line.split(" ").first
		if @state == LF_COMMAND
			if @commands_table.command?(token)
				command = Command.new(token,@current_length)
				out[COMMAND] = command
			else
				message = Message.new(true,"#{@current_length}: unknown command #{token}")
				out[MESSAGE] = message
			end
			@state = LF_ARGS
		elsif @state == LF_ARGS
			if token.start_with?("-")
				flag = Flag.new(token,@current_length)
				out[FLAG] = flag
			elsif token.start_with?("|")
				out[PIPE] = token
				@state = LF_COMMAND
			else
				argument = Argument.new(token,@current_length)
				out[ARGUMENT] = argument
			end
		end
		@line.sub!(token,"").strip!
		@current_length += token.length+1
		return out
	end
end

class Lexer

	ERROR = 0
	PARSE = 1

	COMMAND = Tokenizer::COMMAND
	MESSAGE = Tokenizer::MESSAGE
	FLAG = Tokenizer::FLAG
	PIPE = Tokenizer::PIPE
	ARGUMENT = Tokenizer::ARGUMENT	


	attr_accessor :commands
	attr_accessor :tokenizer
	attr_accessor :flags_table
	attr_accessor :state
	
	def initialize(line)
		@blocks = []
		@tokenizer = Tokenizer.new(line)
		@flags_table = FlagsTable.instance
		@state = PARSE
	end

	def no_error
		return false if @state == ERROR
		return true 
	end

	def iterate
		command = Command.new("",1)
		loop do
			token = @tokenizer.get_next 
			if token.has_key?(MESSAGE)
				puts "#{token[MESSAGE].text}"
				@state = ERROR
			end
			if token.has_key?(COMMAND) && (no_error)
				command = token[COMMAND]	
			end
			if token.has_key?(FLAG) && (no_error)
				if @flags_table.has_flag?(command, token[FLAG])
					command.flags.push(token[FLAG].name)
				else
					puts "#{token[FLAG].position} : unknown flag #{token[FLAG].name}"
					@state = ERROR
				end
			end
			if token.has_key?(ARGUMENT) && (no_error)
				command.arguments.push(token[ARGUMENT].name)
			end
			if token.has_key?(PIPE)
				if (no_error)
					command.print
					@blocks.push(command)
					command = Command.new("",1)
				else
					@state = PARSE
					command = Command.new("",1)
				end
			end
			if token["status"] == Tokenizer::OVER
				if (no_error)
					command.print
					@blocks.push(command)
				end
				puts @blocks
				break
			end
		end
	end


end


lex = Lexer.new("Make-Object -directory dir-dir | Rename-Object -directory new_dir | Make-Object ./$_/inside.txt | Zip-Object -recursive dir-dir")
lex.iterate

