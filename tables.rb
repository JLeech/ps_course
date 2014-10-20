class FlagsTable
	include Singleton

	attr_accessor :flags
	attr_accessor :file

	def initialize
		@file = "flags.txt"
		@flags = {}
		lines = IO.readlines(@file)
		lines.each { |line| line.chomp! }
		lines.each do |line|
			words = line.split(" ")
			@flags[words.first] = words.drop(1)
		end
	end

	def has_flag?(command,flag)
		return true if @flags[command.name].include?(flag.name)
		return false
	end
end

class CommandTable
	include Singleton

	attr_accessor :commands
	attr_accessor :file

	def initialize
		@file = "commands.txt"
		@commands = IO.readlines(@file)
		@commands.each { |command| command.chomp! }
	end

	def command?(token)
		if @commands.include?(token)
			return true
		else
			return false
		end
	end
end