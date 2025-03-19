#!/usr/bin/ruby
# Extract plottable data from repeated top output (cronjobs on dinfo[12] server)
# (echo ; echo ; date ; top -n 1 -b | head -n 16) >> /home/dinfo/Giova/cpu.txt
# scp dinfo11:Giova/cpu.txt tmp/srvLoad/cpu1.txt
# scp dinfo12:Giova/cpu.txt tmp/srvLoad/cpu2.txt
# ruby bin/plotop.rb
# gnuplot
# plot "cpu1.d" u 1:4 w d title "dinfo11 load5", "cpu2.d" u 1:4 w d title "dinfo12 load5"
# plot "cpu1.d" u 1:($7/1000000) w d title "dinfo11 Gb", "cpu2.d" u 1:($7/1000000) w d title "dinfo12 Gb"

require 'date'

class CpuLog
	attr_reader :time, :loads, :percents, :mems, :used_mem
	def initialize(s)
		lines = s.split("\n")
		@time = DateTime.parse(lines.first)
		@loads = lines[1].gsub(/^.*load average: /, "").split(", ").map{|v| v.to_f}
		@percents = lines[3].gsub(/^.*Cpu\(s\): /, "").split(", ").map{|v| v.split("%").reverse}.to_h
		@mems = lines[4].gsub(/^.*Mem: /, "").split(", ").map{|v| v.split("k ").reverse}.map{|a| [a[0], a[1].chomp.to_i]}.to_h

    @used_mem = @mems["used"] - @mems["buffers"]
	end

	def to_gpline(i)
		sprintf("%3d     %6.2f %6.2f %6.2f     %6.2f %6.2f     %12d\n", i, @loads[0], @loads[1], @loads[2], @percents["us"], @percents["sy"], @used_mem)
	end
end

[1,2].each do |i|
	cpus=File.read("cpu#{i}.txt").split("\n\n\n").map{|s| CpuLog.new(s)}
	File.open("cpu#{i}.d", 'w') do |f|
		cpus.each_with_index{|c, i| f.puts c.to_gpline(i)}
	end
end