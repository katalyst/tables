# Katalyst::Tables::Collection::Query

`Query` - Adds query parsing support for filtering collections based on a query parameter.

The `Query` module allows you to define attributes in your collection model that can be populated using a human-friendly query input. The module parses the query string and extracts attribute values.

## Usage

To use the `Query` module, include it in your collection class and define the attributes you want to filter on.

#### Collection Configuration

```ruby
class Collection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Query
  

  attribute :id, default: -> { [] }
  attribute :search, :search, scope: :table_search
  attribute :name, :string
  attribute :active, :boolean
  attribute :category, :enum
  attribute :"parent.name", :string
  attribute :"parent.id", :integer
end
```

## User inputs

The `Query` module supports basic string inputs, which it applies to a `search` attribute if defined.

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

Attributes with types can be completed using tagged inputs. For example:

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

Attributes that have a default array value can accept multiple input values:

```ruby
collection.with_params(query: "category:report")
# => { "category" => ["report"] }
collection.with_params(query: "category: [article, report]")
# => { "category" => ["article", "report"] }
collection.with_params(query: 'category:["article", "report"]')
# => { "category" => ["article", "report"] }
```

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

  attribute :id, default: -> { [] }
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
