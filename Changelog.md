# NEXT

# v2.6.0
- rails 7 support
- rails 4 removed

# v2.15.0.1
- Yanked

# v2.14.1.1
- Allow boolean string values of any casing (eg "TRUE")

# v2.14.0
- Allow strings of numbers with whitespace (eg " 123")

# v2.13.0
- rails 6.1 support
- drop rails 3 support
- drop ruby 2.4 support

# v2.12.0
- allow parameters to be marked as required (refs GH#72)

# v2.8.0
- Controller support (PermittedParameters)

# v2.7.0
- Add key to error message

# v2.6.0
 - add hex constraint

# v2.5.0
 - rails 5.0 support
 - fix type, null_string => nil_string
 - allow the value "on" to be considered boolean

# v2.4.0
 - support string minimum_size

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
 - added new `Parameters.nil_string`
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

