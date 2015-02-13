require_relative 'test_helper'

describe 'regexp parameter constraints' do
  subject { ActionController::Parameters.regexp(/\Aab?c\Z/) }

  permits 'abc'
  permits 'ac'

  rejects 123
  rejects nil
  rejects 'abbc'

  it "rejects non-strings with string constraint" do
    subject.value(123).message.must_equal "must be a string"
  end

  describe "#==" do
    it "is not equal to other" do
      subject.wont_equal ActionController::Parameters.regexp(/\Aabc\Z/)
    end

    it "is equal to self" do
      subject.must_equal subject
    end

    it "is equal to same regexp" do
      subject.must_equal ActionController::Parameters.regexp(/\Aab?c\Z/)
    end
  end
end
