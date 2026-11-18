---
layout: default
title: Bulk actions
parent: Frontend
grand_parent: Developers
nav_order: 7
---

# Bulk actions

`Katalyst::Tables::Selectable` adds the ability to select multiple rows in a table and apply bulk actions to the
selected data rows.

## Usage

The extension is included by default and can be enabled for a specific table by adding a `select` column:

```erb
<%= table_with(collection:, generate_ids: true) do |row| %>
  <% row.select %>
  <% row.text :name %>
  <% row.boolean :active %>
<% end %>
```

You will also need to create a form for holding and submitting the selected rows data and providing actions to 
perform on the selected data rows:

The form itself does not have an `action`; instead, you must specify actions and methods manually for each action 
you want to perform by setting `formaction` and `formmethod` on the action buttons you add to the form. For example:

```erb
<%= table_selection_with(collection:) do %>
  <%= tag.button "Download", formaction: blogs_path(format: :csv), formmethod: :get %>
  <%= tag.button "Activate", formaction: activate_blogs_path, formmethod: :put %>
<% end %>

<%= table_with(collection:) do %>
...
```

### Describing the selection

The form shows a summary of the selection, e.g. "2 blogs selected". To describe the selection elsewhere in the form,
such as in an action button, the form component is passed to the block and provides a `selection_tag` helper. It
renders the number of selected rows and the model name, and updates as the selection changes:

```erb
<%= table_selection_with(collection:) do |selection| %>
  <%# renders "Download 1 blog", "Download 2 blogs", etc %>
  <%= tag.button t(".download_html", selection: selection.selection_tag),
                 formaction: blogs_path(format: :csv), formmethod: :get %>
<% end %>
```

```yaml
en:
  blogs:
    index:
      download_html: "Download %{selection}"
```

`selection_tag` renders HTML, so the translation key must end in `_html`. Rails escapes the markup when it is
interpolated into any other translation. Other arguments to an `_html` translation are escaped as usual.

`selection_tag` renders a `span` and accepts HTML attributes (`id`, `aria`, `class`, `data`, and `html` for any other
attribute).

#### Customising the summary

The summary is translated with `katalyst.tables.selectable.form_component.summary_html`, so you can change it in your
application's locale files:

```yaml
en:
  katalyst:
    tables:
      selectable:
        form_component:
          summary_html: "%{selection} chosen"
```

#### Selection parts

If you need more control, e.g. to show the count without the model name, you can use the parts that
`selection_tag` renders:

* **`count_tag`** renders the number of selected rows
* **`singular_tag`** renders the singular model name, shown when exactly one row is selected
* **`plural_tag`** renders the plural model name, shown when any other number of rows is selected

```erb
<%= tag.button formaction: activate_blogs_path, formmethod: :put do %>
  Activate <%= selection.count_tag(class: "badge") %>
<% end %>
```

Each part renders a `span` and accepts HTML attributes, which are merged with the attributes the part needs.

Model names switch between the `one` and `other` forms of `model_name.human`, as the count changes in the browser.

To complete the example outlined above, you could implement the following:

### Routes
```ruby
# routes.rb
resources :blogs do
  put :activate, path: "active", on: :collection
end
```

### Controller
```ruby
# blogs_controller.rb
class BlogsController < ApplicationController
  def index
    collection = Collection.with_params(params).apply(Blog.all)
    
    respond_to do |format|
      format.html { render locals: { collection: } }
      format.csv { render body: generate_csv_from_collection(collection:) }
    end
  end

  def activate
    Blog.where(id: params[:id]).each { |blog| blog.update(active: true) }
    
    redirect_back_or_to(blogs_path, status: :see_other)
  end
  
  private

  def generate_csv_from_collection(collection:)
    CSV.generate do |csv|
      csv << %w[id name]
      collection.items.pluck(:id, :name).each { |item| csv << item }
    end
  end

  class Collection < Katalyst::Tables::Collection::Base
    config.sorting = :name

    attribute :id, :integer, multiple: true

    def filter
      self.items = items.where(id:) if id.any?
    end
  end
end
```
