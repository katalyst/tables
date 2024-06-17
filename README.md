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

```scss
// app/assets/stylesheets/application.scss
@use "@katalyst/tables";
```

## Usage

This gem provides entry points for backend and frontend concerns:
* `Katalyst::TableComponent` can be used render encapsulated tables,
* `Katalyst::SummaryTableComponent` can be used render a record using the table syntax,
* `Katalyst::Tables::Frontend` provides `table_with` for inline table generation,
* `Katalyst::Tables::Collection::Base` provides a default entry point for
  building collections in your controller actions

### Frontend

Add `include Katalyst::Tables::Frontend` to your `ApplicationHelper` or similar.

You can use the `table_with` helper to generate a table inline in your view without explicitly interacting with the
table component. This is the preferred approach when creating tables. However, if the table is complex or you need to 
reuse it, you should consider moving the definition of the row into a partial.

```erb
<%= table_with collection: @people do |row, person| %>
  <% row.text :name do |cell| %>
    <%= link_to cell.value, [:edit, person] %>
  <% end %>
  <% row.text :email %>
<% end %>
```

By not providing a block to the `table_with` call, the gem will look for a partial called `_person.html+row.erb` to
render each row:

```erb
<%# locals: { row:, person: nil } %>
<% row.text :name do |cell| %>
  <%= link_to cell.value, [:edit, person] %>
<% end %>
<% row.text :email %>
```

The table will call your block / partial once per row and accumulate the cells
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
<%= table_with(collection: @employees, as: :person, partial: "person") %>
```

### HTML Attributes

You can add custom attributes on table, row, and cell tags.

The table tag takes attributes passed to `table_with` helper, similar to `form_with`:

```erb
<%= table_with(collection: @people, id: "people-table")
```

Cells support the same approach:

```erb
<%= row.text :name, class: "name" %>
```

Rows do not get called directly, so instead you can assign to `html_attributes` on the row builder to customize row tag
generation.

```erb
<% row.update_html_attributes(id: person.id) if row.body? %>
```

Note: because the row builder gets called to generate the header row, you may need to guard calls that access the
`person` directly as shown in the previous example. You could also check whether `person` is present.

### Headers

Tables will automatically generate a header row for you by calling your row partial or provided block with no object.
During this call, `row.header?` is true, `row.body?` is false, and the object (`person`) is nil.

All cells generated in the table header iteration will automatically be header cells, but you can also make header cells
in your body rows by passing `heading: true` when you generate the cell.

```erb
<% row.number :id, heading: true %>
```

The table header cells default to showing the capitalized column name, but you can customize this in one of two ways:

* Set the value inline
    ```erb
    <% row.number :id, label: "ID" %>
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
<% row.text :status do %>
  <%= person.password.present? ? "Active" : "Invited" %>
<% end %>
```

In the context of the block you have access the cell component if you simply
want to extend the default behaviour:

```erb
<%# @type [Katalyst::Tables::CellComponent] cell %>
<% row.text :name do |cell| %>
  <%= link_to cell, person %>
<% end %>
```

You can also update `html_attributes` on the cell builder, similar to the row
builder, see `katalyst-html-attributes` for details.

## Collections

The `Katalyst::Tables::Collection::Base` class provides a convenient way to
manage collections in your controller actions. It is designed to be used with
Pagy for pagination and provides built-in sorting when used with ActiveRecord
collections. Sorting and Pagination are off by default, you can either set them
on creation or create a custom `Collection` class that sets them on by default:

```ruby
# in #index
Katalyst::Tables::Collection::Base.new(sorting: "name asc", pagination: true)
# or as a nested class in your controller
class Collection < Katalyst::Tables::Collection::Base
  config.sorting = "name asc" # requires models have a name attribute
  config.pagination = true
end
```

Collections can be passed directly to `table_with` method and it will automatically
detect features such as sorting and generate the appropriate table header links.

```erb
<%= table_with(collection:) %>
```

## Summary tables
You can use the `Katalyst::SummaryTableComponent` to render a single record utilizing all the functionality from the 
`Katalyst::TableComponent`. 

```erb
<%= summary_table_with model: @person do |row| %>
  <% row.text :name %>
  <% row.text :email %>
<% end %>
```

## Extensions

The following extensions are available and activated by default:

* [Filtering](docs/filtering.md) - adds automatic collection filtering based on attributes 
* [Query](docs/query.md) - adds human-friendly text filtering that populates collection attributes 
* [Identifiable](docs/identifiable.md) - adds default dom ids to the table and data rows.
* [Orderable](docs/orderable.md) - adds bulk-update for 'ordinal' columns via dragging rows in the table.
* [Pagination](docs/pagination.md) - handles paginating of data in the collection.
* [Selectable](docs/selectable.md) - adds bulk-action support for rows in the table.
* [Sortable](docs/sortable.md) - table column headers that can be sorted will be wrapped in links.
* [Customization](docs/customization.md) - customize the table and cell rendering.

You can disable extensions by altering the `Katalyst::Tables.config.component_extensions` before initialization.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katalyst/katalyst-tables.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
