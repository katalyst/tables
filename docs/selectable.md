# Katalyst::Tables::Selectable

`Selectable` adds the ability to select multiple rows in a table and apply bulk
actions to the selected data rows.

## Usage

The extension is included by default and can enabled for a specific table
by adding a `select` column:

```erb
<%= table_with(collection:, generate_ids: true) do |row| %>
  <% row.select %>
  <% row.cell :name, label: "Resource partial" %>
  <% row.boolean :active, class: "active" %>
<% end %>
```

You will also need to create a form for holding and submitting the selected rows
data and providing actions to perform on the selected data rows:

The form itself does not have an `action`; instead, you must be specify actions and methods
manually for each action you want to perform by setting `formaction` and `formmethod` on
the action buttons you add the the form. For example:

```erb
<%= table_selection_with(collection:) do %>
  <%= tag.button "Download", formaction: resources_path(format: :csv), formmethod: :get %>
  <%= tag.button "Activate", formaction: activate_resources_path, formmethod: :put %>
<% end %>
```

To complete the example outlined above, you could implement the following:

### Routes
```ruby
# routes.rb
resources :resources do
  put :activate, path: "active", on: :collection
end
```

### Controller
```ruby
# resources_controller.rb
class ResourcesController < ApplicationController
  def index
    collection = Collection.with_params(params).apply(Resource.all)
    
    respond_to do |format|
      format.html { render locals: { collection: } }
      format.csv { render body: generate_csv_from_collection(collection:) }
    end
  end

  def activate
    collection = Collection.with_params(params).apply(Resource.all)

    collection.items.update_all(active: true) if collection.id.any?

    redirect_back fallback_location: resources_path, status: :see_other
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

    attribute :id, default: -> { [] }

    def filter
      self.items = items.where(id:) if id.any?
    end
  end
end
```
