# Katalyst::Tables::Sortable

`Sortable` adds column sorting to tables by wrapping the contents of the header cell with a link.
This link contains the sorting configuration for the column. When clicked, the table will be re-rendered
with the contents of the table sorted by that column. The direction of the sort is toggled between `asc` and `desc`.

The link will also contain a `data-turbo-action` attribute with the value `replace`.
This will cause the table to be re-rendered using Turbo's `replace` action, utilising Morph to only update the table body where needed.

```html
<table>
  <thead>
  <th data-sort="asc"><a data-turbo-action="replace" href="/people?sort=name+desc">Name</a></th>
  </thead>
  <tbody>
    <tr><td>John Doe</td></tr>
  </tbody>
</table>
```

## Usage

Sorting will be applied if the collection is configured with a default
sorting configuration. This can be done by either specifying a default 
config on the collection. or by passing a sorting configuration to the initializer.

### Collection Configuration
```ruby
class Collection < Katalyst::Collection::Base
  config.sorting = "column direction"
end
```

### Initializer Configuration
```ruby
Katalyst::Collection::Base.new(sorting: "column direction")
```

When sort is enabled, table columns will be automatically sortable in the
frontend for any column that corresponds to an attribute on the model.

You can also add sorting to non-attribute columns by defining a scope in your
model:

```ruby
scope :order_by_status, ->(direction) { ... }
```
