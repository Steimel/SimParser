require 'simparser'

dir = 'sample_data/neighborhood/'
nhood1 = SimParser::Neighborhood.new(dir + 'neighborhood1.iff')
nhood2 = SimParser::Neighborhood.new(dir + 'neighborhood2.iff')
nhood3 = SimParser::Neighborhood.new(dir + 'neighborhood3.iff')


while true
  found_hood = false
  while !found_hood
    print 'Enter Neighborhood to view (1-3) (q=quit):'
    input = STDIN.gets.chomp
    exit! if input == 'q'
    found_hood = true
    current_hood = nil
    current_hood = nhood1 if input == '1'
    current_hood = nhood2 if input == '2'
    current_hood = nhood3 if input == '3'
    found_hood = false if current_hood.nil?
  end
  
  found_set = false
  while !found_set
    print 'Enter 1 to view neighbors and 2 to view families (q=quit):'
    input = STDIN.gets.chomp
    exit! if input == 'q'
    found_set = true
    current_set = nil
    current_set = current_hood.neighbors if input == '1'
    current_set = current_hood.families if input == '2'
    found_set = false if current_set.nil?
   end

   restart = false
   while true
     current_set.each_with_index do |obj, index|
       puts index.to_s + ':' + obj.id.to_s
     end
     print 'Enter index of object to view (q=quit, -1=restart):'
     input = STDIN.gets.chomp
     exit! if input == 'q'
     break if input == '-1'
     current_obj = nil
     current_obj = current_set[input.to_i] unless input == ''
     unless current_obj.nil?
       puts current_obj.inspect.to_s
       STDIN.gets
     end
   end
end