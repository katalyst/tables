---
layout: default
title: Partials
parent: Advanced
grand_parent: Developers
nav_order: 1
---

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
