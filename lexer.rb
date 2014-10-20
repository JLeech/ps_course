require 'singleton'
require_relative 'tokens'
require_relative 'tables'


class Tokenizer
	
	COMMAND = 0
	ARGS = 1
	
	OVER = 2

	attr_accessor :line 
	attr_accessor :current_length
	attr_accessor :state
	attr_accessor :commands_table


	def initialize(line)
		@line = line
		@current_length = 1
		@state = COMMAND
		@commands_table = CommandTable.instance
	end

	def get_next
		out = {}
		if line.length <= 0
			out["status"] = OVER
			return out
		end
		token = line.split(" ").first
		if @state == COMMAND
			if @commands_table.command?(token)
				command = Command.new(token,@current_length)
				out["command"] = command
			else
				message = Message.new(true,"#{@current_length}: unknown command #{token}")
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

class Lexer

	ERROR = 0
	PARSE = 1

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
			if token.has_key?("message")
				puts "#{token['message'].text}"
				@state = ERROR
			end
			if token.has_key?("command") && (no_error)
				command = token["command"]	
			end
			if token.has_key?("flag") && (no_error)
				if @flags_table.has_flag?(command, token["flag"])
					command.flags.push(token["flag"].name)
				else
					puts "#{token['flag'].position} : unknown flag #{token['flag'].name}"
					@state = ERROR
				end
			end
			if token.has_key?("argument") && (no_error)
				command.arguments.push(token["argument"].name)
			end
			if token.has_key?("pipe")
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

