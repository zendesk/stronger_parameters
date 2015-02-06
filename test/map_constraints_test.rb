require_relative 'test_helper'

describe 'map parameter constraints' do
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

  rejects({:id => 1, :name => 123}, :key => :name)
  rejects({:id => 'Mick', :name => 'Mick'}, :key => :id)
  rejects(123)
  rejects('abc')
  rejects nil
end

describe 'open-ended map parameter constraints' do
  subject do
    ActionController::Parameters.map
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
  rejects nil
end
