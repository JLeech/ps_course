
require_relative 'token/tokens'
require_relative 'token/tables'

class Semantic

	ARRAY = "array"
	STRING = "string"
	FILE = "file"
	PIPE = "pipe"

	attr_accessor :blocks
	attr_accessor :messages
	attr_accessor :types_table
	attr_accessor :error
	attr_accessor :type_line
	attr_accessor :accumulate
	attr_accessor :each

	def initialize(blocks, messages)
		@blocks = blocks
		@messages = messages
		@types_table = TypesTable.instance
		@error = false
		@type_line = []
		@accumulate = false
		@each = false
	end

	def print
		blocks.each { |block| block.print }
	end
 
	def types_check
		in_pipe = ""
		blocks.each do |block|
			if ((block.class.to_s == Command.name.to_s))
				unless block.error 
					if block.arguments.count > @types_table.types[block.name]["in"].first.split(",").count
						@error = true
						block.error = true
						should_be_in = @types_table.types[block.name]["in"]
						block.print_error(error_message(block,should_be_in,in_pipe)) if @error
					end
				end

				if @each
					in_pipe = PIPE
				end

				unless block.error

					should_be_in = @types_table.types[block.name]["in"]
					args_places = check_args(block.arguments,should_be_in,in_pipe)
					block.print_error(error_message(block,should_be_in,in_pipe)) if @error 
					 
					in_pipe = @types_table.types[block.name]["out"].first
					add_type(args_places)	

					@error = false
				else
					type_line.push("error")	
				end
				if @each
					#in_pipe = ARRAY
				end

				@each = false
			end
			if (block.class.to_s == Pipe.name.to_s)
				#in_pipe = ARRAY if accumulate
				determine_block_type(block)
			end

		end
		puts "#{type_line}"
		return type_line
	end

private 
	
	def determine_block_type(block)
		@accumulate = false
		if (block.type == Pipe::ACCUMULATE)
			@accumulate = true
		end
		if (block.type == Pipe::EACH)
			@each = true
		end
	end

	def add_type(type)
		if type.nil?
			@type_line.push("nil")
		else 
			@type_line.push(type)
		end
	end

	def error_message(command, should, in_pipe_args)
		"Type error occured in commad #{command.name} #{command.position}. Expect types: #{should}.
		 Got: #{command.args_as_string} pipe: #{in_pipe_args}\n"
	end

	def check_args(command_args, should, in_pipe_args)

		income_args_count = command_args.count
		
		income_args_count +=1 if (in_pipe_args == STRING)
		income_args_count +=1 if (in_pipe_args == FILE)
		income_args_count +=1 if (in_pipe_args == PIPE)
		out = ""
		match_found = false


		should.each do |nec_args|
			if in_pipe_args == ARRAY
				match_found = true
				break
			end
			if (split_args(nec_args).count == income_args_count)
				if (split_args(nec_args).keep_if{ |arg| arg == PIPE }.count == 1)
					if (split_args(nec_args).keep_if{ |arg| arg == STRING }.count == command_args.count)
						out = nec_args
						match_found = true
						break
					end
				end
			end
			if (split_args(nec_args).count == command_args.count)
				if (split_args(nec_args).keep_if{ |arg| arg == STRING }.count == command_args.count)
					out = nec_args
					match_found = true
					break
				end
			end
		end
		if match_found == false
			@error = true
		end
		return out
	end

	def check_exist(args)
		return 1 if args.count ==1
	end

	def split_args(args)
		return args.split(",")
	end

end