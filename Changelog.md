# v2.3.0
 - decimal constraint

# v2.2.0
 - file type constraint

# v2.1.0
 - encoding fixes

# v2.0.0
 - no longer raises `StrongerParameters::InvalidParameter` inside of constraints: make your custom constraints return `StrongerParameters::InvalidValue` instead
 - added new `Parameters.nil`
 - added new `Parameters.float`
 - added new `Parameters.regexp`
 - added new `Parameters.null_string`
 - added new unsigned `Parameters.ubigid` and `Parameters.uid`
 - WARNING: no longer accepts `nil` for all parameters, use ` | Parameters.nil`, for transition period you can use this to log all calls that would result in `StrongerParameters::InvalidParameter`, alternatively keep nils and use `ActionController::Parameters.allow_nil_for_everything = true`
 - `action_on_invalid_parameters` will now raise by default
 - `action_on_invalid_parameters` is now set on `ActionController::Parameters`

```Ruby
# tested in test/unit/zendesk/extensions/strong_parameters_test.rb
# remove once we no longer see log messages in production
ActionController::Parameters.action_on_invalid_parameters = lambda do |result, key|
  if result.value.nil? && Rails.env.production?
    Rails.logger.error("Previously allowed nil value passed #{key} -- #{result.message}")
  else
    # default action
    raise StrongerParameters::InvalidParameter.new(result, key)
  end
end
```

