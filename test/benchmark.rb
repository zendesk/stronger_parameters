require_relative 'test_helper'
require 'benchmark'

def build_stack(count, &block)
  if count == 0
    yield
  else
    build_stack(count - 1, &block)
  end
end

puts(Benchmark.realtime do
  build_stack(100) do
    10000.times do
      (StrongerParameters::IntegerConstraint.new | StrongerParameters::BooleanConstraint.new | StrongerParameters::StringConstraint.new).value("xxx")
    end
  end
end)
