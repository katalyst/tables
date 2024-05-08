import { Controller } from "@hotwired/stimulus";

export default class OrderableRowController extends Controller {
  static values = {
    params: Object,
  };

  connect() {
    // index from server may be inconsistent with the visual ordering,
    // especially if this is a new node. Use positional indexes instead,
    // as these are the values we will send on save.
    this.index = domIndex(this.row);
  }

  paramsValueChanged(params) {
    this.id = params.id_value;
  }

  dragUpdate(offset) {
    this.dragOffset = offset;
    this.row.style.position = "relative";
    this.row.style.top = offset + "px";
    this.row.style.zIndex = "1";
    this.row.toggleAttribute("dragging", true);
  }

  /**
   * Called on items that are not the dragged item during drag. Updates the
   * visual position of the item relative to the dragged item.
   *
   * @param index {number} intended index of the item during drag
   */
  updateVisually(index) {
    this.row.style.position = "relative";
    this.row.style.top = `${
      this.row.offsetHeight * (index - this.dragIndex)
    }px`;
  }

  /**
   * Set the index value of the item. This is called on all items after a drop
   * event. If the index is different to the params index then this item has
   * changed.
   *
   * @param index {number} the new index value
   */
  updateIndex(index) {
    this.index = index;
  }

  /** Retrieve params for use in the form */
  params(scope) {
    const { id_name, id_value, index_name } = this.paramsValue;
    return [
      { name: `${scope}[${id_value}][${id_name}]`, value: this.id },
      { name: `${scope}[${id_value}][${index_name}]`, value: this.index },
    ];
  }

  /**
   * Restore any visual changes made during drag and remove the drag state.
   */
  reset() {
    delete this.dragOffset;
    this.row.removeAttribute("style");
    this.row.removeAttribute("dragging");
  }

  /**
   * @returns {boolean} true when the item has a change to its index value
   */
  get hasChanges() {
    return this.paramsValue.index_value !== this.index;
  }

  /**
   * Calculate the relative index of the item during drag. This is used to
   * sort items during drag as it takes into account any uncommitted changes
   * to index caused by the drag offset.
   *
   * @returns {number} index for the purposes of drag and drop ordering
   */
  get dragIndex() {
    if (this.dragOffset && this.dragOffset !== 0) {
      return this.index + Math.round(this.dragOffset / this.row.offsetHeight);
    } else {
      return this.index;
    }
  }

  /**
   * Index value for use in comparisons during drag. This is used to determine
   * whether the dragged item is above or below another item. If this item is
   * being dragged then we offset the index by 0.5 to ensure that it jumps up
   * or down when it reaches the midpoint of the item above or below it.
   *
   * @returns {number}
   */
  get comparisonIndex() {
    if (this.dragOffset) {
      return this.dragIndex + (this.dragOffset > 0 ? 0.5 : -0.5);
    } else {
      return this.index;
    }
  }

  /**
   * The containing row element.
   *
   * @returns {HTMLElement}
   */
  get row() {
    return this.element.parentElement;
  }
}

function domIndex(element) {
  return Array.from(element.parentElement.children).indexOf(element);
}
