require 'set'

if ARGV.length == 0 
    puts "Usage: ruby random_graph_gen.rb [count_nodes] [max_neighbor_size] [thread_num]"
    exit 0
end

max = 2000
max = ARGV[0].to_i if ARGV.length > 0

max_neighbor = 200
max_neighbor = ARGV[1].to_i if ARGV.length > 1

nthread = 8
nthread = ARGV[2].to_i if ARGV.length > 2

lock = Mutex.new

threads = []
step = max / nthread
((0..(max-1)).step step).each do |startNum |
    threads << Thread.new {
        (startNum..(startNum+step-1)).each do |i|
            cn = rand(0..[max_neighbor, max/5].min)
            str = i.to_s + ' ' + cn.to_s 
            neighbors = Set.new
            while neighbors.size < cn
                neighbors << rand(0..max)
            end
            neighbors.each {|n| str += ' ' + n.to_s }
            lock.synchronize do
                puts str
            end
        end
    }
end

threads.each {|t| t.join }
