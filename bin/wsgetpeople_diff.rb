#!/usr/bin/env ruby
require 'digest'
require 'net/http'
require 'json'
require 'diff-lcs'

HOSTS = [
  {
    host: "dinfo11.epfl.ch",
    path: "/cgi-bin/wsgetpeople",
    urihttp: URI::HTTP,
    headers: {Accept: 'application/json', Host: 'people.epfl.ch'}
  },
  {
    host: "people.dev.jkldsa.com",
    path: "/cgi-bin/wsgetpeople",
    urihttp: URI::HTTPS,
    headers: {Accept: 'application/json'}
  }
]
CACHE="tmp/wsgetpeople_cache"

def log(msg)
  STDERR.puts msg
end

def fetch(query, srv=1)
  sig = Digest::MD5.hexdigest(query.to_s)
  cf = "#{CACHE}/#{srv}/#{sig}.json"
  if File.exist?(cf)
    log "#{query} <- #{cf}"
    json = File.read(cf)
  else
    hh = HOSTS[srv]
    uri = hh[:urihttp].build(
      host: hh[:host],
      path: hh[:path],
      query: query
    )
    log "#{query} -> #{uri.to_s} -> #{cf}"
    json = Net::HTTP.get(uri, hh[:headers])
    File.open(cf, 'w+') do |f|
      f.puts(json)
    end
  end
  JSON.parse(json)
end

class String
  # black: 30, red: 31, green: 32, brown: 33, blue: 34, magenta: 35, cyan: 36, gray: 37
  # for background, 4x instead of 3x
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def x0
    colorize(35)
  end

  def x1
    colorize(33)
  end

  def added
    colorize(32)
  end

  def removed
    colorize(31)
  end

  def changed
    colorize(36)
  end

  def green
    colorize(32)
  end

  def red
    colorize(31)
  end

  def ok
    colorize(37)
  end

  def no
    colorize(36)
  end

end

# ------------------------------------------------------------------------------

class Member
  attr_reader :sciper, :email, :position, :unit
  def initialize(data)
    puts "Member::initialize data=#{data.inspect}"
    exit
    @sciper   = data["sciper"].to_s || ""
    @unit     = data["id_unite"].to_s || ""
    @email    = data["email"] || ""
    @position = data["fonction_en"] || ""
  end

  def to_s
    sprintf "%6s  %6s  %-40s  %s", @sciper, @unit, @email, @position
  end

  def to_seq
    [@sciper, @unit, @email, @position]
  end

  def diff0(other)
    diffs = Diff::LCS.sdiff(to_seq, other.to_seq)
    res = []
    diffs.each do |diff|
      case diff.action
      when '-'
        res << diff.old_element.removed
      when '+'
        res << diff.new_element.added
      when '!'
        res << diff.old_element.changed
      else
        res << diff.old_element.ok
      end
    end
    res.join("  ")
  end

  def cmp(s0,s1,f="%s")
    s = sprintf(f, s0)
    if s1.empty? && !s0.empty?
      s.added
    elsif s1 == s0
      s.ok
    else
      s.no
    end
  end

  def diff(other)
    r = []
    r << cmp(@sciper, other.sciper, "%6s")
    r << cmp(@unit, other.unit, "%6s")
    r << cmp(@email, other.email, "%-40s")
    r << cmp(@position, other.position)
    r.join("  ")
  end

  def ==(other)
    @sciper == other.sciper && @position == other.position
  end

  def <=>(other)
    @sciper <=> other.sciper
  end
end

class Section
  attr_reader :label, :members
  def initialize(data)
    @label = data["label"]
    @members = data["members"].map{|md| Member.new(md)}
  end

  def to_s
    "#{@label}:\n" + @members.map{|m| "  #{m.to_s}"}.join("\n")
  end
end

# ------------------------------------------------------------------------------

