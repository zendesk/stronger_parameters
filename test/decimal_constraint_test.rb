require_relative 'test_helper'

describe 'decimal parameter constraints' do
  describe 'with 2 scale and 4 precision' do
    subject { ActionController::Parameters.decimal(4, 2) }

    permits '1.23', as: 1.23
    permits '-1.23', as: -1.23
    permits 1.23
    permits -1.23

    permits '12.34', as: 12.34
    permits '-12.34', as: -12.34
    permits 12.34
    permits -12.34

    permits 1
    permits -1
    permits '1', as: 1
    permits '-1', as: -1

    permits '1.2', as: 1.2
    permits '-1.2', as: -1.2
    permits 1.2
    permits -1.2

    rejects '123', as: 123
    rejects '-123', as: -123
    rejects 123
    rejects -123

    rejects 'abc'
    rejects '1.2.3'
    rejects '.3'
    rejects '3.'
    rejects true

    rejects '1234', as: 1234
    rejects '-1234', as: -1234
    rejects 1234
    rejects -1234

    rejects '1.234', as: 1.234
    rejects '-1.234', as: -1.234
    rejects 1.234
    rejects -1.234

    rejects '123.45', as: 123.45
    rejects '-123.45', as: 123.45
    rejects 123.45
    rejects -123.45
  end

  describe 'with 0 scale and 5 precision' do
    subject { ActionController::Parameters.decimal(5, 0) }

    permits 1
    permits '1', as: 1
    permits -1
    permits '-1', as: -1

    permits 12345
    permits '12345', as: 12345
    permits -12345
    permits '-12345', as: -12345

    rejects 'abc'
    rejects '1.2.3'
    rejects '.3'
    rejects '3.'
    rejects true

    rejects '1.23', as: 1.23
    rejects '-1.23', as: -1.23
    rejects 1.23
    rejects -1.23

    rejects 123456
    rejects '123456', as: 123456
    rejects -123456
    rejects '-123456', as: -123456
  end
end
