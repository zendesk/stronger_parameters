# frozen_string_literal: true

require_relative "test_helper"

SingleCov.not_covered!

class BooksController < ActionController::Base
  ROUTES = ActionDispatch::Routing::RouteSet.new
  ROUTES.draw { resources :books }
  include ROUTES.url_helpers

  rescue_from(ActionController::ParameterMissing) do |e|
    if request.format.to_s.include?("json")
      render json: {error: "Required parameter missing: #{e.param}"}, status: :bad_request
    else
      render plain: "Required parameter missing: #{e.param}", status: :bad_request
    end
  end

  def create
    if Rails::VERSION::MAJOR >= 8
      params.expect(book: {id: Parameters.integer})
    else
      params.require(:book).permit(id: Parameters.integer)
    end

    head :ok
  end
end

describe BooksController do
  before { @routes = BooksController::ROUTES }

  context "for text format" do
    it "rejects invalid params" do
      post :create, params: {magazine: {name: "Mjallo!"}}
      assert_response :bad_request
      response.body.must_equal "Required parameter missing: book"

      post :create, params: {book: {id: "Mjallo!"}}
      assert_response :bad_request
      response.body.must_equal "Invalid parameter: id must be an integer"
    end

    it "permits valid params" do
      post :create, params: {book: {id: "123"}}
      assert_response :ok
    end
  end

  context "for json format" do
    it "rejects invalid params" do
      post :create, params: {magazine: {name: "Mjallo!"}}, format: :json
      assert_response :bad_request
      JSON.parse(response.body)["error"].must_equal "Required parameter missing: book"

      post :create, params: {book: {id: "Mjallo!"}}, format: :json
      assert_response :bad_request
      JSON.parse(response.body)["error"].must_equal "Invalid parameter: id must be an integer"
    end

    it "permits valid params" do
      post :create, params: {book: {id: "123"}}, format: :json
      assert_response :ok
    end
  end
end
