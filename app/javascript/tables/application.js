import TurboCollectionController from "./turbo/turbo_collection_controller";
import ItemController from "./orderable/item_controller";
import ListController from "./orderable/list_controller";
import FormController from "./orderable/form_controller";

const Definitions = [
  {
    identifier: "tables--turbo--turbo-collection",
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
