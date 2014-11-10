#this class is for reading/manipulating data in neighborhood.iff

require_relative 'neighbor'
require_relative 'family'
module SimParser
class Neighborhood
  attr_reader :neighbors, :families
	def initialize(path)
		objects = IffParser::parseiff(path)
		
		@families = []
		objects.each do |obj|
		  @neighbors = parse_NBRS(obj) if obj['type'] == 'NBRS'
		  @families.push(parse_FAMI(obj)) if obj['type'] == 'FAMI'
		end
	end

	def career_paths
		{'ffff' => 'schoolchild',
		'0000' => 'jobless',
		'0100' => 'business',
		'0200' => 'entertainment',
		'0300' => 'law enforcement',
		'0400' => 'crime',
		'0500' => 'medicine',
		'0600' => 'military',
		'0700' => 'politics',
		'0800' => 'pro sports',
		'0900' => 'science',
		'0a00' => 'X-treme',
		'0b00' => 'musician',
		'0c00' => 'slacker',
		'0d00' => 'entertainment', #again?
		'0e00' => 'paranormal',
		'0f00' => 'journalism',
		'1000' => 'hacker'}
	end
	
	def skin_tones
		{'0100' => 'light',
		'0200' => 'medium',
		'0300' => 'dark'}
	end
	
	def genders
		{'0000' => 'male',
		'0100' => 'female'}
	end
	
	def hex_to_gender(hex)
		val = hex.unpack('H*')[0]
		return genders[val]
	end

	def hex_to_skin_tone(hex)
		val = hex.unpack('H*')[0]
		return skin_tones[val]
	end

	def hex_to_career_path(hex)
		val = hex.unpack('H*')[0]
		return career_paths[val]
	end

	#parse_FAMI
	#params: fami obj
	#returns: Family object
	def parse_FAMI(fami)
		family = Family.new
		data = fami['data']
		family.id = fami['id']
		family.house_number = Utils::hex_to_int(data[12..15], Utils::LITTLE_ENDIAN)
		family.cash = Utils::hex_to_int(data[20..23], Utils::LITTLE_ENDIAN)
		return family
	end

	#dont think the first 24 bytes matter
	#parse_NBRS
	#params: nbrs obj
	#returns: Array of neighbors
	def parse_NBRS(nbrs)
		neighbors = []
		data = nbrs['data'][24..-1]
		while !data.nil? && data.size > 0 do
			res = parse_neighbor(data)
			neighbors.push(res[0]) unless res[0].nil?
			data = res[1]
		end
		return neighbors
	end

	#parse_neighbor
	#params: char from NBRS obj
	#returns: Neighbor object, remaining string
	def parse_neighbor(char)
		neighbor = Neighbor.new
		id = ''
		while !char.nil? && char.size > 0 && Utils::hex_to_int(char[0]) != 0 do
			id = id + char[0].to_s
			char = char[1..-1]
		end
		return [nil,''] if char.empty?

		neighbor.id = id
		if is_npc(id)
			neighbor.is_npc = true
			f_start = 0
			ffs_in_a_row = 0
			while ffs_in_a_row < 4
				return [nil,''] if char[f_start + ffs_in_a_row].nil?
				if char[f_start + ffs_in_a_row].unpack('H*')[0] == 'ff'
					ffs_in_a_row = ffs_in_a_row + 1
				else
					ffs_in_a_row = 0
					f_start = f_start + 1
				end
			end
			neighbor.relationship_id = char[(f_start - 6)..(f_start - 5)].unpack('H*')[0]
			neighbor.unknown_id = char[(f_start - 4)..(f_start - 1)].unpack('H*')[0]

			relationships, char = parse_relationships(char[(f_start + 4)..-1])
			neighbor.relationships = relationships
	
			return [neighbor, char]
		end
		neighbor.is_npc = false
	
		personality = {}
		personality['nice'] = Utils::hex_to_int(char[13..14], Utils::LITTLE_ENDIAN)
		personality['active'] = Utils::hex_to_int(char[15..16], Utils::LITTLE_ENDIAN)
		personality['playful'] = Utils::hex_to_int(char[19..20], Utils::LITTLE_ENDIAN)
		personality['outgoing'] = Utils::hex_to_int(char[21..22], Utils::LITTLE_ENDIAN)
		personality['neat'] = Utils::hex_to_int(char[23..24], Utils::LITTLE_ENDIAN)
		neighbor.personality = personality
	
		skills = {}
		skills['cooking'] = Utils::hex_to_int(char[29..30], Utils::LITTLE_ENDIAN)
		skills['charisma'] = Utils::hex_to_int(char[31..32], Utils::LITTLE_ENDIAN)
		skills['mechanical'] = Utils::hex_to_int(char[33..34], Utils::LITTLE_ENDIAN)
		skills['creativity'] = Utils::hex_to_int(char[39..40], Utils::LITTLE_ENDIAN)
		skills['body'] = Utils::hex_to_int(char[43..44], Utils::LITTLE_ENDIAN)
		skills['logic'] = Utils::hex_to_int(char[45..46], Utils::LITTLE_ENDIAN)
		neighbor.skills = skills

		char = char[48..-1]
		char = char[52..-1]

		interests = {}
		interests['travel/toys'] = Utils::hex_to_int(char[1..2], Utils::LITTLE_ENDIAN)
		interests['violence/aliens'] = Utils::hex_to_int(char[3..4], Utils::LITTLE_ENDIAN)
		interests['politics/pets'] = Utils::hex_to_int(char[5..6], Utils::LITTLE_ENDIAN)
		interests['60s/school'] = Utils::hex_to_int(char[7..8], Utils::LITTLE_ENDIAN)
		interests['weather'] = Utils::hex_to_int(char[9..10], Utils::LITTLE_ENDIAN)
		interests['sports'] = Utils::hex_to_int(char[11..12], Utils::LITTLE_ENDIAN)
		interests['music'] = Utils::hex_to_int(char[13..14], Utils::LITTLE_ENDIAN)
		interests['outdoors'] = Utils::hex_to_int(char[15..16], Utils::LITTLE_ENDIAN)
		interests['technology'] = Utils::hex_to_int(char[17..18], Utils::LITTLE_ENDIAN)
		interests['romance'] = Utils::hex_to_int(char[19..20], Utils::LITTLE_ENDIAN)
		neighbor.interests = interests

		career = {}
		career['path'] = hex_to_career_path(char[21..22])
		career['level'] = Utils::hex_to_int(char[23..24], Utils::LITTLE_ENDIAN)
		neighbor.career = career

		neighbor.age = Utils::hex_to_int(char[25..26], Utils::LITTLE_ENDIAN)
		neighbor.skin_tone = hex_to_skin_tone(char[29..30])
		neighbor.gender = hex_to_gender(char[39..40])
	
		f_start = 0
		ffs_in_a_row = 0
		while ffs_in_a_row < 4
			if char[f_start + ffs_in_a_row].unpack('H*')[0] == 'ff'
				ffs_in_a_row = ffs_in_a_row + 1
			else
				ffs_in_a_row = 0
				f_start = f_start + 1
			end
		end
		neighbor.relationship_id = char[(f_start - 6)..(f_start - 5)].unpack('H*')[0]
		neighbor.unknown_id = char[(f_start - 4)..(f_start - 1)].unpack('H*')[0]

		relationships, char = parse_relationships(char[(f_start + 4)..-1])
		neighbor.relationships = relationships
	
		return [neighbor, char]
	end

	#parse_relationships
	#params: hex_string: string starting at the end of the fs
	#returns [[relationship{}], char starting at the end of the current person]
	def parse_relationships(hex_string)
		relationships = []
		num_rels_left = Utils::hex_to_int(hex_string[0..3], Utils::LITTLE_ENDIAN)

		if num_rels_left == 0
			ending = Utils::find_end_of(hex_string, '0100000004000000')
			return [[], hex_string[ending..-1]]
		end

		hex_string = hex_string[8..-1]
		while num_rels_left > 0
			new_rel = {}
			new_rel['other_relationship_id'] = hex_string[0..1].unpack('H*')[0]
			new_rel['value'] = Utils::hex_to_int(hex_string[8..11], Utils::LITTLE_ENDIAN)
			relationships.push(new_rel)
			next_start = 12 + Utils::hex_to_int(hex_string[4..7], Utils::LITTLE_ENDIAN)*4
			hex_string = hex_string[next_start..-1]
			num_rels_left = num_rels_left - 1
		end

		hex_string = '' if hex_string.nil?	

		return [relationships, hex_string[4..-1]]
	end

	#is_npc
	#params: string id
	#returns: bool whether or not char is an npc
	def is_npc(id)
		!id.start_with?('user')
	end
end
end