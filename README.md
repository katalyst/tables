# Katalyst::Tables

Tools for building HTML tables from ActiveRecord collections.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "katalyst-tables" 
```

And then execute:

    $ bundle install

Add the Gem's javascript and CSS to your build pipeline. This assumes that
you're using `rails-dartsass` and `importmaps` to manage your assets.

```javascript
// app/javascript/controllers/application.js
import { application } from "controllers/application";
import tables from "@katalyst/tables";
application.load(tables);
```

## Usage

This gem provides entry points for backend and frontend concerns:
* `Katalyst::TableComponent` can be used render encapsulated tables, it calls a
  partial for each row.
* `Katalyst::Tables::Frontend` provides `table_with` for inline table generation
* `Katalyst::Tables::Collection::Base` provides a default entry point for
  building collections in your controller actions.

## Frontend

Use `Katalyst::TableComponent` to build a table component from an ActiveRecord
collection, or from a `Katalyst::Tables::Collection::Base` instance.

For example, if you render `Katalyst::TableComponent.new(collection: @people)`,
the table component will look for a partial called `_person.html+row.erb` and
render it for each row (and once for the header row).

```erb
<%# locals: { row:, person: nil } %>
<% row.cell :name do |cell| %>
  <%= link_to cell.value, [:edit, person] %>
<% end %>
<% row.cell :email %>
```

The table component will call your partial once per row and accumulate the cells
you generate into rows, including a header row:

```html

<table>
  <thead>
  <tr>
    <th>Name</th>
    <th>Email</th>
  </tr>
  </thead>
  <tbody>
  <tr>
    <td><a href="/people/1/edit">Alice</a></td>
    <td>alice@acme.org</td>
  </tr>
  <tr>
    <td><a href="/people/2/edit">Bob</a></td>
    <td>bob@acme.org</td>
  </tr>
  </tbody>
</table>
```

You can customize the partial and/or the name of the resource in a similar style
to view partials:

```erb
<%= render Katalyst::TableComponent.new(collection: @employees, as: :person, partial: "person") %>
``` 

### Inline tables

You can use the `table_with` helper to generate a table inline in your view without explicitly interacting with the
table component. This is primarily intended for backwards compatibility, but it can be useful for simple tables.

Add `include Katalyst::Tables::Frontend` to your `ApplicationHelper` or similar.

```erb
<%= table_with collection: @people do |row, person| %>
  <% row.cell :name do |cell| %>
    <%= link_to cell.value, [:edit, person] %>
  <% end %>
  <% row.cell :email %>
<% end %>
```

### HTML Attributes

You can add custom attributes on table, row, and cell tags.

The table tag takes attributes passed to `TableComponent` or via the call to `table_with`, similar to `form_with`:

```erb
<%= TableComponent.new(collection: @people, id: "people-table")
```

Cells support the same approach:

```erb
<%= row.cell :name, class: "name" %>
```

Rows do not get called directly, so instead you can assign to `html_attributes` on the row builder to customize row tag
generation.

```erb
<% row.html_attributes = { id: person.id } if row.body? %>
```

Note: because the row builder gets called to generate the header row, you may need to guard calls that access the
`person` directly as shown in the previous example. You could also check whether `person` is present.

#### Headers

Tables will automatically generate a header row for you by calling your row partial or provided block with no object.
During this call, `row.header?` is true, `row.body?` is false, and the object (`person`) is nil.

All cells generated in the table header iteration will automatically be header cells, but you can also make header cells
in your body rows by passing `heading: true` when you generate the cell.

```erb
<% row.cell :id, heading: true %>
```

The table header cells default to showing the capitalized column name, but you can customize this in one of two ways:

* Set the value inline
    ```erb
    <% row.cell :id, label: "ID" %>
    ```
* Define a translation for the attribute
    ```yml
    # en.yml
    activerecord:
      attributes:
        person:
          id: "ID"
    ```
  
Note: if the cell is given a block, it is not called during the header pass. This
is because the block is assumed to be for generating data for the body, not the
header. We suggest you set `label` instead.

#### Cell values

If you do not provide a value when you call the cell builder, the attribute you
provide will be retrieved from the current item and the result will be rendered in
the table cell. This is often all you need to do, but if you do want to customise
the value you can pass a block instead:

```erb
<% row.cell :status do %>
  <%= person.password.present? ? "Active" : "Invited" %>
<% end %>
```

In the context of the block you have access the cell builder if you simply
want to extend the default behaviour:

```erb
<% row.cell :status do |cell| %>
  <%= link_to cell.value, person %>
