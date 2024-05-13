# Katalyst::Tables::Orderable

`Orderable` adds the ability to bulk-update an 'order' column for
model instances from an index table view. Users can drag and
drop rows within their table and the extension will automatically
patch the configured URL with the new ordering data.

## Usage

The extension is included by default and can enabled for a specific table
by adding an `ordinal` column:

```erb
<%= table_with(collection:) do |row| %>
  <% row.ordinal %>
  <% row.text :name %>
<% end %>
```

By default ordinal columns render a `⠿` icon to the cell. This can be configured
by setting I18n for `katalyst.table.orderable.value`.

You will also need to create a hidden form for holding and submitting changes
to the ordinal data when the user interacts with the table:

```erb
<%= table_orderable_with(collection:, url: order_models_path) %>
```

 * `url` is required, when a user interacts with the table elements, this URL
   will be patched with any changes to order data.

## Index tables

Orderable can be used to add drag-and-drop ordering to an index table. The
minimal example for a controller that supports saving ordinal index table data looks like this:

### Routes

```ruby
resources :models do
  patch :order, on: :collection
end
```

### Model
```ruby
class Model < ApplicationRecord
  attribute :orderable, :integer
  
  default_scope { order(orderable: :asc) }
end
```

### Controller
```ruby
def index
   render locals: { collection: Model.all }
end

def order
  order_params[:models].each do |id, attrs|
    Model.find(id).update(attrs)
  end
  
  redirect_back(fallback_location: models_path, status: :see_other)
end

private

def order_params
   params.require(:order).permit(models: [:ordinal])
end
```

### View

```erb
<%= table_with(collection:) do |row| %>
  <% row.ordinal %>
  <% row.text :name %>
<% end %>
<%= table_orderable_with(collection:, url: order_models_path) %>
```

## Nested association tables

You can also use Orderable to add drag-and-drop ordering for an association.
In this example we use a component but the same approach can be used with
the extend method as above.

In this example, we're assuming that the model has a nested images association
and supports nested attributes via update. We're also assuming that the images
table is providing a default stable sort based on the `ordinal` attribute.

### Routes

```ruby
resources :galleries
```

### Model
```ruby
class Gallery < ApplicationRecord
   has_many :images
   accepts_nested_attributes_for :images
end

class Image < ApplicationRecord 
  belongs_to :gallery
   
  attribute :orderable, :integer
  
  default_scope { order(orderable: :asc) }
end
```

### Controller
```ruby
def show
   @gallery = Gallery.find(params[:id])
end

def update
   @gallery = Gallery.find(params[:id])
   @gallery.update(gallery_params)

   redirect_to @gallery, status: :see_other
end

private

def gallery_params
  params.require(:gallery).permit(images: [:ordinal])
end
```

### View

```erb
<%= table_with(collection: gallery.images) do |row| %>
  <% row.ordinal %>
  <% row.text :name %>
<% end %>
<%= table_orderable_with(collection:, url: @gallery, scope: "gallery[image_attributes]") %>
```
