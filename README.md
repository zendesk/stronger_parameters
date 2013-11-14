# stronger_parameters

This is an extension of `strong_parameters` with added type checking.

## Simple types
You can specify simple types like this:

```ruby
params.permit(
  :id   => Parameters.id,
  :name => Parameters.string
)
```

## Arrays
You can specify arrays like this:

```ruby
params.permit(
  :id => Parameters.array(Parameters.id)
)
```

This will allow an array of id parameters that all are IDs.

## Nested Parameters

```ruby
params.permit(
  :name    => Parameters.string,
  :emails  => Parameters.array(Parameters.string),
  :friends => Parameters.array(
    Parameters.map(
      :name   => Parameters.string,
      :family => Parameters.map(
        :name => Parameters.string
      )
      :hobbies => Parameters.array(Parameters.string)
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
  :name => Parameters.string,
  :books_attributes => Parameters.array(
    Parameters.map(
      :title => Parameters.string,
      :id => Parameters.id,
      :_destroy => Parameters.boolean
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
  :status => Parameters.id | Parameters.enum('open', 'closed')
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
  :age => Parameters.integer & Parameters.gte(0)
)
```

This requires the parameter to be an integer greater than or equal to 0.

### Combining Requirements in Arrays

You can also use the `|` and `&` operators in arrays:

```ruby
params.require(:group).permit(
  :users => Parameters.array(Parameters.id | Parameters.string)
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

## Types

| Syntax                         | (Simplified) Definition                                                 |
|--------------------------------|-------------------------------------------------------------------------|
| Parameters.string              | value.is_a?(String)                                                     |
| Parameters.integer             | value.is_a?(Fixnum)                                                     |
| Parameters.enum('asc', 'desc') | ['asc', 'desc'].include?(value)                                         |
| Parameters.lt(10)              | value < 10                                                              |
| Parameters.lte(10)             | value <= 10                                                             |
| Parameters.gt(0)               | value > 0                                                               |
| Parameters.gte(0)              | value >= 0                                                              |
| Parameters.integer32           | Parameters.integer & Parameters.lte(2 ** 31) & Parameters.gte(-2 ** 31) |
| Parameters.integer64           | Parameters.integer & Parameters.lte(2 ** 63) & Parameters.gte(-2 ** 63) |
| Parameters.id                  | Parameters.integer & Parameters.lte(2 ** 31) & Parameters.gte(0)        |
| Parameters.bigid               | Parameters.integer & Parameters.lte(2 ** 63) & Parameters.gte(0)        |
| Parameters.boolean             | Parameters.enum(true, false, 'true', 'false', 1, 0)                     |
