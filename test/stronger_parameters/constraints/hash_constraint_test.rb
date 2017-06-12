# frozen_string_literal: true
require_relative '../../test_helper'

SingleCov.covered!

describe StrongerParameters::HashConstraint do
  def self.permits(value, options = {})
    options[:as] ||= value
    options[:as] = options[:as].with_indifferent_access

    super(value, options)
  end

  subject do
    ActionController::Parameters.map(
      id: ActionController::Parameters.integer,
      name: ActionController::Parameters.string
    )
  end

  describe 'map parameter constraints' do
    permits(id: 1, name: 'Mick')
    permits({id: '1', name: 'Mick'}, as: {id: 1, name: 'Mick'})
    permits(id: 1)
    permits({id: '1'}, as: {id: 1})
    permits(name: 'Mick')

    rejects({id: 1, name: 123}, key: :name)
    rejects({id: 'Mick', name: 'Mick'}, key: :id)
    rejects(123)
    rejects('abc')
    rejects nil
  end

  describe 'open-ended map parameter constraints' do
    subject { ActionController::Parameters.map }

    permits(id: 1, name: 'Mick')
    permits("id" => 1, "name" => 'Mick')
    rejects("a string")
    rejects(123)
    rejects nil
  end

  describe 'merged constraints' do
    subject do
      ActionController::Parameters.map(id: ActionController::Parameters.integer).
        merge(ActionController::Parameters.map(name: ActionController::Parameters.string))
    end

    permits(id: 1, name: 'Mick')
    rejects({id: 'Mick', foo: 'Mick'}, key: :id) # TODO: key: :id is wrong
  end

  describe "#==" do
    it "is the same with same limit" do
      other = ActionController::Parameters.map(
        id: ActionController::Parameters.integer,
        name: ActionController::Parameters.string
      )
      subject.must_equal other
    end

    it "is not the same with different limit" do
      subject.wont_equal ActionController::Parameters.map(id: ActionController::Parameters.integer)
    end
  end
end
