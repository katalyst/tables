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
    this.row.style.transform = `scale(1.01) translateY(${offset}px)`;
    this.row.style.zIndex = "1";
    this.row.toggleAttribute("dragging", true);
  }

  /**
   * Called on items that are not the dragged item during drag. Updates the
   * visual position of the item relative to the dragged item.
   *
   * @param offset {number} intended offset of the item during drag
   */
  updateVisually(offset) {
    this.row.style.transform = `translateY(${offset - this.#offsetTop}px)`;
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
   * Value for use in comparisons during drag. Used by ListController to
   * determine whether the dragged item is above or below another item.
   *
   * @returns {number}
   */
  get dragPosition() {
    return this.dragOffset && this.dragOffset !== 0
      ? this.#leadingEdge
      : this.#midpoint;
  }

  /**
   * The containing row element.
   *
   * @returns {HTMLElement}
   */
  get row() {
    return this.element.parentElement;
  }

  get height() {
    return this.row.offsetHeight;
  }

  get #midpoint() {
    return this.#offsetTop + this.height / 2;
  }

  get #leadingEdge() {
    const top = this.#offsetTop + this.dragOffset;

    return this.dragOffset < 0 ? top : top + this.height;
  }

  get #offsetTop() {
    return this.row.offsetTop;
  }
}

function domIndex(element) {
  return Array.from(element.parentElement.children).indexOf(element);
}
