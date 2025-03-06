---
layout: default
title: Getting started
parent: Developers
nav_order: 1
---

# Getting started

Add this line to your application's Gemfile:

```ruby
gem "katalyst-tables" 
```

And then:

```shell
bundle install
```

## Rendering a table

Add `helper Katalyst::Tables::Frontend` to your `ApplicationHelper` or similar.

This provides the `table_with` helper, which is similar to `form_with` and allows you to generate HTML table output 
from an ActiveRecord relation:

```erb
<%# app/views/people/index.html.erb %>
<%= table_with collection: @people do |row, person| %>
  <% row.text :name do |cell| %>
    <%= link_to cell, person %>
  <% end %>
  <% row.text :email %>
  <% row.date :created_at %>
<% end %>
```

The table will call your block once per row and accumulate the cells you generate into rows, including a header row:

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

## Collections

Tables can work directly with ActiveRecord relations, but in general we recommend using the `Collections` API instead.

`Katalyst::Tables::Collection::*` are useful entry points for creating controller-specific models for customizing 
the way your tabular data is displayed based on params. You can think of it as an example of the [Form Object 
pattern](https://thoughtbot.com/blog/activemodel-form-objects). For example:

```ruby
# app/controllers/people_controller.rb
class PeopleController < ApplicationController
  def index
    collection = Collection.with_params(params).apply(Person)
    
    render locals: { collection: }
  end
  
  class Collection < Katalyst::Tables::Collection::Base
    config.sorting = "name asc"
  end
end
```

Collections can be passed directly to the `table_with` method and it will automatically detect features such as 
sorting and generate the appropriate table header links.

```erb
<%# locals: { collection: } %>
<%# app/views/people/index.html.erb %>
<%= table_with collection: do |row, person| %>
  <% row.text :name do |cell| %>
    <%= link_to cell, person %>
  <% end %>
  <% row.text :email %>
  <% row.date :created_at %>
<% end %>
```

Now that you've specified sorting in your collection, you should be able to click links in your table
headers to toggle sorting on that column.

See [sorting](frontend/sorting) for more details.

## Optional dependencies

ERB rendering and ActiveRecord query functionality works out of the box, but tables also provides additional features
such as pagination, row selection and bulk actions, and a query builder that require additional dependencies.

### Pagination

Add the `pagy` gem to your `Gemfile` and run bundle.

```ruby
# Gemfile
gem "pagy"
```

Alter your collection definition:

```ruby
class Collection < Katalyst::Tables::Collection::Base
  config.paginate = { limit: 5 } # use true for pagy defaults, or use a hash to pass options to pagy
  config.sorting = "name asc"
end
```

Alter your frontend view to include a pagination component:

```erb
<%= table_with collection: do |row, person| %>
  <% row.text :name do |cell| %>
    <%= link_to cell, person %>
  <% end %>
  <% row.text :email %>
  <% row.date :created_at %>
<% end %>

<%= table_pagination_with(collection:) %>
```

You'll see that your frontend now includes a pagination navigation component under the table, and that
when you change sorting, the pagination is reset to 1.

See [pagination](frontend/pagination) for more details.

## Styling

This gem comes with basic styles for intended as a starting point, and not a
complete solution. You can import the basic styles as css:

```css
@import "/katalyst/tables.css";
```

Or, if you're using `dartsass-rails`, add tables to your stylesheet, e.g.

```scss
// app/assets/stylesheets/application.scss
@use "katalyst/tables";
```

## Javascript

Katalyst Tables includes stimulus components for implementing some advanced features such as
[bulk actions](frontend/bulk-actions), [drag and drop reordering](frontend/re-order.md), and
[query modal filtering](frontend/filtering).

Katalyst uses [`importmap-rails`](https://github.com/rails/importmap-rails),
[`turbo-rails`](https://github.com/hotwired/turbo-rails),
and [`stimulus-rails`](https://github.com/hotwired/stimulus-rails) for managing Javascript dependencies.
We also enable [Turbo Morphing](https://turbo.hotwired.dev/handbook/page_refreshes) for pages that use
[query modal filtering](frontend/filtering).

After configuring Turbo and Stimulus using their provided documentation, you will need to load
`@katalyst/tables` into your Stimulus application. For example:

```javascript
// app/javascript/controllers/index.js
import { application } from "controllers/application";

// Add katalyst-tables stimulus controllers
import tables from "@katalyst/tables";
application.load(tables);
```

## Entry points

This gem provides entry points for backend and frontend concerns:
* `Katalyst::TableComponent` can be used to render encapsulated tables,
* `Katalyst::SummaryTableComponent` can be used to render a record using the table syntax,
* `Katalyst::Tables::Frontend` provides `table_with` etc. for inline table generation,
* `Katalyst::Tables::Collection::Base` provides a default entry point for building collections in your controller
  actions,
* `Katalyst::Tables::Collection::Query` provides built-in query parsing and filtering based on the attributes 
  defined in your collection.
