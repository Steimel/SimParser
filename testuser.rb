require 'simparser'

dir = 'sample_data/user/'

users = []
users.push(SimParser::User.new(dir + 'User00011.iff'))
users.push(SimParser::User.new(dir + 'User00012.iff'))
users.push(SimParser::User.new(dir + 'User00016.iff'))
users.push(SimParser::User.new(dir + 'User00018.iff'))

users.each do |u|
  puts u.name
end