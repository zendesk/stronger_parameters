# frozen_string_literal: true
require_relative 'test_helper'

SingleCov.not_covered!

class BooksController < ActionController::Base
  ROUTES = ActionDispatch::Routing::RouteSet.new
  ROUTES.draw { resources :books }
  include ROUTES.url_helpers

  rescue_from(ActionController::ParameterMissing) do |e|
    type = (ActiveSupport::VERSION::MAJOR < 5 ? :text : :plain)
    render type => "Required parameter missing: #{e.param}", :status => :bad_request
  end

  def create
    params.require(:book).permit(id: Parameters.integer)

    head :ok
  end
end

describe BooksController do
  def post(action, options = {})
    if Rails::VERSION::MAJOR < 5
      super(action, options.fetch(:params))
    elsif Rails::VERSION::MAJOR >= 7
      super(action, **options)
    else
      super
    end
  end

  before { @routes = BooksController::ROUTES }

  it 'rejects invalid params' do
    post :create, params: {magazine: {name: 'Mjallo!'}}
    assert_response :bad_request
    response.body.must_equal 'Required parameter missing: book'

    post :create, params: {book: {id: 'Mjallo!'}}
    assert_response :bad_request
    response.body.must_equal 'Invalid parameter: id must be an integer'
  end

  it 'permits valid params' do
    post :create, params: {book: {id: '123'}}
    assert_response :ok
  end
end
