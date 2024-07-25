---
layout: default
title: Sorting
parent: Frontend
grand_parent: Developers
nav_order: 4
---

# Sorting

Collections with column sorting applied will automatically wrap the contents of the header cell with a link.
This link contains the sorting configuration for the column. When clicked, the table will be re-rendered
with the contents of the table sorted by that column. The direction of the sort is toggled between `asc` and `desc`.

The link will also contain a `data-turbo-action` attribute with the value `replace`.
This will cause the table to be re-rendered using Turbo's `replace` action, utilizing Morph to only update the table 
body where needed.

```html
<table>
  <thead>
  <th data-sort="asc"><a data-turbo-action="replace" href="/people?sort=name+desc">Name</a></th>
  </thead>
  <tbody>
    <tr><td>John Doe</td></tr>
  </tbody>
</table>
```

## Usage

No configuration is required in the frontend, but sorting must be enabled and applied by the collection.
See [collection sorting](../collections/sorting) for details.
