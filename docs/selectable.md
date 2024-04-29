# Selectable extension

The Selectable extension adds the ability to select multiple rows in the table
and apply bulk actions to the selected entries.

The extension can be enabled on a specific table instance of mixed in to a
table component class. In either case, the extension will add new functionality
to the table component and any nested row components, plus a component to show
the selection status and keep track of selected items between re-renders that
needs to be rendered in the page separately.

## Usage

You can add the selectable extension to an existing table instance by calling
extend on the table instance:

```ruby
table = Katalyst::TableComponent.new(collection:)
table.extend(Katalyst::Table::Selectable)
```

You can also include the extension in a table component class:

```ruby

class SelectableTableComponent < Katalyst::TableComponent
  include Katalyst::Table::Selectable
```

In both cases, you will need to configure the selection form that is generated
for submitting changes to the items. This can be done by calling

```ruby
table.with_selection
```
`with_selection` accepts the following attributes:
* `primary_key` - the primary key field to store for the selection, defaults to
  `:id`
  
In your row view template, you will need to call `row.selection` to generate the
selection column. This renders a checkbox to select/deselect the individual row 
in the table. Selection is persisted on sort if sorting is enabled.

## Form component

The metadata for the selection is stored separately in the selectable form 
component which must be rendered separately in the view. This generates a form
which contains the hidden inputs for the selected rows. As the actions will
likely be attached to different endpoints, the form itself does not have an
`action`; instead, this must be specified manually for each action you want to
perform via the `formaction` and `formmethod` attributes. We can use this to
generate actions such as CSV download and archiving/activation:
```erb
<%= render table.selection do |form| %>
  <%= tag.button "Download", formaction: resources_path(format: :csv), formmethod: "GET" %>
  <%= tag.button "Activate", formatction: "/resources/activate", formmethod: "PUT" %>
<% end %>
```

## Example

A full example of the set up for csv downloads and activation might look like the following.

### Routes
```ruby
# routes.rb
resources :resources do
  put :activate, on: :collection
end
```

### Controller
```ruby
# resources_controller.rb
class ResourcesController < ApplicationController
  def index
    collection = Collection.with_params(params).apply(Resource.all)
    table      = Katalyst::TableComponent.new(collection: collection)
    table.extend(Katalyst::Tables::Selectable)
    table.with_selection

    respond_to do |format|
      format.html { render locals: { table: table } }
      format.csv { render body: generate_csv_from_collection(collection) }
    end
  end
  
  def activate
    collection = Collection.with_params(params).apply(Resource.all)
    collection.items.update_all(active: true)
    redirect_back fallback_location: resources_path, status: :see_other
  end
  
  private
  
  def generate_csv_from_collection(collection)
    # ...
  end

  class Collection < Katalyst::Tables::Collection::Base
    config.sorting = :name

    attribute :id, default: -> { [] }

    def filter
      self.items = items.where(id: id) if id.any?
    end
  end
end
```

### Views
In the index, render the table selection form and the table separately:
```erb
<%= table.selection do |form| %>
  <%= tag.button "Download", formaction: resources_path(format: :csv), formmethod: "GET" %>
  <%= tag.button "Activate", formaction: activate_resources_path, formmethod: "PUT" %>
<% end %>

<%= render table %>
```

In the row partial, set the row selection:
```erb
<% row.selection %>

<% row.cell :name, label: "Resource partial" %>
<% row.cell :active do |cell| %>
  <%= cell.value ? "Yes" : "No" %>
<% end %>
```
