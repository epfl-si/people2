#!/usr/bin/env ruby

# # spazio e poi t
# (\s+
# 	t(
# 		(\s*\(([^)]+)\))      # t con parentesi
# 		|
# 		(\s+([^ ]+)\s+)       # t senza parentesi
# 	)
# )
# # parentesi e poi t
# (\s*\(\s*
# 	t(
# 		(\s*\(([^)]+)\))      # t con parentesi
# 		|
# 		([^)]+)               # t senza parentesi
# 	)
# \)\s*)

# # arg di t con parentesi = qualsiasi cosa che non sia una parentesi chiusa
# (\s*\(
#   ([^)]+)
# \))

# # arg di t con spazio
# # a) se era dentro una parentesi => qualsiasi cosa che non sia una parentesi
# (
# 	[^)]+
# )
# # b) se non era dentro una parentesi => qualsiasi cosa che  non sia uno spazio
# (\s+
# 	([^ ]+)
# \s+)

TRRE=/[( ]t[ (]['":]/
# TRREXT=/(\s+t((\s*\(([^)]+)\))|(\s+([^ ]+)\s+)))|(\s*\(\s*t((\s*\(([^)]+)\))|([^)]+))\)\s*)/

# --------------------------------------------------- RE including all arguments
# # (t(...))
# TRRE1=/\(\s*t\s*\(['":]?([^)]+)\s*\)/
# # (t ...)
# TRRE2=/\(\s*t\s+['":]?([^'" ]+)/
# # t(...) this would match also some TRRE1 => call after
# TRRE3=/\s+t\s*\(\s*['":]?([^)]+)/
# # t ... this would match also some TRRE2 => call after
# TRRE4=/\s+t\s+['":]?([^'" ]+)?/


# ------------------------------------------------------ RE including only label
# (t(...))
TRRE1=/\(\s*t\s*\(['":]?([^'" ,)]+)\s*\)/
# (t ...)
TRRE2=/\(\s*t\s+['":]?([^'", ]+)/
# t(...) this would match also some TRRE1 => call after
TRRE3=/\s+t\s*\(\s*['":]?([^'" ,)]+)/
# t ... this would match also some TRRE2 => call after
TRRE4=/\s+t\s+['":]?([^'", ]+)?/

def parse_line(l)
	puts "    | #{l}"
	[TRRE1, TRRE2, TRRE3, TRRE4].each do |re|
		# puts "      ] #{l}"
		# puts "      ] #{l.scan(re).inspect}"
		while(m=re.match(l))
			puts "    #{m[1]}"
			l.sub!(re, '')
		end
	end
end

def parse_file(path, type: nil)
	out = ""
	lines = File.readlines(path, chomp: true).select{|l| l =~ TRRE}.map{|l| l.strip}
	return if lines.count == 0

	puts "#{path}:"
	lines.each{|l| parse_line(l)}
end

# ------------------------------------------------------------------------------

# l='<p><%= t "admin_data.title" %></p>'
# l="""year_end <%= t 'spazio.t.spazio' %>= year_end.presence || t('spazio.t.parentesi') ciccio( t 'parentesi.t.spazio' ) pappamolla(t(:parentesi.t.parentesi)  ) """
# p l.scan(TRRE1)
# p l.scan(TRRE2)
# p l.scan(TRRE3)
# p l.scan(TRRE4)
# parse_line(l)
# exit


view_files = IO.popen("find app/views -name '*.erb'").readlines(chomp: true)
# # help_files = IO.popen("find app/helpers -name '*.rb'").readlines(chomp: true)
# # cont_files = IO.popen("find app/helpers -name '*.rb'").readlines(chomp: true)

view_files.each do |f|
	parse_file(f, type: :view)
end
