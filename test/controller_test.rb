require_relative 'test_helper'

class BooksController < ActionController::Base
  def create
    params.require(:book).permit(:id => Parameters.integer)

    head :ok
  end
end

describe BooksController do
  it 'rejects invalid params' do
    post :create, { :magazine => { :name => 'Mjallo!' } }
    assert_response :bad_request
    response.body.must_equal 'Required parameter missing: book'

    post :create, { :book => { :id => 'Mjallo!' } }
    assert_response :bad_request
    response.body.must_equal 'Invalid parameter: id must be an integer'
  end

  it 'permits valid params' do
    post :create, { :book => { :id => '123' } }
    assert_response :ok
  end
end
