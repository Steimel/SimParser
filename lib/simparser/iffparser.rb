module SimParser
class IffParser
  #parseiff
	#params: filename: string path to iff file
	#returns: array of hashes: {type, id, size, data}
	def self.parseiff(filename)
		contents = open(filename, "rb") {|io| io.read }
		contents = contents [64..-1]
		objects = []
		while !contents.nil? && contents.size > 0 do
			new_obj = {}
			new_obj['type'] = contents[0..3]
			size = hex_to_int(contents[4..7])
			new_obj['size'] = size - 76
			new_obj['id'] = hex_to_int(contents[8..9])
			new_obj['data'] = contents[76..(size - 1)]
			objects.push(new_obj)
			contents = contents[size..-1]
		end
		return objects
	end
end
end