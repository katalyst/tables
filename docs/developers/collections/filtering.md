---
layout: default
title: Filtering
parent: Collections
grand_parent: Developers
nav_order: 3
---

# Filtering

The `Filtering` module allows you to apply filters to your collections based on the attributes you define and the 
values they have been given, e.g., from a `with_params` call.

This feature is designed for use with the `Query` module, allowing you to define and apply filters to attributes in
your collection model, but can be used independently as well if you prefer to create a custom form.

## Usage

To use the `Filtering` module, include it in your collection class and define the attributes you want to filter. The
module applies filters based on the value of each given attribute to the collection.

```ruby
class Collection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Filtering
  
  attribute :id, :integer, multiple: true
  attribute :search, :search, scope: :table_search
  attribute :name, :string
  attribute :active, :boolean
  attribute :updated, :boolean, scope: :updated
  attribute :category, :enum
  attribute :"parent.name", :string
  attribute :"parent.active", :boolean
  attribute :"parent.updated", :boolean
  attribute :"parent.id", :integer, multiple: true
  attribute :"parent.role", :enum
end
```

To apply filters, use the `with_params` method to pass the query parameters, and then call the `apply` method with 
the initial scope (e.g., `Resource.all`).

```ruby
collection.with_params(params).apply(Resource)
```

### Boolean search

```ruby
scope = collection.with_params(active: true).apply(Resource)
# => Resource.where(active: true)
```

You can implement derived booleans which do not exist in the model too. When filtering on a derived attribute,
`Filtering` will look for a scope specified on the attribute and pass the value of the boolean attribute:

```ruby
# model scope
scope :updated, ->(updated) { updated ? where("created_at != updated_at") : where("created_at = updated_at") }

# collection attribute
attribute :updated, :boolean, scope: :updated

# controller usage
collection.with_params(updated: true).apply(Resource).items
# => Resource.where("created_at != updated_at")
```

### Multi-value search

Attributes that have a default array value can accept multiple input values:

 ```ruby
 scope = collection.with_params(category: "report").apply(Resource)
 # => Resource.where(category: :report)
 
scope = collection.with_params(category: ["article", "report"]).apply(Resource)
 # => Resource.where(category: %w[article report])
 ```

### String search

String attributes use `like` matching:

```ruby
scope = collection.with_params(name: "Aaron").apply(Nested::Child)
# => Nested::Child.where("name LIKE ?", "%Aaron%")
```

String filtering with associations:

 ```ruby
 scope = collection.with_params("parent.name": "test").apply(Nested::Child)
 # => Nested::Child.joins(:parent).where("parents.name LIKE ?", "%test%")
 ```

### Associations

 ```ruby
scope = collection.with_params("parent.role": "teacher").apply(Nested::Child)
# => Nested::Child.joins(:parent).merge(Parent.where(role: :teacher))

scope = collection.with_params("parent.active": true).apply(Nested::Child)
# => Nested::Child.joins(:parent).merge(Parent.where(active: true))

scope = collection.with_params("parent.id": "15").apply(Nested::Child)
# => Nested::Child.joins(:parent).where("parents.id = ?", 15)

scope = collection.with_params("parent.id": [1, 2, 3]).apply(Nested::Child)
# => Nested::Child.joins(:parent).where("parents.id IN ?", [1, 2, 3])

scope = collection.with_params("parent.name": "test").apply(Nested::Child)
# => Nested::Child.joins(:parent).where("parents.name LIKE ?", "%test%")
```
