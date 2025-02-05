#!/usr/bin/env ruby
require 'uri'
year=2024
tmpfile="tmp/wsgetpeople_access2024.txt"
srcfile="tmp/wsgetpeople_access2024_suc.txt"

unless File.exist?(tmpfile)
	logsdir="/var/www/vhosts/people.epfl.ch/logs"
	cmd="zgrep cgi-bin/wsgetpeople #{logsdir}/access.log-#{year}1222.gz"
	flt="gawk '/ 200 /{print $2, $8;}'"
	system "ssh dinfo@dinfo11.epfl.ch '#{cmd}' | #{flt} >  #{tmpfile}"
	system "ssh dinfo@dinfo12.epfl.ch '#{cmd}' | #{flt} >> #{tmpfile}"
end

system "sort '#{srcfile}' | uniq -c > #{srcfile}" unless File.exist?(srcfile)

ips_count={} # source ip address
par_count={} # parameter combinations
str_count={} # structure files
pos_count={} # position filter
uni_count={} # units values
gru_count={} # groups values
pco_count={} # progcode values
File.readlines(srcfile, chomp: true).each do |line|
	# log file where already sort|uniq -c so the first column contains the multiplicity
	c, ip, req = line.split(" ")
	c = c.to_i
	ips_count[ip] = (ips_count[ip]||0) + c
	# all_params = req.split(/[?&=]/)[(1..).step(2)]
	q = URI(req).query || "none"
	params = URI::decode_www_form(q).to_h
	param_names = params.keys.reject{|v| v=~/amp;q|lang|tabs|filter/}
	pk = param_names.sort.join(" ")
	par_count[pk] = (par_count[pk]||0) + c
	unless (str=params["struct"]).nil?
		str_count[str] = (str_count[str]||0) + c
	end
	unless (str=params["position"]).nil?
		pos_count[str] = (pos_count[str]||0) + c
	end
	unless (str=params["units"]).nil?
		uni_count[str] = (uni_count[str]||0) + c
	end
	unless (str=params["groups"]).nil?
		gru_count[str] = (gru_count[str]||0) + c
	end
	unless (str=params["progcode"]).nil?
		pco_count[str] = (pco_count[str]||0) + c
	end
end

printf("# ------------- Source IP addresses")
ips_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for position parameter")
pos_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for units parameter")
uni_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Used parameter combinations")
par_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for struct parameter")
str_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for group parameter")
gru_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for progcode parameter")
pco_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end
