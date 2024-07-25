---
layout: default
title: Query
parent: Collections
grand_parent: Developers
nav_order: 4
---

# Query

`Katalyst::Tables::Collection::Query` adds support to controllers that allows users to type a semi-structured query
string that will be parsed, and arguments sanitized and assigned to [filter](filtering) attributes.

When coupled with [table_query_with](../frontend/filtering) in the frontend, the collection can generate suggestions for
the user based on the current position of their cursor (`p`) and live-update the frontend using Turbo Morph to show
context help for the user as they type their query.

## Usage

To use the `Query` module, include it in your collection class and define the attributes you want to filter on. Query
automatically includes the `Filter` module as well.

```ruby
class Collection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Query

  attribute :search, :search, scope: :table_search
  attribute :id, :integer, multiple: true
  attribute :name, :string
  attribute :active, :boolean
  attribute :category, :enum
  attribute :"parent.name", :string
  attribute :"parent.id", :integer
end
```

## Basic search

The `Query` module supports basic string inputs, which it passes to a `search` attribute (type: `:search`) if defined.

```ruby
class Collection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Query
  
  attribute :custom_search, :search, scope: :custom_search
end

collection.with_params(q: "test").apply(Resource.all).items
# => Resource.custom_search("test")
```

Search attributes require a scope (`custom_search`), which should be defined on your model and take a string as input.
For example, you could refer to a `pg_search` scope defined in the model.

### Tagged inputs

Attributes with types can be completed using tagged and typed inputs. For example:

```ruby
# In the collection
attribute :active, :boolean

# In the controller
collection.with_params(q: "active:true").filters
# => { "active" => true }
```

Values can be quoted, e.g., if they contain spaces:
```ruby
collection.with_params(q: 'active:"true"').filters
# => { "active" => true }
```

### Multi-value inputs

Some attributes support multiple values. Enums support this by default, while integers, floats, and booleans can be
configured to accept multiple inputs. Example: `attribute :id, :integer, multiple: true`.

```ruby
collection.with_params(q: "category:report")
# => { "category" => ["report"] }
collection.with_params(q: "category: [article, report]")
# => { "category" => ["article", "report"] }
collection.with_params(q: 'category:["article", "report"]')
# => { "category" => ["article", "report"] }
```

### Range inputs

Continuous values like dates, integers, and floats support range inputs. These are enabled by default, and users can
filter on a range by specifying open or closed ranges. For example:

```ruby
collection.with_params(q: "created_at:..2024-01-01")
# => { "created_at" => ..2024-01-01 }
collection.with_params(q: "created_at:2024-01-01..")
# => { "created_at" => 2024-01-01.. }
collection.with_params(q: "created_at:2024-01-01..2025-01-01")
# => { "created_at" => 2024-01-01..2025-01-01 }
```

### String inputs

String inputs are automatically matched using `Arel::Predicates#matches` (substring matching).

```ruby
collection.with_params(q: "first_name:Aaron")
# => where(arel_table[:first_name].matches("%Aaron%"))
```

You can configure exact (equality) matching instead with attribute configuration:
`attribute :first_name, :string, exact: true`.

### Associations

Filtering supports joining on `belongs_to` associations. These can be filtered using `model.key` tagged inputs:

```ruby
collection.with_params(q: "parent.name:test")
# => { "parent.name" => "test" }
collection.with_params(q: "parent.id:[15]")
# => { "parent.id" => [15] }
```

### Unsupported Queries

Queries with unsupported tags or unknown keys are ignored.

```ruby
collection.with_params(q: "unknown:true")
# => {}
collection.with_params(q: "boom.name:test")
# => {}
```

### Synthetic attributes

If you want to provide filtering on an attribute that is not backed by a database column, you can configure a scope to
use instead. For example:

```ruby
attribute :active, :enum, scope: :active, multiple: false, default: "active"

# in your model:
scope :active, ->(active) do
  case active
  when "active"
    where.not(activated_at: nil)
  when "inactive"
    where(activated_at: nil)
  else
    unscope(where: :activated_at)
  end
end
```

If your scope needs examples from the database, you can define `<attribute>_examples` in your collection:

```ruby
def active_examples
  %w[active inactive all]
end
```

### Example

Here is an example of using the `Query` module with a collection:

```ruby
class Collection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Query

  attribute :id, :integer, multiple: true
  attribute :search, :search, scope: :table_search
  attribute :name, :string
  attribute :active, :boolean
  attribute :category, :enum
  attribute :"parent.name", :string
  attribute :"parent.id", :integer
end

collection = MyCollection.new
collection.with_params(q: "active:true category:[article,report] parent.id:15")
# => { "active" => true, "category" => ["article", "report"], "parent.id" => 15 }
```
