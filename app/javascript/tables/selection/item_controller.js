import { Controller } from "@hotwired/stimulus";

export default class SelectionItemController extends Controller {
  static outlets = ["tables--selection--form"];
  static values = {
    params: Object,
    checked: Boolean,
  };

  tablesSelectionFormOutletConnected(form) {
    this.checkedValue = form.isSelected(this.id);
  }

  change(e) {
    e.preventDefault();

    this.checkedValue = this.tablesSelectionFormOutlet.toggle(this.id);
  }

  get id() {
    return this.paramsValue.id;
  }

  checkedValueChanged(checked) {
    this.element.querySelector("input").checked = checked;
  }
}
