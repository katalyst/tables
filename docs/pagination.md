# Katalyst::Tables::Collection::Pagination

`Pagination` - Adds pagination support for a collection.

This gem is designed to work with [pagy](https://github.com/ddnexus/pagy/).

If you use collections and enable pagination then pagy will be called internally
and the pagy metadata will be available as `pagination` on the collection.

## Usage

Pagination will be applied if the collection is configured with a default
pagination configuration. This can be done by either specifying a default 
config on the collection. or by passing a pagination configuration to the initializer.

### Collection Configuration
```ruby
class Collection < Katalyst::Collection::Base
  config.paginate = true
end
```

#### Passing options to pagy
```ruby
class Collection < Katalyst::Collection::Base
  config.paginate = { limit: 10 }
end
```

### Initializer Configuration
```ruby
Katalyst::Collection::Base.new(paginate: true)
```

#### Passing options to pagy
```ruby
Katalyst::Collection::Base.new(paginate: { limit: 10 })
```

When pagination is enabled, table rows will be automatically paginated
prior to rendering the table. The pagy metadata will be available as `pagination` 
for you to use your preferred method of pagination control rendering.

`Frontend` provides `table_pagination_with` for rendering with sensible defaults:

```erb
<%= table_pagination_with(collection:) %>
```
