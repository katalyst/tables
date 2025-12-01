---
layout: default
title: Bulk actions
parent: Frontend
grand_parent: Developers
nav_order: 7
---

# Bulk actions

`Katalyst::Tables::Selectable` adds the ability to select multiple rows in a table and apply bulk actions to the
selected data rows.

## Usage

The extension is included by default and can be enabled for a specific table by adding a `select` column:

```erb
<%= table_with(collection:, generate_ids: true) do |row| %>
  <% row.select %>
  <% row.text :name %>
  <% row.boolean :active %>
<% end %>
```

You will also need to create a form for holding and submitting the selected rows data and providing actions to 
perform on the selected data rows:

The form itself does not have an `action`; instead, you must specify actions and methods manually for each action 
you want to perform by setting `formaction` and `formmethod` on the action buttons you add to the form. For example:

```erb
<%= table_selection_with(collection:) do %>
  <%= tag.button "Download", formaction: blogs_path(format: :csv), formmethod: :get %>
  <%= tag.button "Activate", formaction: activate_blogs_path, formmethod: :put %>
<% end %>

<%= table_with(collection:) do %>
...
```

To complete the example outlined above, you could implement the following:

### Routes
```ruby
# routes.rb
resources :blogs do
  put :activate, path: "active", on: :collection
end
```

### Controller
```ruby
# blogs_controller.rb
class BlogsController < ApplicationController
  def index
    collection = Collection.with_params(params).apply(Blog.all)
    
    respond_to do |format|
      format.html { render locals: { collection: } }
      format.csv { render body: generate_csv_from_collection(collection:) }
    end
  end

  def activate
    Blog.where(id: params[:id]).each { |blog| blog.update(active: true) }
    
    redirect_back_or_to(blogs_path, status: :see_other)
  end
  
  private

  def generate_csv_from_collection(collection:)
    CSV.generate do |csv|
      csv << %w[id name]
      collection.items.pluck(:id, :name).each { |item| csv << item }
    end
  end

  class Collection < Katalyst::Tables::Collection::Base
    config.sorting = :name

    attribute :id, :integer, multiple: true

    def filter
      self.items = items.where(id:) if id.any?
    end
  end
end
```
