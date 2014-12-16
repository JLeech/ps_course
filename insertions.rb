
class Insertions

	attr_accessor :argument
	attr_accessor :pipe

	def initialize(argument,pipe)
		@argument = argument
		@pipe = pipe
	end

	def process_insertions
		find_arrays_with_methods
		find_simple_arrays
		find_methods
		find_simple_inserts
		return @argument
	end

	def find_arrays_with_methods
		loop do 
		 	array_with_method = /\$_\[\d*\]\$[a-z]*/.match(@argument)
		 	break if array_with_method.nil?
		 	process_arrays_with_methods(array_with_method)
		end
	end

	def process_arrays_with_methods(to_process)
		@argument.gsub!(to_process.to_s,"AWM")
	end

	def find_simple_arrays
		loop do 
		 	simple_array = /\$_\[\d*\]/.match(@argument)
		 	break if simple_array.nil?
		 	process_simple_arrays(simple_array)
		end
	end

	def process_simple_arrays(to_process)
		number = /\d/.match(to_process.to_s)
		@argument.gsub!(to_process.to_s,File.basename(@pipe[number.to_s.to_i]))
	end

	def find_methods
		loop do 
		 	simple_method = /\$_\$[a-z]*/.match(@argument)
		 	break if simple_method.nil?
		 	process_simple_methods(simple_method)
		end		
	end

	def process_simple_methods(to_process)
		@argument.gsub!(to_process.to_s,"SM")
	end

	def find_simple_inserts
		loop do 
		 	simple_method = /\$_/.match(@argument)
		 	break if simple_method.nil?
		 	process_simple_inserts(simple_method)
		end
	end

	def process_simple_inserts(to_process)
		@argument.gsub!(to_process.to_s,File.basename(@pipe.first))
	end

end



#argument = "$_/$_[1]$zzz/$_[0]$llll/$_[1]/$_$lll/$_.txt"
#pipe = ["FIRST","SECOND"]

#Insertions.new(argument,pipe).process_insertions
#puts argument