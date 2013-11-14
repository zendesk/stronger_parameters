require_relative 'test_helper'

describe 'array parameter constraints' do
  subject do
    ActionController::Parameters.map(
      :id => ActionController::Parameters.integer,
      :name => ActionController::Parameters.string
    )
  end

  def self.permits(value, options = {})
    options[:as] ||= value
    options[:as] = options[:as].with_indifferent_access

    super(value, options)
  end

  permits(:id => 1, :name => 'Mick')
  permits({:id => '1', :name => 'Mick'}, :as => {:id => 1, :name => 'Mick'})
  permits(:id => 1)
  permits({:id => '1'}, :as => {:id => 1})
  permits(:name => 'Mick')

  rejects(:id => 1, :name => 123)
  rejects(:id => 'Mick', :name => 'Mick')
  rejects(123)
  rejects('abc')
end
