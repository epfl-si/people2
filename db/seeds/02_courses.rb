# frozen_string_literal: true

Rake.application['data:courses'].invoke if Course.count.zero?
