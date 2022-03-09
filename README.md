# Katalyst::Tables

Tools for building HTML tables from ActiveRecord collections.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "katalyst-tables", git: "https://github.com/katalyst/katalyst-tables", branch: "main" 
```

And then execute:

    $ bundle install

**Reminder:** If you have a rails server running, remember to restart the server to prevent the `uninitialized constant` error.

## Usage

This gem provides two entry points: Frontend for use in your views, and Backend for use in your controllers. The backend
entry point is optional, as it's only required if you want to support sorting by column headers.

### Frontend

Add `include Katalyst::Tables::Frontend` to your `ApplicationHelper` or similar.

```erb
<%= table_with collection: @people do |row, person| %>
  <%= row.cell :name %>
  <%= row.cell :email %>
  <%= row.cell :actions do %>
   <%= link_to "Edit", person %>
  <% end %>
<% end %>
```

`table_builder` will call your block once per row and accumulate the cells you generate into rows:

```html

<table>
    <thead>
    <tr>
        <th>Name</th>
        <th>Email</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <td>Alice</td>
        <td>alice@acme.org</td>
        <td><a href="/people/1/edit">Edit</a></td>
    </tr>
    <tr>
        <td>Bob</td>
        <td>bob@acme.org</td>
        <td><a href="/people/2/edit">Edit</a></td>
    </tr>
    </tbody>
</table>
```

### Options

You can customise the options passed to the table, rows, and cells.

Tables support options via the call to `table_with`, similar to `form_with`.

```erb
<%= table_with collection: @people, id: "people-table" do |row, person| %>
  ...
<% end %>
```

Cells support the same approach:

```erb
<%= row.cell :name, class: "name" %>
```

Rows do not get called directly, so instead you can call `options` on the row builder to customize the row tag
generation.

```erb
<%= table_with collection: @people, id: "people-table" do |row, person| %>
  <% row.options data: { id: person.id } if row.body? %>
  ...
<% end %>
```

Note: because the row builder gets called to generate the header row, you may need to guard calls that access the
`person` directly as shown in the previous example. You could also check whether `person` is present.

#### Headers

`table_builder` will automatically generate a header row for you by calling your block with no object. During this
iteration, `row.header?` is true, `row.body?` is false, and the object (`person`) is nil.

All cells generated in the table header iteration will automatically be header cells, but you can also make header cells
in your body rows by passing `heading: true` when you generate the cell.

```erb
<%= row.cell :id, heading: true %>
```

The table header cells default to showing the titleized column name, but you can customize this in one of two ways:

* Set the value inline
    ```erb
    <%= row.cell :id, label: "ID" %>
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
<%= row.cell :status do %>
 <%= person.password.present? ? "Active" : "Invited" %>
<% end %>
```

In the context of the block you have access the cell builder if you simply
want to extend the default behaviour:

```erb
<%= row.cell :status do |cell| %>
 <%= link_to cell.value, person %>
<% end %>
```

You can also call `options` on the cell builder, similar to the row builder, but
please note that this will replace any options passed to the cell as arguments.

### Sort

The major reason why you should use this gem, apart the convenience of the
builder, is for adding efficient and simple column sorting to your tables.

Start by including the backend in your controller(s):

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
  <%= row.cell :actions do %>
   <%= link_to "Edit", person %>
  <% end %>
<% end %>
```

That's it! Any column that corresponds to an ActiveRecord attribute will now be
automatically sortable in the frontend.

You can also add sorting to non-attribute columns by defining a scope in your
model:

```
scope :order_by_status, ->(direction) { ... }
```

Finally, you can use sort with a collection that is already ordered, but please
note that the backend will call `reorder` if the user provides a sort option. If
you want to provide a tie-breaker default ordering, the best way to do so is after
calling `table_sort`.

You may also want to whitelist the `sort` param if you encounter strong param warnings.

### Pagination

This gem designed to work with [pagy](https://github.com/ddnexus/pagy/).

```ruby

def index
  @people = People.all

  @sort, @people = table_sort(@people) # sort
  @pagy, @people = pagy(@people) # then paginate
end
```

```erb
<%= table_with collection: @people, sort: @sort do |row, person| %>
  <%= row.cell :name %>
  <%= row.cell :email %>
  <%= row.cell :actions do %>
   <%= link_to "Edit", person %>
  <% end %>
<% end %>
<%== pagy_nav(@pagy) %>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katalyst/katalyst-tables.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
