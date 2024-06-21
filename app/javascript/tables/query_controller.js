import { Controller } from "@hotwired/stimulus";

export default class QueryController extends Controller {
  static targets = ["modal"];

  focus() {
    if (document.activeElement === this.query) return;

    this.query.addEventListener(
      "focusin",
      (e) => {
        e.target.setSelectionRange(-1, -1);
      },
      { once: true },
    );

    this.query.focus();
  }

  closeModal(e) {
    delete this.modalTarget.dataset.open;
  }

  openModal(e) {
    this.modalTarget.dataset.open = "true";
  }

  clear() {
    this.query.value = "";
    this.element.requestSubmit();
  }

  submit() {
    if (this.query.value === "") {
      this.query.disabled = true;
    }
  }

  get query() {
    return this.element.querySelector("input[type=search]");
  }
}