class MemberListComparer
  def initialize(mem0,mem1)
    @mem0 = mem0
    @mem1 = mem1
  end

  def mem0_by_sciper
    @mem0_by_sciper ||= @mem0.map{|m| [m.sciper, m]}.to_h
  end

  def mem1_by_sciper
    @mem1_by_sciper ||= @mem1.map{|m| [m.sciper, m]}.to_h
  end

  def diff
    res = []
    s0 = mem0_by_sciper.keys.sort
    s1 = mem1_by_sciper.keys.sort
    x0 = s0 - s1
    x1 = s1 - s0
    x0.each {|sciper| res << "   -- #{mem0_by_sciper[sciper].to_s}".x0}
    x1.each {|sciper| res << "   ++ #{mem1_by_sciper[sciper].to_s}".x1}
    cs = s0.intersection(s1)
    cs.each do |sciper|
      m0 = mem0_by_sciper[sciper]
      m1 = mem1_by_sciper[sciper]
      unless m0 == m1
        res << "   ≠/ #{m0.diff(m1)}"
        res << "   ≠\\ #{m1.diff(m0)}"
      end
    end
    res.join("\n")
  end
end

class StructsComparer
  def initialize(res0, res1)
    @secs0 = res0.map{|d| Section.new(d)}
    @secs1 = res1.map{|d| Section.new(d)}
  end
  def secs0_by_label
    @secs0_by_label ||= @secs0.map{|s| [s.label, s]}.to_h
  end
  def secs1_by_label
    @secs1_by_label ||= @secs1.map{|s| [s.label, s]}.to_h
  end

  def diff
    res = []
    allmem0 = @secs0.map{|s| s.members}.flatten
    allmem1 = @secs1.map{|s| s.members}.flatten
    lr = MemberListComparer.new(allmem0, allmem1)
    d = lr.diff
    unless d.empty?
      res << "  Overall Members:"
      res << d
    end

    labs0 = @secs0.map{|s| s.label}
    labs1 = @secs1.map{|s| s.label}
    xlab0 = labs0 - labs1
    xlab1 = labs1 - labs0

    res << "   Structures:" unless xlab0.empty? && xlab1.empty?
    xlab0.each do |l|
      res << " - #{l}".x0
      secs0_by_label[l].members.each do |m|
        res << "      #{m.to_s}".x0
      end
    end
    xlab1.each do |l|
      res << " + #{l}".x1
      secs1_by_label[l].members.each do |m|
        res << "      #{m.to_s}".x1
      end
    end

    clab = labs0.intersection(labs1)
    clab.each do |lab|
      s0 = secs0_by_label[lab]
      s1 = secs1_by_label[lab]
      lr = MemberListComparer.new(s0.members, s1.members)
      d = lr.diff
      unless d.empty?
        res << "   #{lab}:"
        res << d
      end
    end
    res.join("\n")
  end
end

def test_struct(query)
  res0 = fetch(query, 0)
  res1 = fetch(query, 1)
  c = StructsComparer.new(res0, res1)
  d = c.diff
end

def test_list(query)
  res0 = fetch(query, 0)
  res1 = fetch(query, 1)
  mem0 = res0.values.map{|d| Member.new(d)}
  mem1 = res1.values.map{|d| Member.new(d)}
  c = MemberListComparer.new(mem0, mem1)
  d = c.diff
end


# ------------------------------------------------------------------------------
[CACHE, "#{CACHE}/0", "#{CACHE}/1"].each do |dir|
  Dir.mkdir(dir) unless Dir.exist?(dir)
end

TESTS = [
  {
    scipers: "256138,269974,364830",
    lang: "en"
  },
  {
    units: "ph-sb",
    lang: "en"
  },
  {
    units: "LASUR"
  },
  {
    units: "LAND",
  },
  {
    units: "ISAS-FSD",
  },
  {
    units: "ISCS-IAM",
  },
  # {
  #   progcode: "EDMX",
  #   lang: "en"
  # },
  {
    units: "LAND",
    struct: "default_en_struct"
  },
  {
    units: "LAND,LASUR",
    struct: "default_en_struct"
  },
]

TESTS.each do |params|
  query=URI.encode_www_form(params)

  if params.key?(:struct)
    d = test_struct(query)
  else
    d = test_list(query)
  end

  if d.empty?
    s="OK".green
    puts "#{s} #{query}"
  else
    s="NO".red
    puts "#{s} #{query}"
    puts d
  end
end
