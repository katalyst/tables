---
layout: default
title: Sorting
parent: Collections
grand_parent: Developers
nav_order: 1
---

# Sorting

`Katalyst::Tables::Sortable` adds column sorting to tables by wrapping the contents of the header cell with a link. This
link contains the sorting configuration for the column. When clicked, the table will be re-rendered with the contents of
the table sorted by that column. The direction of the sort is toggled between `asc` and `desc`.

## Usage

Sorting will be applied if the collection is configured with a default sorting configuration. This can be done by either
specifying a default config on the collection or by passing a sorting configuration to the initializer.

### Collection Configuration
```ruby
class Collection < Katalyst::Tables::Collection::Base
  config.sorting = "column direction"
end
```

### Initializer Configuration
```ruby
Katalyst::Tables::Collection::Base.new(sorting: "column direction")
```

When sort is enabled, table columns will be automatically sortable in the frontend for any column that corresponds to an
attribute on the model.

You can also add sorting to non-attribute columns by defining a scope prefixed with `order_by_` in your model:

```ruby
scope :order_by_status, ->(direction) { ... }
```

These custom scopes can also be applied as the default sort by omitting the prefix:

```ruby
config.sorting = "status asc"
```
