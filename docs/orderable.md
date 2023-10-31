# Orderable extension

The Orderable extension adds the ability to bulk-update an 'order' column for
model instances from an index table view.

The extension can be enabled on a specific table instance of mixed in to a
table component class. In either case, the extension will add new functionality
to the table component and any nested row components, plus a hidden form 
component that needs to be rendered in the page separately.

## Usage

You can add the orderable extension to an existing table instance by calling
extend on the table instance:

```ruby
table      = Katalyst::TableComponent.new(collection:)
table.extend(Katalyst::Table::Orderable)
```

You can also include the extension in a table component class:

```ruby
class OrderedTableComponent < Katalyst::TableComponent
  include Katalyst::Table::Orderable
```

In both cases, you will need to configure the orderable form that is generated
for submitting changes to order data. This can be done by calling

```ruby
table.with_orderable(url: order_models_path)
```

 * `url` is required, when a user interacts with the table elements, this URL
   will be patched with any changes to order data.
 * `scope` is optional and defaults to `order[#{collection.model_name.plural}]`.
   This is used as a prefix for the generated params. This is useful if, for
   example, you want to use an existing update method that expects the params
   in accepts_nested_attributes format.

In your views, or row partials, you will also need to call `row.ordinal` to
generate the ordinal column. This column provides a drag handle for the row
and stores metadata for generating updates after drag events.

By default, ordinal columns will expect and update the `ordinal` attribute on
the given rows. You can override this by passing `attribute` to the row
ordinal call. This is useful if you want to use a different attribute for
sorting, such as `index`. You can also override the primary key attribute,
which defaults to `id`, by passing `primary_key` to the row ordinal call.

By default ordinal columns render a `⠿` icon to the cell. This can be configured
by setting I18n for `katalyst.table.orderable.value`.

When using the extension, the table will generate a hidden form component that
also needs to be rendered into the page. This form is identified by its ID, so
it can be placed anywhere within the page. You can see some examples below.

## Index tables

Orderable can be used to add drag-and-drop ordering to an index table. The
minimal example looks like this:

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
    collection = Collection.new.with_params(params).apply(Model.all)
    table      = Katalyst::TableComponent.new(collection:)
    table.extend(Katalyst::Table::Orderable)
    table.with_orderable(url: order_models_path)

    render locals: { table: table }
end

def order
  order_params = params.require(:order).permit(models: [:id, :ordinal])
  order_params[:models].each do |id, attrs|
    Model.find(id).update(attrs)
  end
  
  redirect_back(fallback_location: models_path, status: :see_other)
end
```

### View

```erb
<%= render table do |row| %>
  <% row.ordinal %>
  <% row.cell :name %>
<% end %>
<%= render table.orderable %>
```

This style of table can also be constructed by including `Orderable` into a
table component class that inherits from `Katalyst::TableComponent`. This could
look like:

### Component
```ruby
class ModelTableComponent < Katalyst::TableComponent
  include Katalyst::Table::Orderable

  def initialize(collection:)
    super
  end
  
  def before_render
    # note that path construction requires a controller context
    with_orderable(url: order_models_path)
  end
  
  def call
    # in the include scenario, orderable is a standard component slot
    render_parent_to_string + orderable.to_s
  end
end
```

You can render the form manually or via the component, both shown above. 

## Nested association tables

You can also use orderable to add drag-and-drop ordering for an association.
In this example we use a component but the same approach can be used with
the extend method as above.

```ruby
class ImagesTableComponent < Katalyst::Turbo::TableComponent
  include Katalyst::Tables::Orderable
  include KpopHelper

  def initialize(model)
    @model = model
  
    collection = Katalyst::Tables::Collection::Base.new.apply(model.images)
  
    super(collection:, id: "images", caption: true)
  end
  
  def before_render
    with_orderable(url:, scope:)
  end
  
  def new_image_url
    [:new, @model, :image]
  end
  
  def turbo_stream_response?
    response.media_type.eql?("text/vnd.turbo-stream.html")
  end
  
  private
  
  def url
    [@model]
  end
  
  def scope
    "#{@model.model_name.param_key}[images_attributes]"
  end
end
```

```erb
<%= turbo_stream.kpop.dismiss if turbo_stream_response? %>
<%= render_parent %>
<% unless turbo_stream_response? %>
  <div class="actions-group">
    <%= kpop_link_to("Add Image", new_image_url, class: "button button--secondary") %>
  </div>
  <%= orderable %>
<% end %>
```

In this example, we're assuming that the model has a nested images association
and supports nested attributes via update. We're also assuming that the images
table is providing a default stable sort based on the `ordinal` attribute.

This example uses turbo for in-place updates and `katalyst-kpop` for creating in
a modal, but these features are not required for the example.

For Katalyst developers, this example is based on the Adelaide Fringe
Merchandise model which has nested Gallery Images. Merchandise demonstrates both
an index ordinal table and a nested attributes ordinal table.
