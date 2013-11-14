# stronger_parameters

This is an extension of `strong_parameters` with added type checking.

## Simple types
You can specify simple types like this:

```ruby
params.permit(:id => Params.id, :name => Params.string)
```

## Arrays
You can specify arrays like this:

```ruby
params.permit(:id => Params.array(Params.id))
```

This will allow an array of id parameters that all are IDs.

## Nested parameters

```ruby
params.permit(
  :name => Params.string,
  :emails => Params.array(Params.email),
  :friends => Params.array(
    Params.map(
      :name => Params.string,
      :family => Params.map(
        :name => Params.string
      )
      :hobbies => Params.array(Params.string)
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
  :name => Params.string,
  :books_attributes => Params.array(
    Params.map(
      :title => Params.string,
      :id => Params.id,
      :_destroy => Params.boolean
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
  :title => Params.string,
  :chapters_attributes => Params.map(
    Params.integer => Params.map(
      :title => Params.string
    )
  )
)

```

## Combining Requirements

If you want to permit a parameter to be one of multiple types, you can use the `|` operator:

```ruby
params.require(:ticket).permit(:requester => Params.id | Params.email)
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
params.require(:user).permit(:email => Params.email & Params.max_length(128))
```

This requires the parameter to be an email and to be no longer than 128 bytes.

### Combining Requirements in Arrays

You can also use the `|` and `&` operators in arrays:

```ruby
params.require(:group).permit(:users => Params.array(Params.id | Params.email))
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

| syntax                     | definition                                                  |
|----------------------------|-------------------------------------------------------------|
| Params.string              | value.is_a?(String)                                         |
| Params.integer             | value.is_a?(Fixnum)                                         |
| Params.enum('asc', 'desc') | ['asc', 'desc'].include?(value)                             |
| Params.lt(10)              | value < 10                                                  |
| Params.lte(10)             | value <= 10                                                 |
| Params.gt(0)               | value > 0                                                   |
| Params.gte(0)              | value >= 0                                                  |
| Params.integer32           | Params.integer & Params.lte(2 ** 31) & Params.gte(-2 ** 31) |
| Params.integer64           | Params.integer & Params.lte(2 ** 63) & Params.gte(-2 ** 63) |
| Params.id                  | Params.integer32 & Params.positive                          |
| Params.bigid               | Params.integer64 & Params.positive                          |
| Params.boolean             | Params.enum(true, false, 'true', 'false', 1, 0)             |
