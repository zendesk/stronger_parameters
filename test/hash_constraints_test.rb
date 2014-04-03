require_relative 'test_helper'

describe 'open-ended hash parameter constraints' do

  subject do
    ActionController::Parameters.hash
  end

  def self.permits(value, options = {})
    options[:as] ||= value
    options[:as] = options[:as].with_indifferent_access

    super(value, options)
  end

  permits(:id => 1, :name => 'Mick')
  permits({:id => 1, :name => 'Mick'})
  rejects("a string")
  rejects(123)
end
