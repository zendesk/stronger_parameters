# v2.0.0 (unreleased)
 - no longer raises `StrongerParameters::InvalidParameter` inside of constraints: make your custom constraints return `StrongerParameters::InvalidValue` instead
 - added new `Parameters.nil`
 - added new `Parameters.float`
 - added new `Parameters.regexp`
 - added new `Parameters.null_string`
 - added new unsigned `Parameters.ubigid` and `Parameters.uid`
 - WARNING: no longer accepts `nil` for all parameters, use ` | Parameters.nil`, for transition period you can use this to log all calls that would result in `StrongerParameters::InvalidParameter`

```Ruby
# tested in test/unit/zendesk/extensions/strong_parameters_test.rb
# remove once we no longer see log messages in production
config.action_controller.action_on_invalid_parameters = lambda do |result, key|
  if result.value.nil? && Rails.env.production?
    Rails.logger.error("Previously allowed nil value passed #{key} -- #{result.message}")
  else
    # default action
    raise StrongerParameters::InvalidParameter.new(result, key)
  end
end
```

