import { Controller } from "@hotwired/stimulus";

export default class FilterModalController extends Controller {
  static targets = ["modal"];

  close(e) {
    delete this.modalTarget.dataset.open;
  }

  open(e) {
    this.modalTarget.dataset.open = "true";
  }
}
