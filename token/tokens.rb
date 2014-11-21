class Argument
	
	INSERT = "$_"

	attr_accessor :name
	attr_accessor :position
	attr_accessor :insertion

	def initialize(name,position)
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
