require 'singleton'
require 'pathname'
require_relative 'token/tokens'
require_relative 'token/tables'


class Interpreter

	attr_accessor :type_line
	attr_accessor :blocks
	attr_accessor :current_path

	def initialize(type_line,blocks)
		@type_line = type_line
		@blocks = blocks
		@current_path = File.dirname(__FILE__)
	end

	def run
		if run?
			execute_commands
		end
	end

	def execute_commands
		result = []
		blocks.each do |block|
				result = execute(block,result)
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
		end
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
			argument = block.arguments.first
			argument.name = "#{current_path}/" + "#{argument.name[2..-1]}" if argument.name.start_with?("./")
			argument.name.gsub!(Argument::INSERT,"#{result}") if argument.has_insertion?

		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		if recursive 
			files =  Dir.entries(argument.name)
			files.delete_if { |file| file =~ /(^\.*$)/}
			puts "#{files}"
		else
		end
		

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

		origin,rename = block.arguments if block.arguments.count > 1
		rename = block.arguments.first if block.arguments.count == 1
		
		if @type_line.first == "string,string"
			
			origin.name.gsub!(Argument::INSERT,"#{File.basename(result)}") if origin.has_insertion?
			rename.name.gsub!(Argument::INSERT,"#{result}") if rename.has_insertion?	

			origin.name = modify_to_full_path(origin.name)
			rename.name = modify_to_full_path(rename.name)
			
			rename_existing(rename.name,force)

			File.rename(origin.name,rename.name)

		elsif @type_line.first == "pipe,string"
			unless object
				rename.name.gsub!(Argument::INSERT,"#{result.first}") if rename.has_insertion?
				rename.name = modify_to_full_path(rename.name)
				
				rename_existing(rename.name,force)
				File.rename(result,rename.name)
			
			else
				rename.name = "#{File.dirname(result.first)}/#{rename.name}"
			end

		elsif @type_line.first == "pipe,pipe"
			#TODO
		end
		@type_line = @type_line.drop(1)
		return rename.name

	end

	def rename_existing(name,force)
		if ( (File.exist?(name)) && (force) )
			File.rename(name,"#{name}_#{rand(500)}")	
		end
	end

	def modify_to_full_path(path)
		"#{current_path}/#{path}"
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
			argument = block.arguments.first
		elsif @type_line.first == "pipe"
			argument = Argument.new(result.first)
		end

		if hidden
			new_str = argument.name.reverse.sub(File.basename(argument.name).reverse,"#{File.basename(argument.name).reverse}.").reverse
			argument.name = new_str
		end

		@type_line = @type_line.drop(1)
		argument.name = modify_to_full_path(argument.name)
		
		argument.name.gsub!(Argument::INSERT,"#{File.basename(result)}") if argument.has_insertion?
		
		FileUtils.rm_rf(argument.name) if force
		if file
			tmp = File.open("#{argument.name}","w") unless File.exist?("#{argument.name}")
			tmp.close
			out = "#{argument.name}"
		else
			Dir.mkdir("#{argument.name}") unless File.exist?("#{argument.name}")
			out = "#{argument.name}"
		end
		`chmod -x #{argument.name}` if exec
		result = out
	end

end