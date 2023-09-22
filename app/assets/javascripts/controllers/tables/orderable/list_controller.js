import { Controller } from "@hotwired/stimulus";

export default class OrderableListController extends Controller {
  static outlets = ["tables--orderable--item", "tables--orderable--form"];

  //region State transitions

  startDragging(dragState) {
    this.dragState = dragState;

    document.addEventListener("mousemove", this.mousemove);
    document.addEventListener("mouseup", this.mouseup);
    window.addEventListener("scroll", this.scroll, true);

    this.element.style.position = "relative";
  }

  stopDragging() {
    const dragState = this.dragState;
    delete this.dragState;

    document.removeEventListener("mousemove", this.mousemove);
    document.removeEventListener("mouseup", this.mouseup);
    window.removeEventListener("scroll", this.scroll, true);

    this.element.removeAttribute("style");
    this.tablesOrderableItemOutlets.forEach((item) => item.reset());

    return dragState;
  }

  drop() {
    // note: early returns guard against turbo updates that prevent us finding
    // the right item to drop on. In this situation it's better to discard the
    // drop than to drop in the wrong place.

    const dragItem = this.dragItem;

    if (!dragItem) return;

    const newIndex = dragItem.dragIndex;
    const targetItem = this.tablesOrderableItemOutlets[newIndex];

    if (!targetItem) return;

    // swap the dragged item into the correct position for its current offset
    if (newIndex < dragItem.index) {
      targetItem.row.insertAdjacentElement("beforebegin", dragItem.row);
    } else if (newIndex > dragItem.index) {
      targetItem.row.insertAdjacentElement("afterend", dragItem.row);
    }

    // reindex all items based on their new positions
    this.tablesOrderableItemOutlets.forEach((item, index) =>
      item.updateIndex(index),
    );

    // save the changes
    this.commitChanges();
  }

  commitChanges() {
    // clear any existing inputs to prevent duplicates
    this.tablesOrderableFormOutlet.clear();

    // insert any items that have changed position
    this.tablesOrderableItemOutlets.forEach((item) => {
      if (item.hasChanges) this.tablesOrderableFormOutlet.add(item);
    });

    this.tablesOrderableFormOutlet.submit();
  }

  //endregion

  //region Events

  mousedown(event) {
    if (this.isDragging) return;

    const target = this.#targetItem(event.target);

    if (!target) return;

    event.preventDefault(); // prevent built-in drag

    this.startDragging(new DragState(this.element, event, target.id));

    this.dragState.updateCursor(this.element, target.row, event, this.animate);
  }

  mousemove = (event) => {
    if (!this.isDragging) return;

    event.preventDefault(); // prevent build-in drag

    if (this.ticking) return;

    this.ticking = true;

    window.requestAnimationFrame(() => {
      this.ticking = false;
      this.dragState.updateCursor(
        this.element,
        this.dragItem.row,
        event,
        this.animate,
      );
    });
  };

  scroll = (event) => {
    if (!this.isDragging || this.ticking) return;

    this.ticking = true;

    window.requestAnimationFrame(() => {
      this.ticking = false;
      this.dragState.updateScroll(
        this.element,
        this.dragItem.row,
        this.animate,
      );
    });
  };

  mouseup = (event) => {
    if (!this.isDragging) return;

    this.drop();
    this.stopDragging();
    this.tablesOrderableFormOutlets.forEach((form) => delete form.dragState);
  };

  tablesOrderableFormOutletConnected(form, element) {
    if (form.dragState) {
      // restore the previous controller's state
      this.startDragging(form.dragState);
    }
  }

  tablesOrderableFormOutletDisconnected(form, element) {
    if (this.isDragging) {
      // cache drag state in the form
      form.dragState = this.stopDragging();
    }
  }

  //endregion

  //region Helpers

