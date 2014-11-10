module SimParser
class Utils
  LITTLE_ENDIAN = 0
  BIG_ENDIAN = 1

  def self.hex_to_int(hex, endianness = BIG_ENDIAN)
		hex = hex.reverse if endianness == LITTLE_ENDIAN
		num = 0
		while hex.size > 0 do
			num = num + hex[0].unpack('H*')[0].to_i(16) * (256 ** (hex.size - 1))
			hex = hex[1..-1]
		end
		return num
	end
	
	def self.find_end_of(hex_str, hex_substr)
		len = hex_substr.size / 2
		start = 0
		while !hex_str.nil? && hex_str.size >= hex_substr.size
			return start + len if hex_str[0..(len-1)].unpack('H*')[0] == hex_substr
			start = start + 1
			hex_str = hex_str[1..-1]
		end
		return -1
	end
end
end