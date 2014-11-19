require 'singleton'
require_relative 'token/tokens'
require_relative 'token/tables'

class Semantic

	attr_accessor :blocks
	attr_accessor :messages
	attr_accessor :types_table
	attr_accessor :error

	def initialize(blocks, messages)
		@blocks = blocks
		@messages = messages
		@types_table = TypesTable.instance
		@error = false
	end

	def print
		blocks.each { |block| block.print }
	end
 
	def types_check
		in_pipe = []
		blocks.each do |block|
			if (block.class.to_s == Command.name.to_s)
				should_be_in = @types_table.types[block.name]["in"]
				puts check_args(block.arguments,should_be_in,in_pipe)
			end
		end
	end

private 
	
	def  check_args(command_args, should, in_pipe_args)
		income_args_count = command_args.count + in_pipe_args.count
		out = ""
		match_found = false
		should.each do |nec_args|
			if (split_args(nec_args).count == income_args_count)
				if (split_args(nec_args).keep_if{ |arg| arg == "string" }.count == command_args.count)
					if (split_args(nec_args).count != command_args.length)
						if (split_args(nec_args).keep_if{ |arg| arg == "pipe" }.count == in_pipe_args.count)
							out = nec_args
							match_found = true
						else 
							@error = true
						end
					else
						out = nec_args
						match_found = true
					end
				end
			end
		end
		if match_found == false
			@error = true
		end
		return out
	end

	def split_args(args)
		return args.split(",")
	end

end