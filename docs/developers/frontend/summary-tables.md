---
layout: default
title: Summary tables
parent: Frontend
grand_parent: Developers
nav_order: 9
---

# Summary tables

You can use the `Katalyst::SummaryTableComponent` to render a single record utilizing all the functionality from the
`Katalyst::TableComponent`.

```erb
<%= summary_table_with model: @person do |row| %>
  <% row.text :name %>
  <% row.text :email %>
<% end %>
```

Instead of rendering rows for each record and columns for each attribute, this will render a table with labels and
values as two columns, with a row for each attribute. This component extends `TableComponent` and customizes the
rendering, but has access to all the same cell types as `TableComponent`
