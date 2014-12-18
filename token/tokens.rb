class Argument
	
	INSERT = "$_"

	attr_accessor :name
	attr_accessor :position
	attr_accessor :insertion

	def initialize(name,position= "0")
		@name = name
		@position = position
		@insertion = @name.index(INSERT)
	end

	def has_insertion?
		return !@insertion.nil?
	end

	def as_string
		"string: \"#{@name}\","
	end

	def get_copy
		arg = Argument.new(name.clone,position)
		arg.insertion = insertion
		return arg
	end
end

class Pipe
	USUAL = "|"
	ACCUMULATE = "accu"
	EACH = "each"
	OVER = "end"

	attr_accessor :name
	attr_accessor :type
	attr_accessor :position
	attr_accessor :skeleton

	def initialize(name,position)
		@name = name
		@position = position
		@type = def_type
		@skeleton = File.open("sceleton.txt","a")
	end

	def def_type
		type = ACCUMULATE if @name.end_with?(ACCUMULATE)
		type = EACH if @name.end_with?(EACH)
		type = OVER if @name.end_with?(OVER)
		type = USUAL if @name == USUAL
		return type
	end

	def print
		@skeleton = File.open("sceleton.txt","a")
		@skeleton.write(": #{@name} : #{@position}\n")
		@skeleton.write(":    #{type}\n")
		@skeleton.write("-------------\n")
		@skeleton.close
	end

end

class Flag
	attr_accessor :name
	attr_accessor :position

	def initialize(name,position)
		@name = name
		@position = position
	end
end

class Command

	attr_accessor :name
	attr_accessor :flags
	attr_accessor :arguments
	attr_accessor :position
	attr_accessor :skeleton
	attr_accessor :error

	def initialize(name = "",position = 0)
		@name = name
		@position = position
		@flags = []
		@arguments = []
		@skeleton = File.open("sceleton.txt","a")
		@error = false
	end

	def print()
		@skeleton = File.open("sceleton.txt","a")
		@skeleton.write(": #{@name} : #{@position} | err: #{@error}\n")
		@skeleton.write(":    #{flags}\n")
		if arguments != []
			arguments.each do |arg|
				@skeleton.write(":    #{arg.name} : #{arg.has_insertion?}\n") 
			end
		end
		@skeleton.write("-------------\n")
		@skeleton.close
	end

	def print_error(message)
		@skeleton = File.open("sceleton.txt","a")
		@error = true unless message.empty?
		@skeleton.write(": ERROR: #{message}") unless message.empty?
		@skeleton.close
	end

	def args_as_string
		args_accum = ""
		@arguments.each do |arg|
			args_accum = "#{args_accum} #{arg.as_string}"
		end
		return "[#{args_accum}]"
	end

	def is_make_object?
		return true if @name == "Make-Object"
		return false
	end
	def is_rename_object?
		return true if @name == "Rename-Object"
		return false
	end
	def is_zip_object?
		return true if @name == "Zip-Object"
		return false
	end
	def is_unzip_object?
		return true if @name == "Unzip-Object"
		return false
	end
	def is_print_file?
		return true if @name == "Print-File"
		return false
	end

	def is_remove_object?
		return true if @name == "Remove-Object"
		return false
	end	
	def is_current_directory?
		return true if @name == "Current-Directory"
		return false
	end

	def is_change_directory?
		return true if @name == "Change-Directory"
		return false
	end

	def is_list_objects?
		return true if @name == "List-Objects"
		return false
	end
	def is_copy_object?
		return true if @name == "Copy-Object"
		return false
	end
	def is_move_object?
		return true if @name == "Move-Object"
		return false
	end
	def is_diff_files?
		return true if @name == "Diff-Files"
		return false
	end

end

class Message
	attr_accessor :error
	attr_accessor :text


	def initialize(error,text)
		@error = error
		@text = text
	end

	def isError?
		return error
	end

	def self.unknown_command(position,token)
		"#{position}: unknown command #{token}\n"
	end

	def self.unknown_flag(position, token)
		"#{position} : unknown flag #{token}\n"
	end

end
