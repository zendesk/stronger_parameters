# frozen_string_literal: true
require_relative 'test_helper'

SingleCov.not_covered!

class BooksAPIController < ActionController::API
  ROUTES = ActionDispatch::Routing::RouteSet.new
  ROUTES.draw { resources :books_api }
  include ROUTES.url_helpers

  rescue_from(ActionController::ParameterMissing) do |e|
    render json: { error: "Required parameter missing: #{e.param}" }, status: :bad_request
  end

  def create
    params.require(:book).permit(id: Parameters.integer)

    head :ok
  end
end

describe BooksAPIController do
  before { @routes = BooksAPIController::ROUTES }

  it 'rejects invalid params' do
    post :create, params: {magazine: {name: 'Mjallo!'}}
    assert_response :bad_request
    (JSON.parse(response.body)["error"]).must_equal 'Required parameter missing: book'

    post :create, params: {book: {id: 'Mjallo!'}}
    assert_response :bad_request
    (JSON.parse(response.body)["error"]).must_equal 'Invalid parameter: id must be an integer'
  end

  it 'permits valid params' do
    post :create, params: {book: {id: '123'}}
    assert_response :ok
  end
end
