# Katalyst::Tables::Collection::Filtering

`Filtering` - Automatically filter the items of a collections based off the attributes configured.

The `Filtering` module allows you to apply filters to your collections based on the values of the attributes within the
collection.
This feature integrates seamlessly with the `Query` module, allowing you to define and apply filters to attributes in
your collection model.

### Usage

To use the `Filtering` module, include it in your collection class and define the attributes you want to filter.
The module applies filters based on the value of each given attribute to the collection.

#### Collection Configuration

```ruby

class Collection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Query
  include Katalyst::Tables::Collection::Filtering
  
  attribute :id, default: -> { [] }
  attribute :search, :search, scope: :table_search
  attribute :name, :string
  attribute :active, :boolean
  attribute :updated, :boolean, scope: :updated
  attribute :category, :enum
  attribute :"parent.name", :string
  attribute :"parent.active", :boolean
  attribute :"parent.updated", :boolean
  attribute :"parent.id", default: -> { [] }
  attribute :"parent.role", :enum
end
```

### Applying Filters

To apply filters, use the `with_params` method to pass the query parameters, and then call the `apply` method with the
initial scope (e.g., `Resource.all`).

### Filter Types

When passing an empty query string to the collection, no filters will be applied

```ruby
scope = collection.with_params(query: "").apply(Resource.all)
# => Resource.all
```

### Basic search

The `Filtering` module supports basic string search, which it applies to a `:search` attribute if defined.

```ruby
class Collection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Query
  
  attribute :custom_search, :search, scope: :custom_search
end

scope = collection.with_params(query: "test").apply(Resource.all)
# => Resource.custom_search("test")

collection.with_params(query: "active status")
# => Resource.custom_search('active status')

scope = collection.with_params(query: '"active status"').apply(Resource.all)
# => Resource.custom_search('"active status"')
```

### Boolean search

```ruby
scope = collection.with_params(query: "active:true").apply(Resource.all)
# => Resource.where(active: true)
```

Supports derived booleans. When filtering on a derived attribute, `Filtering` will call the scope with 
the name of the attribute, passing in the value. 

```ruby
scope = collection.with_params(query: "updated:true").apply(Resource.all)
# => Resource.where("created_at != updated_at")
```

### Multi-value search

Attributes that have a default array value can accept multiple input values:

 ```ruby
 scope = collection.with_params(query: "category:report").apply(Resource.all)
 # => Resource.where(category: :report)
 
scope = collection.with_params(query: "category: [article, report]").apply(Resource.all)
 # => Resource.where(category: %i[article report])
 ```

### String search
```ruby
scope = collection.with_params(query: "name:Aaron").apply(Nested::Child.all)
# => Nested::Child.where("name LIKE ?", "%Aaron%")
```

- **Complex Key Matching**: String filtering with associations.
 ```ruby
 scope = collection.with_params(query: "parent.name:test").apply(Nested::Child.all)
 # => Nested::Child.joins(:parent).where("parents.name LIKE ?", "%test%")
 ```

### Associations

 ```ruby
scope = collection.with_params(query: "parent.role:teacher").apply(Nested::Child.all)
# => Nested::Child.joins(:parent).merge(Parent.where(role: :teacher))

scope = collection.with_params(query: "parent.active:true").apply(Nested::Child.all)
# => Nested::Child.joins(:parent).merge(Parent.where(active: true))

scope = collection.with_params(query: "parent.id:15").apply(Nested::Child.all)
# => Nested::Child.joins(:parent).where("parents.id = ?", 15)

scope = collection.with_params(query: "parent.id:[1, 2, 3]").apply(Resource.all)
# => Resource.where(id: [1, 2, 3])

scope = collection.with_params(query: "parent.name:test").apply(Nested::Child.all)
# => Nested::Child.joins(:parent).where("parents.name LIKE ?", "%test%")
```

### Example

Here is an example of using the `Filtering` module with a collection:

```ruby

class MyCollection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Query
  include Katalyst::Tables::Collection::Filtering

  attribute :id, default: -> { [] }
  attribute :search, :search, scope: :table_search
  attribute :name, :string
  attribute :active, :boolean
  attribute :category, :enum
  attribute :"parent.name", :string
  attribute :"parent.id", :integer
end

collection = MyCollection.new
scope      = collection.with_params(query: "active:true category:[article,report] parent.id:15").apply(Resource.all)
# => Resource.joins(:parent).where(active: true, category: %i[article report], "parents.id" => 15)
```
