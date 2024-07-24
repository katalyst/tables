---
layout: default
title: Query
parent: Developers
nav_order: 5
---

# Query

Include `Katalyst::Tables::Collection::Query` into your collection to add automatic
query parsing and filtering based on the configured attributes. For example:

```ruby
class Collection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Query
  
  attribute :first_name, :string
  attribute :created_at, :date
end
```

With this definition and a text-input named `query`, your users can write tagged
query expressions such as `first_name:Aaron` or `created_at:>2024-01-01` and these
will be automatically parsed and applied to the collection attribute, and the collection
will automatically generate and apply ActiveRecord conditions to filter the given scope.

There's also a frontend utility, `table_query_with(collection:)` that will generate the form
and show a modal that helps users to interact with the query interface.

More details available in the [query extension](extensions/query) documentation.
