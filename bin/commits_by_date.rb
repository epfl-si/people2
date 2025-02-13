#!/usr/bin/env ruby
require 'active_support/core_ext/numeric/time'
# require 'date'
START_DATE="2023-01-31"

class Commit
	attr_reader :d, :h
	def initialize(l)
		@d,@h, @a = l.split(" ")
	end

	def <=>(other)
		@d <=> other.d
	end

	def ym
		@d.split("-")[..1].join("-")
	end

	def date
		@date ||= Date.parse(@d)
	end

	def to_s
		"#{@d} #{@h} #{@a}"
	end
end
		
# The git repo contains commits from Dom's RoR starter kit 
# but --all and --since do not work together
cmd = "git log --all --pretty=format:'%ad %h %an' --date=short"
commits = `#{cmd}`.split("\n")
	.map {|l| Commit.new(l)}
	.sort.select{|c| c.d >= START_DATE}

byday = {}
commits.each do |c|
	if byday.key?(c.d)
		byday[c.d] << c
	else
		byday[c.d] = [c]
	end
end

bymonth = {}
commits.each do |c|
	if bymonth.key?(c.ym)
		bymonth[c.ym] << c
	else
		bymonth[c.ym] = [c]
	end
end

cdc = commits.map{|c| c.d}.uniq.count

d0 = commits.first.date
d1 = commits.last.date
dd = (d1 - d0)
puts "Commits lifespan: #{d0} -- #{d1}"
puts "Days since first commit: #{dd.days/86400}"
puts "Days with commits: #{cdc}"

puts "\n\nMonthly histogram"
d = d0
while d <= d1
	ym = d.strftime("%Y-%m")
	c = bymonth[ym]&.count || 0
	h = '#' * c
	printf "%7s %2d %s\n", ym, c, h
	# puts "#{ym}  #{h} #{c}"
	d = d.next_month
end

puts "\n\nDaily histogram"
d = d0
while d <= d1
	ymd = d.strftime("%Y-%m-%d")
	d = d.tomorrow
	c = byday[ymd]&.count || 0
	h = '#' * c
	if c>0 || d.on_weekday?
		printf "%10s %2d %s\n", ymd, c, h
	end
end
