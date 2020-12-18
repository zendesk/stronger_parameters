# frozen_string_literal: true
require_relative 'test_helper'

SingleCov.not_covered!

class BooksController < ActionController::Base
  rescue_from(ActionController::ParameterMissing) do |e|
    render plain: "Required parameter missing: #{e.param}", status: :bad_request
  end

  def create
    params.require(:book).permit(id: Parameters.integer)

    head :ok
  end
end

describe BooksController do
  it 'rejects invalid params' do
    post "/books", params: {magazine: {name: 'Mjallo!'}}
    assert_response :bad_request
    response.body.must_equal 'Required parameter missing: book'

    post "/books", params: {book: {id: 'Mjallo!'}}
    assert_response :bad_request
    response.body.must_equal 'Invalid parameter: id must be an integer'
  end

  it 'permits valid params' do
    post "/books", params: {book: {id: '123'}}
    assert_response :ok
  end
end
