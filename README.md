# stronger_parameters
![CI](https://github.com/zendesk/stronger_parameters/workflows/CI/badge.svg)

This is an extension of `strong_parameters` with added type checking and conversion.

## Simple types
You can specify simple types like this:

```ruby
params.permit(
  id: Parameters.id,
  name: Parameters.string
)
```

## Arrays
You can specify arrays like this:

```ruby
params.permit(
  id: Parameters.array(Parameters.id)
)
```

This will allow an array of id parameters that all are IDs (integer less than 2**31, greater than 0) and convert to Fixnum (`'2' --> 2`).

### Empty array -> nil
Rails converts empty arrays to nil, so often `Parameters.array | Parameters.nil` is needed.

### Allowing nils

It can be convenient to allow nil for all attributes since ActiveRecord converts it to false/0.
`ActionController::Parameters.allow_nil_for_everything = true`

### Rejecting nils

You can reject a request that fails to supply certain parameters by marking them
as required with the `.required` operator:

```ruby
params.permit(
  name: Parameters.string.required, # will not accept a nil or a non-String
  email: Parameters.string          # optional, may be omitted
)
```

This also works in conjunction with the `&` and `|` constraints. For example, to
express that a `uid` must be either a string or a number:

```ruby
params.permit(
  uid: (Parameters.string | Parameters.integer).required
)
```

## Nested Parameters

```ruby
params.permit(
  name: Parameters.string,
  emails: Parameters.array(Parameters.string),
  friends: Parameters.array(
    Parameters.map(
      name: Parameters.string,
      family: Parameters.map(
        name: Parameters.string
      ),
      hobbies: Parameters.array(Parameters.string)
    )
  )
)
```

This will allow parameters like this:

```json
{
  "name": "Mick",
  "emails": ["mick@zendesk.com", "mick@staugaard.com"],
  "friends": [
    {"name": "Morten", "family": {"name": "Primdahl"}, "hobbies": ["work", "art"]},
    {"name": "Eric", "family": {"name": "Chapweske"}, "hobbies": ["boating", "whiskey"]}
  ]
}
```

### ActiveModel Nested Attributes

```ruby
params.require(:author).permit(
  name: Parameters.string,
  books_attributes: Parameters.array(
    Parameters.map(
      title: Parameters.string,
      id: Parameters.id,
      _destroy: Parameters.boolean
    )
  )
)
```

This will allow parameters like this:

```json
{
  "author": {
    "name": "Eric Chapweske",
    "books_attributes": [
      {"title": "Boatin' and Drinkin'", "id": 234, "_destroy": true},
      {"title": "Advanced Boatin' and Drinkin'", "id": 567}
    ]
  }
}
```

## Combining Requirements

If you want to permit a parameter to be one of multiple types, you can use the `|` operator:

```ruby
params.require(:ticket).permit(
  status: Parameters.id | Parameters.enum('open', 'closed')
)
```

This will allow these parameter sets:

```json
{
  "ticket": {
    "status": 123
  }
}
```
```json
{
  "ticket": {
    "status": "open"
  }
}
```

You can use the `&` operator to apply further restrictions on the type:

```ruby
params.require(:user).permit(
  age: Parameters.integer & Parameters.gte(0)
)
```

This requires the parameter to be an integer greater than or equal to 0.

### Combining Requirements in Arrays

You can also use the `|` and `&` operators in arrays:

```ruby
params.require(:group).permit(
  users: Parameters.array(Parameters.id | Parameters.string)
)
```

This will permit these parameters:
```json
{
  "group": {
    "users": [123, "mick@zendesk.com", 345, 676, "morten@zendesk.com"]
  }
}
```

## Rollout in log-only mode

Just want to log violations in production:

```Ruby
# config/environments/production.rb
ActionController::Parameters.action_on_invalid_parameters = :log
```

## Controller support

Include `PermittedParameters` into a controller to force the developer
to explicitly permit params for every action.

Examples:

```ruby
class TestController < ApplicationController
  include StrongerParameters::ControllerSupport::PermittedParameters

  permitted_parameters :all, locale: Parameters.string # permit :locale in all actions for this controller

  permitted_parameters :show, id: Parameters.integer
  def show
  end

  permitted_parameters :create, topic: { forum: { id: Parameters.integer } }
  def create
  end

  permitted_parameters :index, {} # no parameters permitted
  def index
  end

  permitted_parameters :update, :skip # use when migrating old controllers/actions
  def update
  end
end
```


### Log only mode for invalid parameters

To only log invalid (not unpermitted) parameters during rollout of stronger_parameters:

```ruby
class MyController < ApplicationController
  log_invalid_parameters! if Rails.env.production? # Still want other environments and controllers to raise

  permitted_parameters :update, user: { name: Parameters.string }
  def update
  end
end
```

### Notifying users about unpermitted params

Add headers to all requests that have unpermitted params (does not log invalid):

```Ruby
# config/application.rb
config.stronger_parameters_violation_header = 'X-StrongerParameters-API-Warn'
```

```shell
curl -I 'http://localhost/api/users/1.json' -X POST -d '{ "user": { "id": 1 } }'
=> HTTP/1.1 200 OK
=> ...
=> X-StrongerParameters-API-Warn: Removed restricted keys ["user.id"] from parameters
```

## Types

| Syntax                         | (Simplified) Definition                                                                    |
|--------------------------------|--------------------------------------------------------------------------------------------|
| Parameters.string              | value.is_a?(String)                                                                        |
| Parameters.integer             | value.is_a?(Fixnum) or '-1'                                                                |
| Parameters.float               | value.is_a?(Float) or '-1.2'                                                               |
| Parameters.date                | value.is_a?(Date) or '2014-05-13' or '13.05.2014'                                          |
| Parameters.date_iso8601        | value is a date that conforms to ISO8601: '2014-05-13'                                     |
| Parameters.time                | value.is_a?(Time) or '2014-05-13' or '2015-03-31 14:34:56 +0000'                           |
| Parameters.time_iso8601        | value is a time that conforms to ISO8601: '2014-05-13' or '2015-03-31T14:34:56Z'           |
| Parameters.datetime            | value.is_a?(DateTime) or '2014-05-13' or '2015-03-31T14:34:56Z'                            |
| Parameters.datetime_iso8601    | value is a date that conforms to ISO8601: '2014-05-13' or '2015-03-31T14:34:56Z'           |
| Parameters.regexp(/foo/)       | value =~ regexp                                                                            |
| Parameters.enum('asc', 'desc') | ['asc', 'desc'].include?(value)                                                            |
| Parameters.lt(10)              | value < 10                                                                                 |
| Parameters.lte(10)             | value <= 10                                                                                |
| Parameters.gt(0)               | value > 0                                                                                  |
| Parameters.gte(0)              | value >= 0                                                                                 |
| Parameters.integer32           | Parameters.integer & Parameters.lt(2 ** 31) & Parameters.gte(-2 ** 31)                     |
| Parameters.integer64           | Parameters.integer & Parameters.lt(2 ** 63) & Parameters.gte(-2 ** 63)                     |
| Parameters.id                  | Parameters.integer & Parameters.lt(2 ** 31) & Parameters.gte(0)                            |
| Parameters.bigid               | Parameters.integer & Parameters.lt(2 ** 63) & Parameters.gte(0)                            |
| Parameters.uid                 | Parameters.integer & Parameters.lt(2 ** 32) & Parameters.gte(0)                            |
| Parameters.ubigid              | Parameters.integer & Parameters.lt(2 ** 64) & Parameters.gte(0)                            |
| Parameters.boolean             | Parameters.enum(true, false, 'true', 'false', 1, 0)                                        |
| Parameters.nil                 | value is nil                                                                               |
| Parameters.nil_string          | value is nil, '', 'undefined'                                                              |
| Parameters.file                | File, StringIO, Rack::Test::UploadedFile, ActionDispatch::Http::UploadedFile or subclasses |
| Parameters.decimal(8,2)        | value is a String, Integer or Float with a precision of 9 and scale of 2                   |
| Parameters.hex                  | value is a String that matches the hexadecimal format |

## Development

### Releasing a new version

```
git checkout master && git fetch origin && git reset --hard origin/master
bundle exec rake bump:<patch|minor|major>
git tag v<tag>
git push --tags
```

[github action](.github/workflows/ruby-gem-publication.yml) will release a new version to rubygems.org
