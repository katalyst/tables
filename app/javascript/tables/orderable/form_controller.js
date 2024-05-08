import { Controller } from "@hotwired/stimulus";

export default class OrderableFormController extends Controller {
  static values = { scope: String };

  add(item) {
    item.params(this.scopeValue).forEach(({ name, value }) => {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<input type="hidden" name="${name}" value="${value}" data-generated>`,
      );
    });
  }

  submit() {
    if (this.inputs.length === 0) return;

    this.element.requestSubmit();
  }

  clear() {
    this.inputs.forEach((input) => input.remove());
  }

  get inputs() {
    return this.element.querySelectorAll("input[data-generated]");
  }
}