<% end %>
```

You can also assign to `html_attributes` on the cell builder, similar to the row
builder, but please note that this will replace any options passed to the cell
as arguments.

## Collections

The `Katalyst::Tables::Collection::Base` class provides a convenient way to
manage collections in your controller actions. It is designed to be used with
Pagy for pagination and provides built-in sorting when used with ActiveRecord
collections. Sorting and Pagination are off by default, but you can create
a custom `ApplicationCollection` class that sets them on by default.

```ruby
class ApplicationCollection < Katalyst::Tables::Collection::Base
  config.sorting = "name" # requires models have a name attribute
  config.pagination = true
end
```

You can then use this class in your controller actions:

```ruby
class PeopleController < ApplicationController
  def index
    @people = ApplicationCollection.new.with_params(params).apply(People.all)
  end
end
```

Collections can be passed directly to `TableComponent` and it will automatically
detect features such as sorting and generate the appropriate table header links.

```erb
<%= render TableComponent.new(collection: @people) %>
```

## Sort

When sort is enabled, table columns will be automatically sortable in the
frontend for any column that corresponds to an attribute on the model. You can
also add sorting to non-attribute columns by defining a scope in your
model:

```
scope :order_by_status, ->(direction) { ... }
```

You can also use sort without using collections, this was the primary backend
interface for V1 and takes design cues from Pagy. Start by including the backend
in your controller(s):

```ruby
include Katalyst::Tables::Backend
```

Now, in your controller index actions, you can sort your active record
collections based on the `sort` param which is appended to the current URL as a
get parameter when a user clicks on a column header.

Building on our example from earlier:

```ruby
class PeopleController < ApplicationController
  include Katalyst::Tables::Backend
  
  def index
    @people = People.all

    @sort, @people = table_sort(@people) # sort
  end
end
```

You then add the sort form object to your view so that it can add column header
links and show the current sort state:

```erb
<%= table_with collection: @people, sort: @sort do |row, person| %>
  <%= row.cell :name %>
  <%= row.cell :email %>
<% end %>
```

## Pagination

This gem designed to work with [pagy](https://github.com/ddnexus/pagy/).

If you use collections and enable pagination then pagy will be called internally
and the pagy metadata will be available as `pagination` on the collection.

`Katalyst::Tables::PagyNavComponent` can be used to render the pagination links
for a collection.

```erb
<%= render Katalyst::Tables::PagyNavComponent.new(collection: @people) %>
```

## Turbo streams

This gem provides turbo stream entry points for table and pagy_nav. These are
identical in the options they support, but they require ids, and they will
automatically render turbo stream replace tags when rendered as part of a turbo
stream response.

To take full advantage of this feature, we suggest you build the component in
your controller and pass it to the view. This allows you to use the same
controller for both HTML and turbo responses.

```ruby
def index
  collection = ApplicationCollection.new.with_params(params).apply(People.all)
  table = Katalyst::Turbo::TableComponent.new(collection:, id: "people")
  
  respond_to do |format|
    format.turbo_stream { render table } if self_referred?
    format.html { render locals: { table: table } }
  end
end
```

## Extensions

The following extensions are available:

* [Orderable](docs/orderable.md) - adds bulk-update for 'ordinal' columns via dragging rows in the table.

## Customization

A common pattern we use is to have a cell at the end of the table for actions. For example:

```html
<table class="action-table">
  <thead>
    <tr>
      <th>Name</th>
      <th class="actions"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Alice</td>
      <td class="actions">
        <a href="/people/1/edit">Edit</a>
        <a href="/people/1" method="delete">Delete</a>
      </td>
    </tr>
  </tbody>
</table>
```

You can write a custom component that helps generate this type of table by
adding the required classes and adding helpers for generating the actions.
This allows for a declarative table syntax, something like this:

```erb
<%= render ActionTableComponent.new(collection:) do |row| %>
  <% row.cell :name %>
  <% row.actions do |cell| %>
    <%= cell.action "Edit", :edit %>
    <%= cell.action "Delete", :delete, method: :delete %>
  <% end %>
<% end %>
```

And the customized component:

```ruby
class ActionTableComponent < Katalyst::TableComponent

  config.header_row = "ActionHeaderRow"
  config.body_row   = "ActionBodyRow"
  config.body_cell  = "ActionBodyCell"
  
  def default_html_attributes
    { class: "action-table" }
  end

  class ActionHeaderRow < Katalyst::Tables::HeaderRowComponent
    def actions(&block)
      cell(:actions, class: "actions", label: "", &block)
    end
  end

  class ActionBodyRow < Katalyst::Tables::BodyRowComponent
    def actions(&block)
      cell(:actions, class: "actions", &block)
    end
  end

  class ActionBodyCell < Katalyst::Tables::BodyCellComponent
    def action(label, href, **attrs)
      content_tag(:a, label, href: href, **attrs)
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katalyst/katalyst-tables.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
