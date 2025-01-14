#!/usr/bin/env ruby
require 'uri'
year=2024
tmpfile="/tmp/wsgetpeople_access2024.txt"
srcfile="wsgetpeople_access2024_suc.txt"

unless File.exist?(tmpfile)
	logsdir="/var/www/vhosts/people.epfl.ch/logs"
	cmd="zgrep cgi-bin/wsgetpeople #{logsdir}/access.log-#{year}1222.gz"
	flt="gawk '/ 200 /{print $2, $8;}'"
	system "ssh dinfo@dinfo11.epfl.ch '#{cmd}' | #{flt} >  #{tmpfile}"
	system "ssh dinfo@dinfo12.epfl.ch '#{cmd}' | #{flt} >> #{tmpfile}"
end

system "sort '#{srcfile}' | uniq -c > #{srcfile}" unless File.exist?(srcfile)

ips_count={}
par_count={}
File.readlines(srcfile, chomp: true).each do |line|
	c, ip, req = line.split(" ")
	ips_count[ip] = (ips_count[ip]||0) + c.to_i
	# all_params = req.split(/[?&=]/)[(1..).step(2)]
	q = URI(req).query || "none"
	all_params = URI::decode_www_form(q).to_h.keys
	params = all_params.reject{|v| v=~/amp;q|lang|tabs|filter/}
	pk = params.sort.join(" ")
	par_count[pk] = (par_count[pk]||0) + c.to_i
end

ips_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

par_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end
