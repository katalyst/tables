---
layout: default
title: Filtering and search
parent: Frontend
grand_parent: Developers
nav_order: 6
---

# Filtering and search

[Collections](../collections) provide a model-like interface for connecting filter and search parameters to collections.
At its simplest, the pipeline for applying a filter to your frontend view looks like this:
1. Provide the user with inputs to specify filters to apply
2. Send the user's inputs to the server as params
3. Controller passes inputs to the Collection, which sanitizes and stores the filter inputs
4. Call `apply` on the Collection, passing the unfiltered scope
5. Re-render the table using the (now filtered) collection

## Basic search

The simplest version of search that doesn't take advantage of any of the more advanced features tables offer would 
use a standard Rails form and pass the collection as the model:

```erb
<%# app/views/people/index.html.erb %>
<%= form_with(model: collection, method: :get) do |form| %>
  <%= form.text_field :search, type: :search %>
  <%= form.submit "Filter" %>
<% end %>

<%= table_with(collection:) do |row| %>
  <% row.string :name %>
<% end %>
```

Passing the collection as the model allows the collection to take responsibility for applying strong params 
filtering and ensuring that the user's input is preserved when re-rendering the page.

```ruby
# app/controllers/people_controller.rb
def index
  collection = Collection.with_params(params).apply(Person)
  render locals: { collection: }
end

class Collection < Katalyst::Tables::Collection::Base
  attribute :search
  
  def filter
    self.items = items.where(Person.arel_table[:name].matches("%#{Person.sanitize_sql_like(search)}%")) if search.present?
  end
end
```

You can extend the Rails form-based approach as far as you like with custom fields and inputs, possibly in 
combination with [collections filtering](../collections/filtering) to automatically apply the filters.

## Structured text-based filtering and search using `table_query_with`

Adding [`Katalyst::Tables::Collection::Query`](../collections/query) in your collection enables automatic query 
parsing and suggestions based on the user's inputs. You can define attributes that you want to expose for filtering 
and then add an interactive query generation tool to users based on the configured attributes. For example:

```erb
<%# app/views/people/index.html.erb %>
<%= table_query_with(collection:) %>
<%= table_with(collection:) do |row| %>
  <% row.string :first_name %>
  <% row.date :created_at %>
<% end %>
```

```ruby
# app/controllers/people_controller.rb
# ...
class Collection < Katalyst::Tables::Collection::Base
  include Katalyst::Tables::Collection::Query
  
  attribute :first_name, :string
  attribute :created_at, :date
end
```

With this definition, your users will see a query input with a modal that can help users to write tagged query 
expressions such as `first_name:Aaron` or `created_at:2024-01-01...`.

These queries will be automatically parsed and applied to the collection, and the collection will automatically 
filter the given scope based on the user's inputs.

There's also a frontend utility, `table_query_with(collection:)` that will generate the form and show a modal that 
helps users to interact with the query interface.

See the [collection query documentation](../collections/query) for details on how to define attributes and suggestions.
