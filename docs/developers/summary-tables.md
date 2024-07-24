---
layout: default
title: Summary tables
parent: Developers
nav_order: 6
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
