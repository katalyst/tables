# Katalyst::Tables::Collection::Query

`Query` - Adds query parsing support for filtering collections based on a query parameter.

The `Query` module allows you to define attributes in your collection model that can be populated using a human-friendly query input. The module parses the query string and extracts attribute values.

## Usage

To use the `Query` module, include it in your collection class and define the attributes you want to filter on.

#### Collection Configuration

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
```

## User inputs

The `Query` module supports basic string inputs, which it applies to a `search` attribute (type: `:search`) if defined.

```ruby
collection.with_params(query: "test")
# => { "search" => "test" }
collection.with_params(query: "active status")
# => { "search" => "active status" }
collection.with_params(query: '"active status"')
# => { "search" => '"active status"' }
```

The named scope should be defined on your model and take a string as input. A good example would be a pg_search scope. 

### Tagged inputs

Attributes with types can be completed using tagged and typed inputs. For example:

```ruby
# In the collection
attribute :active, :boolean
# In the controller
collection.with_params(query: "active:true").filters
# => { "active" => true }
```

Values can be quoted, e.g. if they contain spaces:
```ruby
collection.with_params(query: 'active:"true"').filters
# => { "active" => true }
```

### Multi-value inputs

Some attributes support multiple values. Enums support this by default, while integers, floats, and booleans
can be configured to accept multiple inputs. Example: `attribute :id, :integer, multiple: true`.

```ruby
collection.with_params(query: "category:report")
# => { "category" => ["report"] }
collection.with_params(query: "category: [article, report]")
# => { "category" => ["article", "report"] }
collection.with_params(query: 'category:["article", "report"]')
# => { "category" => ["article", "report"] }
```

### Range inputs

Continuous values like dates, integers, and floats support range inputs. These are enabled by default and
users can filter on a range by specifying open or closed ranges. For example:

```ruby
collection.with_params(query: "created_at:<2024-01-01")
# => { "created_at" => ..2024-01-01 }
collection.with_params(query: "created_at:>2024-01-01")
# => { "created_at" => 2024-01-01.. }
collection.with_params(query: "created_at:2024-01-01..2025-01-01")
# => { "created_at" => 2024-01-01..2025-01-01 }
```

### String inputs

String inputs are automatically matched using `Arel::Predicates#matches` (substring matching).

```ruby
collection.with_params(query: "first_name:Aaron")
# => where(arel_table[:first_name].matches("%Aaron%"))
```

You can configure exact (equality) matching instead with attribute configuration:
`attribute :first_name, :string, exact: true`.

### Associations

Filtering supports joining on `belongs_to` associations. These can be filtered using `model.key` tagged inputs:

```ruby
collection.with_params(query: "parent.name:test")
# => { "parent.name" => "test" }
collection.with_params(query: "parent.id:[15]")
# => { "parent.id" => [15] }
```

### Unsupported Queries

Queries with unsupported tags or unknown keys are ignored.

```ruby
collection.with_params(query: "unknown:true")
# => {}
collection.with_params(query: "boom.name:test")
# => {}
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
collection.with_params(query: "active:true category:[article,report] parent.id:15")
# => { "active" => true, "category" => ["article", "report"], "parent.id" => 15 }
```
