#!/usr/bin/env ruby
require 'digest'
require 'net/http'
require 'json'
require 'diff-lcs'

REPEAT = 4
HOST = {
  host: "people.dev.jkldsa.com",
  path: "/cgi-bin/wsgetpeople",
  urihttp: URI::HTTPS,
  headers: {Accept: 'application/json'},
  cache: false
}

def log(msg)
  STDERR.puts msg
end

def fetch(query)
  uri = HOST[:urihttp].build(
    host: HOST[:host],
    path: HOST[:path],
    query: query
  )
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  json = Net::HTTP.get(uri, HOST[:headers])
  t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  t1-t0
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

comment = ARGV[0] || ""
TESTS.each do |params|
  query=URI.encode_www_form(params)

  t1 = fetch(query)
  tt = (1..REPEAT).map{ |i| fetch(query) }
  ta = tt.sum / tt.count
  ts = Math.sqrt(tt.map{|t| (t-ta)*(t-ta)}.sum / (tt.count - 1))
  printf("%-4s : %5.2f / %5.2f ±%5.2f <- %s\n", comment, t1, ta, ts, query);
end
