import { Controller } from "@hotwired/stimulus";

export default class OrderableFormController extends Controller {
  add(name, value) {
    this.element.insertAdjacentHTML(
      "beforeend",
      `<input type="hidden" name="${name}" value="${value}" data-generated>`,
    );
  }

  submit() {
    this.element.requestSubmit();
  }

  clear() {
    this.element
      .querySelectorAll("input[data-generated]")
      .forEach((input) => input.remove());
  }
}
