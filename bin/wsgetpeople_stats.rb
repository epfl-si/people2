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
stu_count={} # structure + unit parameter
uni_histo={} # histogram of how many times a given number of units was used
muu_list={}  # multiple units combinations
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
		unless (uni=params["units"]).nil?
			stu_count["#{uni} / #{str}"] = (stu_count["#{uni} / #{str}"]||0) + c
		end
	end
	unless (str=params["position"]).nil?
		pos_count[str] = (pos_count[str]||0) + c
	end
	unless (str=params["units"]).nil?
		uni_count[str] = (uni_count[str]||0) + c
		nu = str.split(",").count
		uni_histo[nu] = (uni_histo[nu]||0) + c
		if nu > 3
			muu_list[str] = (muu_list[str]||0) + c
		end
	end
	unless (str=params["groups"]).nil?
		gru_count[str] = (gru_count[str]||0) + c
	end
	unless (str=params["progcode"]).nil?
		pco_count[str] = (pco_count[str]||0) + c
	end
end

printf("# ------------- Source IP addresses\n")
ips_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for position parameter\n")
pos_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for units parameter\n")
uni_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Used parameter combinations\n")
par_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for struct parameter\n")
str_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for group parameter\n")
gru_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for progcode parameter\n")
pco_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Values for unit / structure parameter\n")
stu_count.to_a.sort{|a,b| a[1] <=> b[1]}.each do |k,c|
	printf("%8d %s\n", c, k);
end

printf("# ------------- Histogram of how many units in units parameter\n")
printf("  %8s   %8s\n", "units", "times")
uni_histo.keys.sort.each do |c|
	printf("  %8d   %8d\n", c, uni_histo[c])
end

printf("# ------------- Multiple units combinations\n")
muu_list.to_a.sort{|a,b| a[1] <=> b[1]}.each do |v|
	printf("%8d %s\n", v[1], v[0])
end
