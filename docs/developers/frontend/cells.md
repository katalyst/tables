---
layout: default
title: Cells
parent: Frontend
grand_parent: Developers
nav_order: 1
---

# Cells

If you do not provide a value when you call the cell builder, the attribute you provide will be retrieved from the 
current item and the result will be rendered in the table cell. This is often all you need to do, but if you do want 
to customize the value you can pass a block instead:

```erb
<% row.text :status do %>
  <%= person.password.present? ? "Active" : "Invited" %>
<% end %>
```

In the context of the block you have access to the cell component if you simply want to extend the default behavior:

```erb
<%# @type [Katalyst::Tables::CellComponent] cell %>
<% row.text :name do |cell| %>
  <%= link_to cell, person %>
<% end %>
```

You can also update `html_attributes` on the cell builder, similar to the row builder, see
[HTML attributes](html-attributes) for details.
