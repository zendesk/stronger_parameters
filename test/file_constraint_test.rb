require_relative 'test_helper'

describe 'io parameter constraints' do
  subject { ActionController::Parameters.file }

  permits StringIO.new('test')
  permits File.new('.')
  permits Rack::Test::UploadedFile.new('./README.md')
  permits ActionDispatch::Http::UploadedFile.new(tempfile: Tempfile.new('test'))

  rejects 123
  rejects Date.today
  rejects Time.now
  rejects nil
end
