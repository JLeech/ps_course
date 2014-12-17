require 'singleton'
require 'pathname'

require_relative 'token/tokens'
require_relative 'token/tables'
require_relative 'insertions'


class Interpreter

	attr_accessor :type_line
	attr_accessor :blocks
	attr_accessor :current_path
	attr_accessor :current_arg

	attr_accessor :in_accu
	attr_accessor :in_each

	def initialize(type_line,blocks)
		@type_line = type_line
		@blocks = blocks
		@current_path = File.dirname(__FILE__)
		@in_accu = false
		@in_each = false
		@current_arg = ""
	end

	def run
		if run?
			execute_commands
		else
			puts "Some errors occured during parsing. Check log."
		end
	end

	def execute_commands
		tmp_result = []
		result = []
		blocks.each do |block|
			@current_arg = result.first
			if @in_accu
				tmp_result = execute(block,result)
				result << tmp_result
				result.flatten!
				@in_accu = false
			elsif @in_each
				each_result = []
				result.each do |argument|
					@current_arg = argument
					each_result << execute(block,result)
				end
				drop_type_line
				result = each_result
				result.flatten!
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
			puts result
			if block.is_make_object?
				result = execute_make_object(block,result)
			end
			if block.is_rename_object?
				result = execute_rename_object(block,result)
			end
			if block.is_zip_object?
				result = execute_zip_object(block,result)
			end
			if block.is_unzip_object?
				result = execute_unzip_object(block,result)
			end
			if block.is_print_file?
				result = execute_print_file(block,result)
			end
			if block.is_remove_object?
				result = execute_remove_object(block,result)
			end
			if block.is_current_directory?
				result = execute_current_directory(block,result)
			end
			if block.is_change_directory?
				result = execute_change_directory(block,result)
			end
			if block.is_list_objects?
				result = execute_list_objects(block,result)
			end			
			drop_type_line
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

	def execute_current_directory(block,result)
		puts current_path
		return [@current_path]
	end

	def execute_change_directory(block,result)
		create = false

		block.flags.each do |flag|
			case flag
			when  "-create"
				create = true
			end
		end

		if @type_line.first == "string"
			argument = block.arguments.first.get_copy
		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		argument = process_insertion(argument,result)
		@current_path = argument.name
		
		puts @current_path

		return [argument.name]
	end

	def execute_remove_object(block,result)


		if @type_line.first == "string"
			argument = block.arguments.first.get_copy
		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		argument = process_insertion(argument,result)

		`rm -rf #{argument.name}`
		return [argument.name]

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
		
		argument = process_insertion(argument,result)

		if hidden
			new_str = argument.name.reverse.sub(File.basename(argument.name).reverse,"#{File.basename(argument.name).reverse}.").reverse
			argument.name = new_str
		end
		Dir.chdir (File.dirname(argument.name)){
			`rm -rf #{argument.name}` if force
		}
		if file
			unless File.exist?("#{argument.name}")
				tmp = File.open("#{argument.name}","w") 
				tmp.close
			end
			out = "#{argument.name}" if File.exist?("#{argument.name}")
		else
			Dir.mkdir("#{argument.name}") unless File.exist?("#{argument.name}")
			out = "#{argument.name}"
		end
		Dir.chdir (File.dirname(argument.name)){
			`chmod -x #{argument.name}` if exec
		}
		return [out]
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

		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		argument = process_insertion(argument,result)

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
		return result
	end

	def execute_zip_object(block,result)
		recursive = false

		if @type_line.first == "string"
			argument = block.arguments.first.get_copy

		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		argument = process_insertion(argument,result)

		Dir.chdir (File.dirname(argument.name)){
			unless recursive 
				files =  Dir.entries(argument.name)
				files.delete_if { |file| file =~ /(^\.*$)/}
				files.each do |file|
					Dir.chdir (argument.name){
						`zip -r #{argument.name}/#{file} {file}`
					}
				end
				`zip -r #{argument.name} #{File.basename(argument.name)}`
			else
				`zip -r #{argument.name} . -i #{File.basename(argument.name)}`
			end
		}
		return ["#{argument.name}.zip"]
	end

	def execute_unzip_object(block,result)
		recursive = false

		if @type_line.first == "string"
			argument = block.arguments.first.get_copy

		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		argument = process_insertion(argument,result)

		Dir.chdir (File.dirname(argument.name)){
			unless recursive 
				`unzip #{argument.name}`
			else
				`unzip #{argument.name}`
			end
		}
		argument.name.gsub!(".zip","")
		return [argument.name]
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

			origin = process_insertion(origin,result)
			rename = process_insertion(rename,result)

			rename_existing(rename.name,force)

			File.rename(origin.name,rename.name)

		elsif @type_line.first == "pipe,string"

			rename = process_insertion(rename,result)

			unless object
				
				rename_existing(rename.name,force)
				File.rename(result.first,rename.name)
			
			else
				rename.name = "#{File.dirname(result.first)}/#{rename.name}"
			end

		elsif @type_line.first == "pipe,pipe"
			
			unless object
				rename_existing(result[1],force)
				File.rename(result[0],result[1])
			else
				rename.name = result[1]
			end
		end
		return [rename.name]
	end

	def execute_list_objects(block,result)
		recursive = false
		hidden = false

		block.flags.each do |flag|
			case flag
			when  "-recursive"
				recursive = true
			when "-hidden"
				hidden = true
			end

		end

		if @type_line.first == "string"
			argument = block.arguments.first.get_copy

		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		argument = process_insertion(argument,result)

		if hidden
			files =  Dir.entries(argument.name).delete_if { |file| file =~ /(^\.*$)/}
		else
			files = Dir.entries(argument.name).delete_if { |file| file =~ /(^\.+[a-z]*)/}
		end
		puts files
		return [files]
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
		argument.name = Insertions.new(argument.name,pipe,@current_arg).process_insertions if argument.has_insertion?
		argument.name = "#{@current_path}/" + "#{argument.name[2..-1]}" if argument.name.start_with?("./")
		return argument
	end
end