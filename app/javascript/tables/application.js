import TurboCollectionController from "./turbo/collection_controller";
import ItemController from "./orderable/item_controller";
import ListController from "./orderable/list_controller";
import FormController from "./orderable/form_controller";

const Definitions = [
  {
    identifier: "tables--turbo--collection",
    controllerConstructor: TurboCollectionController,
  },
  {
    identifier: "tables--orderable--item",
    controllerConstructor: ItemController,
  },
  {
    identifier: "tables--orderable--list",
    controllerConstructor: ListController,
  },
  {
    identifier: "tables--orderable--form",
    controllerConstructor: FormController,
  },
];

export { Definitions as default };
