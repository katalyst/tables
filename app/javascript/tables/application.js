import OrderableItemController from "./orderable/item_controller";
import OrderableListController from "./orderable/list_controller";
import OrderableFormController from "./orderable/form_controller";
import SelectionFormController from "./selection/form_controller";
import SelectionItemController from "./selection/item_controller";
import SelectionTableController from "./selection/table_controller";
import QueryController from "./query_controller";
import QueryInputController from "./query_input_controller";

const Definitions = [
  {
    identifier: "tables--orderable--item",
    controllerConstructor: OrderableItemController,
  },
  {
    identifier: "tables--orderable--list",
    controllerConstructor: OrderableListController,
  },
  {
    identifier: "tables--orderable--form",
    controllerConstructor: OrderableFormController,
  },
  {
    identifier: "tables--selection--form",
    controllerConstructor: SelectionFormController,
  },
  {
    identifier: "tables--selection--item",
    controllerConstructor: SelectionItemController,
  },
  {
    identifier: "tables--selection--table",
    controllerConstructor: SelectionTableController,
  },
  {
    identifier: "tables--query",
    controllerConstructor: QueryController,
  },
  {
    identifier: "tables--query-input",
    controllerConstructor: QueryInputController,
  },
];

export { Definitions as default };
