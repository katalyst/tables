# Orderable extension

The Orderable extension adds the ability to bulk-update an 'order' column for
model instances from an index table view.

The extension can be enabled on a specific table instance of mixed in to a
table component class. In either case, the extension will add new functionality
to the table component and any nested row components, plus a hidden form 
component that needs to be rendered in the page separately.

A minimal example for use in practice looks like this:

```ruby
def index
    collection = Collection.new.with_params(params).apply(Model.order(:ordinal))
    table      = Katalyst::TableComponent.new(collection:)
    table.with_orderable(url: order_models_path)

    render locals: { table: table }
end

def order
  order_params = params.require(:order).permit(models: [:ordinal])
  order_params[:models].each do |id, attrs|
    Model.find(id).update(attrs)
  end
  
  redirect_back(fallback_location: models_path)
end
```

The `with_orderable` method takes a single argument, `url`, which is the URL for
the update path. When a user interacts with the table elements, this URL will
be patched with any changes to order data.

When using the extension, the table will generate a hidden form component that
also needs to be rendered into the page. This form is identified by its ID, so
it can be placed anywhere within the page. You will also need to call `ordinal`
on the row components in a location of your choosing to generate the row
metadata required for each record. By default this adds a `⠿` icon to the cell
which can be configured by setting I18n for `katalyst.table.orderable.value`.

```erb
<%= render table do |row| %>
  <% row.ordinal %>
  <% row.cell :name %>
<% end %>
<%= render table.orderable %>
```
