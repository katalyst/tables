import { Controller } from "@hotwired/stimulus";

export default class SelectionFormController extends Controller {
  static values = {
    count: Number,
    primaryKey: { type: String, default: "id" },
  };
  static outlets = ["item"];
  static targets = ["count", "singular", "plural"];

  connect() {
    this.countValue = this.inputs.length;
  }

  reset(e) {
    e?.preventDefault();

    this.inputs.forEach((input) => input.remove());

    this.countValue = this.inputs.length;
  }

  turboSubmitEnd({ detail }) {
    if (!/get/i.test(detail.formSubmission.method)) {
      this.reset();
    }
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

    this.countValue = this.inputs.length;

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
