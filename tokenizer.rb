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
				pipe = Pipe.new(token,@current_length)
				out[PIPE] = pipe
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