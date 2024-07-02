import { Controller } from "@hotwired/stimulus";

export default class SelectionTableController extends Controller {
  static targets = ["header", "item"];
  static outlets = ["tables--selection--form"];

  itemTargetConnected(item) {
    this.update();
  }

  itemTargetDisconnected(item) {
    this.update();
  }

  toggleHeader(e) {
    this.items.forEach((item) => {
      if (item.checkedValue === e.target.checked) return;

      item.checkedValue = this.tablesSelectionFormOutlet.toggle(item.id);
    });
  }

  async update() {
    this.updating ||= Promise.resolve().then(() => {
      this.#update();
      delete this.updating;
    });

    return this.updating;
  }

  #update() {
    let present = 0;
    let checked = 0;

    this.items.forEach((item) => {
      present++;
      if (item.checkedValue) checked++;
    });

    this.headerInput.checked = present > 0 && checked === present;
    this.headerInput.indeterminate = checked > 0 && checked !== present;
  }

  get headerInput() {
    return this.headerTarget.querySelector("input");
  }

  get items() {
    return this.itemTargets.map((el) => this.#itemOutlet(el)).filter((c) => c);
  }

  /**
   * Ideally we would be using outlets, but as of turbo 8.0.4 outlets do not fire disconnect events when morphing.
   *
   * Instead, we're using the targets to finds the controller.
   */
  #itemOutlet(el) {
    return this.application.getControllerForElementAndIdentifier(
      el,
      "tables--selection--item",
    );
  }
}
