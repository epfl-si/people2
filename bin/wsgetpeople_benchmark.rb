#!/usr/bin/env ruby
require 'digest'
require 'net/http'
require 'json'
require 'yaml'
require 'diff-lcs'

REPEAT = 4
HOSTS = [
  # {
  #   host: "people.dev.jkldsa.com",
  #   path: "/cgi-bin/wsgetpeople",
  #   urihttp: URI::HTTPS,
  #   headers: {Accept: 'application/json'},
  #   cache: false
  # },
  {
    name: "LEGACY",
    host: "dinfo11.epfl.ch",
    path: "/cgi-bin/wsgetpeople",
    urihttp: URI::HTTP,
    headers: {Accept: 'application/json', Host: 'people.epfl.ch'}
  },
  {
    name: "NEW_S",
    host: "people-next.epfl.ch",
    path: "/api/v0/wsgetpeople",
    urihttp: URI::HTTPS,
    headers: {Accept: 'application/json'},
    cache: false
  },
  {
    name: "OLD_S",
    host: "people.epfl.ch",
    path: "/api/v0/wsgetpeople",
    urihttp: URI::HTTPS,
    headers: {Accept: 'application/json'},
    cache: false
  },
]

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
  {
    units: "LAND,LASUR",
  },
  {
    progcode: "EDMX",
    lang: "en"
  },
  {
    units: "ISAS-FSD",
    struct: "default_en_struct"
  },
  {
    units: "LAND",
    struct: "default_en_struct",
  },
  {
    units: "LASUR",
    struct: "default_en_struct"
  },
  {
    units: "LAND,LASUR",
    struct: "default_en_struct"
  },
]

def log(msg)
  STDERR.puts msg
end

def fetch(query, host)
  uri = host[:urihttp].build(
    host: host[:host],
    path: host[:path],
    query: query
  )
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  json = Net::HTTP.get(uri, host[:headers])
  t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  t1-t0
end

repeat = REPEAT
tests = TESTS
hosts = HOSTS

while a=ARGV.shift
  case a
  when "-r"
    repeat = ARGV.shift.to_i
  when "-i"
    tf = ARGV.shift
    tests = YAML.load_file(tf)
  when "-s"
    hosts = [HOSTS[ARGV.shift.to_i]]
  end
end

# puts "repeat:  #{repeat}"
# puts "tests:   #{tests.inspect}"
# puts "hosts: #{hosts.inspect}"


hosts.each do |host|
  tests.each do |params|
    query=URI.encode_www_form(params)

    t1 = fetch(query, host)
    tt = (1..REPEAT).map{ |i| fetch(query, host) }
    ta = tt.sum / tt.count
    ts = Math.sqrt(tt.map{|t| (t-ta)*(t-ta)}.sum / (tt.count - 1))
    printf("%-6s : %5.2f / %5.2f ±%5.2f <- %s\n", host[:name], t1, ta, ts, query);
  end
end
