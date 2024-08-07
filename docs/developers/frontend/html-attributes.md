---
layout: default
title: HTML Attributes
parent: Frontend
grand_parent: Developers
nav_order: 3
---

# HTML Attributes

You can add HTML attributes on table, row, and cell tags.

The table tag takes attributes passed to the `table_with` helper, similar to `form_with`:

```erb
<%= table_with(collection: @people, id: "people-table") %>
```

Cells support the same approach:

```erb
<%= row.text :name, class: "name" %>
```

Rows do not get called directly, so instead, you can assign to `html_attributes` on the row builder to customize row
tag generation.

```erb
<% row.html_attributes = { id: person.id } if row.body? %>
```

Note: because the row builder gets called to generate the header row, you may need to guard calls that access the
`person` directly as shown in the previous example. You could also check whether `person` is present.
