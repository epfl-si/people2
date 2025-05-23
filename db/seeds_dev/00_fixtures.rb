# frozen_string_literal: true

# TODO: in dev we load the test fixtures but it would be nicer that test features
#       have nothing to do with reality and that we could load real seed data

Rake.application['db:fixtures:load'].invoke
