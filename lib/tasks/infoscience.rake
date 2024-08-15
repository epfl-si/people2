# frozen_string_literal: true

namespace :chore do
  desc 'Extract legacy people that are using an infoscience export link'
  task natislinks: :environment do
    boxes = Legacy::Box.where("sys = 'I' and src is not null and src != ''")
    scipers = boxes.map(&:sciper).sort.uniq
    people = scipers.map { |s| Ldap::Person.for_sciper(s) }.compact
    urls = {}
    boxes.each do |b|
      urls[b.sciper] ||= []
      urls[b.sciper] << b.src
    end
    r = people.map do |p|
      {
        name: p.name.to_s,
        mail: p.email.to_s,
        urls: urls[p.sciper],
      }
    end
    puts r.to_yaml
  end
end
