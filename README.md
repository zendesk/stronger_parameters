# stronger_parameters
[![Build Status](https://travis-ci.org/zendesk/stronger_parameters.svg?branch=master)](https://travis-ci.org/zendesk/stronger_parameters)

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
Rails converts empty arrays to nil unless `config.action_dispatch.perform_deep_munge = false` is set
(available in Rails 4.1+). Either use this or `Parameters.array | Parameters.nil` to deal with this.

### Allowing nils

It can be convenient to allow nil to be passed as all kinds of attributes since ActiveRecord converts it to false/0 behind the scenes.
`ActionController::Parameters.allow_nil_for_everything = true`

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
      )
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

## Production rollout

Just want to log violations in production:

```Ruby
# config/environments/production.rb
ActionController::Parameters.action_on_invalid_parameters = :log
```

## Types

| Syntax                         | (Simplified) Definition                                                                    |
|--------------------------------|--------------------------------------------------------------------------------------------|
| Parameters.string              | value.is_a?(String)                                                                        |
| Parameters.integer             | value.is_a?(Fixnum) or '-1'                                                                |
| Parameters.float               | value.is_a?(Float) or '-1.2'                                                               |
| Parameters.datetime            | value.is_a?(DateTime) or '2014-05-13' or '2015-03-31T14:34:56Z'                            |
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
