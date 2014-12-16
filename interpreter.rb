require 'singleton'
require 'pathname'

require_relative 'token/tokens'
require_relative 'token/tables'
require_relative 'insertions'


class Interpreter

	attr_accessor :type_line
	attr_accessor :blocks
	attr_accessor :current_path

	attr_accessor :in_accu
	attr_accessor :in_each

	def initialize(type_line,blocks)
		@type_line = type_line
		@blocks = blocks
		@current_path = File.dirname(__FILE__)
		@in_accu = false
		@in_each = false
	end

	def run
		if run?
			execute_commands
		else
			puts "Some errors occured during parsing. Check log and retry."
		end
	end

	def execute_commands
		tmp_result = []
		result = []
		blocks.each do |block|
			if @in_accu
				tmp_result = execute(block,result)
				result << tmp_result
				result.flatten!
				@in_accu = false
			elsif @in_each
				each_result = []
				result.each do |argument|
					each_result << execute(block,[argument])
				end
				drop_type_line
				result = each_result
				@in_each = false
			else
				result = execute(block,result)			
			end
		end
	end

	def run?
		blocks.each do |block|
			if ((block.class.to_s == Command.name.to_s))
				return false if block.error 
			end
		end
		return true
	end

	def execute(block,result)
		if ((block.class.to_s == Command.name.to_s))
			if block.is_make_object?
				result = execute_make_object(block,result)
			end
			if block.is_rename_object?
				result = execute_rename_object(block,result)
			end
			if block.is_zip_object?
				result = execute_zip_object(block,result)
			end
			if block.is_print_file?
				result = execute_print_file(block,result)
			end
			if block.is_remove_object?
				result = execute_remove_object(block,result)
			end
		end
		if ((block.class.to_s == Pipe.name.to_s))
			if block.type == Pipe::ACCUMULATE
				@in_accu = true
			end
			if block.type == Pipe::EACH
				@in_each = true
			end
		end
		return result
	end

	def execute_remove_object(block,result)

		if @type_line.first == "string"
			argument = block.arguments.first.get_copy
		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		argument.name = "#{current_path}/" + "#{argument.name[2..-1]}" if argument.name.start_with?("./")
		
		argument.name.gsub!(Argument::INSERT,"#{File.basename(result)}") if argument.has_insertion?

		`rm -rf #{argument.name}`

	end


	def execute_make_object(block,result)
		file = true
		hidden = false
		exec = false
		force = false

		block.flags.each do |flag|
			case flag
			when "-directory"
				file = false
			when  "-hidden"
				hidden = true
			when "-exec"
				exec = true
			when "-force"
				force = true
			end
		end
		if @type_line.first == "string"
			argument = block.arguments.first.get_copy

		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		drop_type_line
		
		

		argument.name = "#{current_path}/" + "#{argument.name[2..-1]}" if argument.name.start_with?("./")
		
		argument.name = Insertions.new(argument.name,@result).process_insertions if argument.has_insertion?
		
		if hidden
			new_str = argument.name.reverse.sub(File.basename(argument.name).reverse,"#{File.basename(argument.name).reverse}.").reverse
			argument.name = new_str
		end

		`rm -rf #{argument.name}` if force
		if file
			tmp = File.open("#{argument.name}","w") unless File.exist?("#{argument.name}")
			tmp.close	unless File.exist?("#{argument.name}")
			out = "#{argument.name}" unless File.exist?("#{argument.name}")
		else
			Dir.mkdir("#{argument.name}") unless File.exist?("#{argument.name}")
			out = "#{argument.name}"
		end
		`chmod -x #{argument.name}` if exec
		result = [out]
	end


	def execute_print_file(block,result)
		quiet = false

		block.flags.each do |flag|
			case flag
			when  "-quiet"
				quiet = true
			end
		end

		if @type_line.first == "string"
			argument = block.arguments.first.get_copy
			argument.name = "#{current_path}/" + "#{argument.name[2..-1]}" if argument.name.start_with?("./")
			argument.name.gsub!(Argument::INSERT,"#{result}") if argument.has_insertion?

		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		file_data = []
		file = File.new(argument.name, "r")
		while (line = file.gets)
    		file_data << line.chomp
		end
		file.close

		if quiet
			result = file_data
		else
			puts file_data
		end
		
		drop_type_line
		return result

	end

	def execute_zip_object(block,result)
		recursive = false

		block.flags.each do |flag|
			case flag
			when  "-recursive"
				recursive = true
			end
		end

		if @type_line.first == "string"
			argument = block.arguments.first.get_copy
			argument.name = "#{current_path}/" + "#{argument.name[2..-1]}" if argument.name.start_with?("./")
			argument.name.gsub!(Argument::INSERT,"#{result}") if argument.has_insertion?

		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		if recursive 
			files =  Dir.entries(argument.name)
			files.delete_if { |file| file =~ /(^\.*$)/}
			files.each do |file|
				`zip -r #{argument.name}/#{file} {file}`
			end
			`zip -r #{argument.name} #{File.basename(argument.name)}`
		else

		end
		drop_type_line

	end

	def execute_rename_object(block,result)
		object = false
		force = false
		block.flags.each do |flag|
			case flag
			when  "-object"
				object = true
			when "-force"
				force = true
			end

		end

		origin,rename = Array.new(block.arguments) if block.arguments.count > 1
		rename = block.arguments.first.get_copy if block.arguments.count == 1
		
		if @type_line.first == "string,string"
			
			origin.name.gsub!(Argument::INSERT,"#{File.basename(result.first)}") if origin.has_insertion?
			rename.name.gsub!(Argument::INSERT,"#{File.basename(result.first)}") if rename.has_insertion?	

			origin.name = modify_to_full_path(origin.name)
			rename.name = modify_to_full_path(rename.name)
			
			rename_existing(rename.name,force)

			File.rename(origin.name,rename.name)

		elsif @type_line.first == "pipe,string"
			unless object
				rename.name.gsub!(Argument::INSERT,"#{result.first}") if rename.has_insertion?
				rename.name = modify_to_full_path(rename.name)
				
				rename_existing(rename.name,force)
				File.rename(result.first,rename.name)
			
			else
				rename.name = "#{File.dirname(result.first)}/#{rename.name}"
			end

		elsif @type_line.first == "pipe,pipe"
			#TODO
		end
		drop_type_line
		return [rename.name]

	end

	def rename_existing(name,force)
		if ( (File.exist?(name)) && (force) )
			File.rename(name,"#{name}_#{rand(500)}")	
		end
	end

	def drop_type_line
		@type_line = @type_line.drop(1) unless @in_each
	end

	def modify_to_full_path(path)
		"#{current_path}/#{path}"
	end

	def process_insertion(argument,pipe)

	end
end