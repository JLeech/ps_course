	def read_file(file_path)

		data = []
		file = File.new(file_path, "r")
		while (line = file.gets)
    		data << line.chomp
		end
		file.close
		return data
	end



