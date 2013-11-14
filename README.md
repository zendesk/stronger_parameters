# stronger_parameters

This is an extension of `strong_parameters` with added type checking.

## Simple types
You can specify simple types like this:

```ruby
params.permit(:id => Parameters.id, :name => Parameters.string)
```

## Arrays
You can specify arrays like this:

```ruby
params.permit(:id => Parameters.array(Parameters.id))
```

This will allow an array of id parameters that all are IDs.

## Nested parameters

```ruby
params.permit(
  :name => Parameters.string,
  :emails => Parameters.array(Parameters.email),
  :friends => Parameters.array(
    Parameters.map(
      :name => Parameters.string,
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

Strange numbered arrays in ActiveModel nested attributes look something like this:

```json
{
  "book": {
    "title": "Some Book",
    "chapters_attributes": {
      "1": {"title": "First Chapter"},
      "2": {"title": "Second Chapter"}
    }
  }
}
```

and can be described like this:

```ruby
params.require(:book).permit(
  :title => Parameters.string,
  :chapters_attributes => Parameters.map(
    Parameters.integer => Parameters.map(
      :title => Parameters.string
    )
  )
)

```

## Combining Requirements

If you want to permit a parameter to be one of multiple types, you can use the `|` operator:

```ruby
params.require(:ticket).permit(:requester => Parameters.id | Parameters.email)
```

This will allow these parameter sets:

```json
{
  "ticket": {
    "requester": 123
  }
}
```
```json
{
  "ticket": {
    "requester": "mick@zendesk.com"
  }
}
```

You can use the `&` operator to apply further restrictions on the type:

```ruby
params.require(:user).permit(:email => Parameters.email & Parameters.max_length(128))
```

This requires the parameter to be an email and to be no longer than 128 bytes.

### Combining Requirements in Arrays

You can also use the `|` and `&` operators in arrays:

```ruby
params.require(:group).permit(:users => Parameters.array(Parameters.id | Parameters.email))
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

| Syntax                         | Definition                                                              |
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
| Parameters.id                  | Parameters.integer32 & Parameters.positive                              |
| Parameters.bigid               | Parameters.integer64 & Parameters.positive                              |
| Parameters.boolean             | Parameters.enum(true, false, 'true', 'false', 1, 0)                     |
