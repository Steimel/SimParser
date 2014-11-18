#this class is for reading/manipulating all data

module SimParser
class SimParser
  attr_reader :neighborhood, :users
	def initialize(path)
	   unless File.directory?(path)
	     puts 'Error: not a directory: ' + path
	     return
	   end
		@neighborhood = Neighborhood.new(get_neighborhood_path(path))
		@users = []
		@neighborhood.neighbors.each do |neighbor|
		  set_neighbor_name(path, neighbor)
		end
	end
	
	def set_neighbor_name(path, neighbor)
	  if neighbor.is_npc
	    neighbor.name = neighbor.id
	  else
	    new_user = User.new(get_user_path(path, neighbor))
	    neighbor.name = new_user.name
	    @users.push(new_user)
	  end
	end
	
	def get_neighborhood_path(path)
	  return path + 'neighborhood.iff' if path[-1] == '/'
	  return path + '/neighborhood.iff'
	end
	
	def get_user_path(path, neighbor)
	  return path + 'Characters/' + neighbor.id if path[-1] == '/'
	  return path + '/Characters/' + neighbor.id
	end
end
end