require 'set'
require 'optparse'
require 'set'

$max_node = 2000
$max_neighbor = 200
$parallel = 4
$is_directed = true

OptionParser.new do |opts|
    opts.banner = "Usage: ruby random_graph_gen.rb [options]"
    opts.on('-n NUM', 'number of nodes') {|p| $max_node = p.to_i }
    opts.on('-e NUM', 'maximum edge number foreach node') {|p| $max_neighbor = p.to_i}
    opts.on('-p NUM', 'parallelism') {|p| $parallel= p.to_i}
    opts.on('-u', "undirected graph?,\n\t\t\t note this is the in memory implementation!") { $is_directed = false} 
    opts.on('-h') { puts opts; exit}
    opts.parse!
end

lock = Mutex.new

if $is_directed 
    threads = []
    step = $max_node / $parallel
    ((0..($max_node-1)).step step).each do |startNum |
        threads << Thread.new {
            (startNum..(startNum+step-1)).each do |i|
                cn = rand(0..[$max_neighbor,$max_node].min)
                str = i.to_s + ' ' + cn.to_s 
                neighbors = Set.new
                while neighbors.size < cn
                    neighbors << rand(0..$max_node-1)
                end
                neighbors.each {|n| str += ' ' + n.to_s }
                lock.synchronize do
                    puts str
                end
            end
        }
    end

    threads.each {|t| t.join }
    exit
end

(0..$max_node*$max_neighbor/2).each_with_object(Array.new) do |i, list|
    src = rand(0..$max_node-1)
    des = rand(0..$max_node-1)
    list << [src, des] << [des, src] if src != des
end.reduce(Hash.new) do | hash, edge|
    prev = hash[edge.first] || Set.new
    hash[edge.first] = (prev << edge.last)
    hash
end.map do |src, destlist|
    puts src.to_s + " " + destlist.size.to_s + " " + destlist.to_a.join(' ')
end

