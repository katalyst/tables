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

And then execute:

    $ bundle install

Add the Gem's JavaScript and CSS to your build pipeline. This assumes that you're using `rails-dartsass` and 
`importmaps` to manage your assets.

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

## Rendering a table

Add `include Katalyst::Tables::Frontend` to your `ApplicationHelper` or similar.

This provides the `table_with` helper, which is similar to `form_with` and allows you to generate HTML table output 
from an ActiveRecord relation:

```erb
<%# app/views/people/index.html.erb %>
<%= table_with collection: @people do |row, person| %>
  <% row.text :name do |cell| %>
    <%= link_to cell.value, person %>
  <% end %>
  <% row.text :email %>
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

### Rendering with a partial

The `table_with` helper is designed to let you define your columns inline and generate a table inline in your 
template. This is the approach we recommend for most situations. However, if the table is complex or you need to 
reuse it, you can consider moving the definition of the row into a partial.

By not providing a block to the `table_with` call, the gem will look for a partial called `_person.html+row.erb` to 
render each row:

```erb
<%# locals: { row:, person: nil } %>
<% row.text :name do |cell| %>
  <%= link_to cell.value, [:edit, person] %>
<% end %>
<% row.text :email %>
```

You can customize the partial and/or the name of the resource in a similar style to view partials:

```erb
<%= table_with(collection: @employees, as: :person, partial: "person") %>
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
    collection = Collection.with_params(params).apply(People)
    
    render locals: { collection: }
  end
  
  class Collection < Katalyst::Tables::Collection::Base
    config.sorting = "name asc" # requires that People has a `name` column
    config.pagination = true
  end
end
```

Collections can be passed directly to the `table_with` method and it will automatically detect features such as 
sorting and generate the appropriate table header links.

```erb
<%# locals: { collection: } %>
<%# app/views/people/index.html.erb %>
<%= table_with(collection:) do |row, person| %>
  <% row.string :name do |cell| %>
    <%= link_to cell.value, person %>
  <% end %>
<% end %>
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
