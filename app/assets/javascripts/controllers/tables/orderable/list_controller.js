import { Controller } from "@hotwired/stimulus";

export default class OrderableListController extends Controller {
  static outlets = ["tables--orderable--item", "tables--orderable--form"];

  dragstart(event) {
    if (this.element !== event.target.parentElement) return;

    const target = event.target;
    event.dataTransfer.effectAllowed = "move";

    // update element style after drag has begun
    setTimeout(() => (target.dataset.dragging = ""));
  }

  dragover(event) {
    if (!this.dragItem) return;

    swap(this.dropTarget(event.target), this.dragItem);

    event.preventDefault();
    return true;
  }

  dragenter(event) {
    event.preventDefault();
  }

  drop(event) {
    if (!this.dragItem) return;

    event.preventDefault();
    delete this.dragItem.dataset.dragging;

    this.update();
  }

  update() {
    // clear any existing inputs to prevent duplicates
    this.tablesOrderableFormOutlet.clear();

    // insert any items that have changed position
    this.tablesOrderableItemOutlets.forEach((item, index) => {
      if (item.valueValue !== index) {
        this.tablesOrderableFormOutlet.add(item.nameValue, index);
      }
    });

    this.tablesOrderableFormOutlet.submit();
  }

  get dragItem() {
    return this.element.querySelector("[data-dragging]");
  }

  dropTarget($e) {
    while ($e && $e.parentElement !== this.element) {
      $e = $e.parentElement;
    }
    return $e;
  }
}

function swap(target, item) {
  if (target && target !== item) {
    const positionComparison = target.compareDocumentPosition(item);
    if (positionComparison & Node.DOCUMENT_POSITION_FOLLOWING) {
      target.insertAdjacentElement("beforebegin", item);
    } else if (positionComparison & Node.DOCUMENT_POSITION_PRECEDING) {
      target.insertAdjacentElement("afterend", item);
    }
  }
}
