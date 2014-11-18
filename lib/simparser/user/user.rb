#this class is for reading/manipulating data in userXXXXX.iff

module SimParser
class User
   attr_reader :name
	def initialize(path)
		objects = IffParser::parseiff(path)
		
		objects.each do |obj|
		  parse_OBJD(obj) if obj['type'] == 'OBJD'
		end
	end

   def parse_OBJD(obj)
     data = obj['header']
     ending = Utils::find_end_of(data,'202d20')
     data = data[ending..-1]
     name_ending = Utils::find_end_of(data,'00') - 2
     @name = data[0..name_ending]
   end

end
end