import { Controller } from "@hotwired/stimulus";

export default class OrderableFormController extends Controller {
  add(item) {
    const { id_name, id_value, index_name } = item.paramsValue;
    this.element.insertAdjacentHTML(
      "beforeend",
      `<input type="hidden" name="${id_name}" value="${id_value}" data-generated>
              <input type="hidden" name="${index_name}" value="${item.index}" data-generated>`
    );
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
