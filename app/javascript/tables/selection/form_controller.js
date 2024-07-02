import { Controller } from "@hotwired/stimulus";

export default class SelectionFormController extends Controller {
  static values = {
    count: Number,
    primaryKey: { type: String, default: "id" },
  };
  static targets = ["count", "singular", "plural"];

  connect() {
    this.countValue = this.inputs.length;
  }

  /**
   * @param id to toggle
   * @return {boolean} true if selected, false if unselected
   */
  toggle(id) {
    const input = this.input(id);

    if (input) {
      input.remove();
    } else {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<input type="hidden" name="${this.primaryKeyValue}[]" value="${id}">`,
      );
    }

    this.countValue = this.visibleInputs.length;

    return !input;
  }

  /**
   * @param id to toggle visibility
   * @return {boolean} true if visible, false if not visible
   */
  visible(id, visible) {
    const input = this.input(id);

    if (input) {
      input.disabled = !visible;
    }

    this.countValue = this.visibleInputs.length;

    return !input;
  }

  /**
   * @returns {boolean} true if the given id is currently selected
   */
  isSelected(id) {
    return !!this.input(id);
  }

  get inputs() {
    return this.element.querySelectorAll(
      `input[name="${this.primaryKeyValue}[]"]`,
    );
  }

  get visibleInputs() {
    return Array.from(this.inputs).filter((i) => !i.disabled);
  }

  input(id) {
    return this.element.querySelector(
      `input[name="${this.primaryKeyValue}[]"][value="${id}"]`,
    );
  }

  countValueChanged(count) {
    this.element.toggleAttribute("hidden", count === 0);
    this.countTarget.textContent = count;
    this.singularTarget.toggleAttribute("hidden", count !== 1);
    this.pluralTarget.toggleAttribute("hidden", count === 1);
  }
}
