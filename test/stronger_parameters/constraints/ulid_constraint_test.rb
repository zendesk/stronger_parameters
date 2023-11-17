# frozen_string_literal: true

require_relative "../../test_helper"

SingleCov.covered!

describe StrongerParameters::UlidConstraint do
  subject { ActionController::Parameters.ulid }
  rejects 123
  rejects Date.today
  rejects Time.now
  rejects nil
  rejects "01GTJ6C0NF1MQX0KFZMS1RHTY" # short
  rejects "01GTJ6C0NF1MQX0KFZMS1RHT-!" # special char
  rejects "0IGTJ6C0NF1MQX0KFZMS1RHTYF" # i
  rejects "0LGTJ6C0NF1MQX0KFZMS1RHTYF" # l
  rejects "O1GTJ6C0NF1MQX0KFZMS1RHTYF" # o
  rejects "01GTJ6C0NF1MQX0KFZMS1RHTYU" # u

  permits "01GTJ6C0NF1MQX0KFZMS1RHTYF"
  permits "01GTJ6C0NF1MQX0KFZMS1RHTYF".downcase
end
