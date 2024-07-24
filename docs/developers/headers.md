---
layout: default
title: Headers
parent: Developers
nav_order: 3
---

# Headers

Tables will automatically generate a header row for you by calling your row partial or provided block with no object.
During this call, `row.header?` is true, `row.body?` is false, and the object (`person`) is nil.

All cells generated in the table header iteration will automatically be header cells, but you can also make header cells
in your body rows by passing `heading: true` when you generate the cell.

```erb
<% row.number :id, heading: true %>
```

The table header cells default to showing the capitalized column name, but you can customize this in one of two ways:

### Set the value inline

```erb
<% row.number :id, label: "ID" %>
```

### Define a translation for the attribute

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
