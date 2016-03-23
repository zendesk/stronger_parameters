require_relative 'test_helper'

class BooksController < ActionController::Base
  def create
    params.require(:book).permit(:id => Parameters.integer)

    head :ok
  end
end

describe BooksController do
  it 'rejects invalid params' do
    if Rails::VERSION::MAJOR < 5
      post :create, { :magazine => { :name => 'Mjallo!' } }
    else
      post :create, :params => { :magazine => { :name => 'Mjallo!' } }
    end
    assert_response :bad_request
    response.body.must_equal 'Required parameter missing: book'

    if Rails::VERSION::MAJOR < 5
      post :create, { :book => { :id => 'Mjallo!' } }
    else
      post :create, :params => { :book => { :id => 'Mjallo!' } }
    end
    assert_response :bad_request
    response.body.must_equal 'Invalid parameter: id id => must be an integer'
  end

  it 'permits valid params' do
    if Rails::VERSION::MAJOR < 5
      post :create, { :book => { :id => '123' } }
    else
      post :create, :params => { :book => { :id => '123' } }
    end
    assert_response :ok
  end
end
