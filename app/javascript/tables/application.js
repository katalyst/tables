import TurboCollectionController from "./turbo/collection_controller";
import OrderableItemController from "./orderable/item_controller";
import OrderableListController from "./orderable/list_controller";
import OrderableFormController from "./orderable/form_controller";
import SelectionFormController from "./selection/form_controller";
import SelectionItemController from "./selection/item_controller";

const Definitions = [
  {
    identifier: "tables--turbo--collection",
    controllerConstructor: TurboCollectionController,
  },
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
];

export { Definitions as default };