  /**
   * Updates the position of the drag item with a relative offset. Updates
   * other items relative to the new position of the drag item, as required.
   *
   * @callback {OrderableListController~animate}
   * @param {number} offset
   */
  animate = (offset) => {
    const dragItem = this.dragItem;

    // Visually update the dragItem so it follows the cursor
    dragItem.dragUpdate(offset);

    // Visually updates the position of all items in the list relative to the
    // dragged item. No actual changes to orderings at this stage.
    this.#currentItems.forEach((item, index) => {
      if (item === dragItem) return;
      item.updateVisually(index);
    });
  };

  get isDragging() {
    return !!this.dragState;
  }

  get dragItem() {
    if (!this.isDragging) return null;

    return this.tablesOrderableItemOutlets.find(
      (item) => item.id === this.dragState.targetId,
    );
  }

  /**
   * Returns the current items in the list, sorted by their current index.
   * Current uses the drag index if the item is being dragged, if set.
   *
   * @returns {Array[OrderableRowController]}
   */
  get #currentItems() {
    return this.tablesOrderableItemOutlets.toSorted(
      (a, b) => a.comparisonIndex - b.comparisonIndex,
    );
  }

  /**
   * Returns the item outlet that was clicked on, if any.
   *
   * @param element {HTMLElement} the clicked ordinal cell
   * @returns {OrderableRowController}
   */
  #targetItem(element) {
    return this.tablesOrderableItemOutlets.find(
      (item) => item.element === element,
    );
  }

  //endregion
}

/**
 * During drag we want to be able to translate a document-relative coordinate
 * into a coordinate relative to the list element. This state object calculates
 * and stores internal state so that we can translate absolute page coordinates
 * from mouse events into relative offsets for the list items within the list
 * element.
 *
 * We also keep track of the drag target so that if the controller is attached
 * to a new element during the drag we can continue after the turbo update.
 */
class DragState {
  /**
   * @param list {HTMLElement} the list controller's element (tbody)
   * @param event {MouseEvent} the initial event
   * @param id {String} the id of the element being dragged
   */
  constructor(list, event, id) {
    // cursor offset is the offset of the cursor relative to the drag item
    this.cursorOffset = event.offsetY;

    // initial offset is the offset position of the drag item at drag start
    this.initialPosition = event.target.offsetTop - list.offsetTop;

    // id of the item being dragged
    this.targetId = id;
  }

  /**
   * Calculates the offset of the drag item relative to its initial position.
   *
   * @param list {HTMLElement} the list controller's element (tbody)
   * @param row {HTMLElement} the row being dragged
   * @param event {MouseEvent} the current event
   * @param callback {OrderableListController~animate} updates the drag item with a relative offset
   */
  updateCursor(list, row, event, callback) {
    // Calculate and store the list offset relative to the viewport
    // This value is cached so we can calculate the outcome of any scroll events
    this.listOffset = list.getBoundingClientRect().top;

    // Calculate the position of the cursor relative to the list.
    // Accounts for scroll offsets by using the item's bounding client rect.
    const cursorPosition = event.clientY - this.listOffset;

    // intended item position relative to the list, from cursor position
    let itemPosition = cursorPosition - this.cursorOffset;

    this.#updateItemPosition(list, row, itemPosition, callback);
  }

  /**
   * Animates the item's position as the list scrolls. Requires a previous call
   * to set the scroll offset.
   *
   * @param list {HTMLElement} the list controller's element (tbody)
   * @param row {HTMLElement} the row being dragged
   * @param callback {OrderableListController~animate} updates the drag item with a relative offset
   */
  updateScroll(list, row, callback) {
    const previousScrollOffset = this.listOffset;

    // Calculate and store the list offset relative to the viewport
    // This value is cached so we can calculate the outcome of any scroll events
    this.listOffset = list.getBoundingClientRect().top;

    // Calculate the change in scroll offset since the last update
    const scrollDelta = previousScrollOffset - this.listOffset;

    // intended item position relative to the list, from cursor position
    const position = this.position + scrollDelta;

    this.#updateItemPosition(list, row, position, callback);
  }

  #updateItemPosition(list, row, position, callback) {
    // ensure itemPosition is within the bounds of the list (tbody)
    position = Math.max(position, 0);
    position = Math.min(position, list.offsetHeight - row.offsetHeight);

    // cache the item's position relative to the list for use in scroll events
    this.position = position;

    // Item has position: relative, so we want to calculate the amount to move
    // the item relative to it's DOM position to represent how much it has been
    // dragged by.
    const offset = position - this.initialPosition;

    // Convert itemPosition from offset relative to list to offset relative to
    // its position within the DOM (if it hadn't moved).
    callback(offset);
  }
}
