import { Controller } from "@hotwired/stimulus";

/**
 * Couples an input element in a row to the selection form which is turbo-permanent and outside the table.
 * When the input is toggled, the form will create/destroy hidden inputs. The checkbox inside this cell will follow
 * the hidden inputs.
 *
 * Cell value may change when:
 *  * cell connects, e.g. when the user paginates
 *  * cell is re-used by turbo-morph, e.g. pagination
 *  * cell is toggled
 *  * select-all/de-select-all on table header
 */
export default class SelectionItemController extends Controller {
  static outlets = ["tables--selection--form"];
  static values = {
    params: Object,
    checked: Boolean,
  };

  tablesSelectionFormOutletConnected(form) {
    this.tablesSelectionFormOutlet?.visible(this.id, true);
    this.checkedValue = form.isSelected(this.id);
  }

  disconnect() {
    // Remove from form's list of visible selections.
    // This should be an outlet disconnect, but those events are not reliable in turbo 8.0
    this.tablesSelectionFormOutlet?.visible(this.id, false);
  }

  change(e) {
    e.preventDefault();

    this.checkedValue = this.tablesSelectionFormOutlet?.toggle(this.id);
  }

  get id() {
    return this.paramsValue.id;
  }

  /**
   * Update checked to match match selection form. This occurs when the item is re-used by turbo-morph.
   */
  paramsValueChanged(params, previous) {
    // if id is changing (e.g. morph) then let the form know that the previous id is now not visible
    if (previous.id !== params.id) {
      this.tablesSelectionFormOutlet?.visible(previous.id, false);
    }

    // tell form that our id is now visible in the table
    this.tablesSelectionFormOutlet?.visible(params.id, true);

    // id has changed, so update checked from form
    this.checkedValue = this.tablesSelectionFormOutlet?.isSelected(params.id);

    // propagate changes
    this.update();
  }

  /**
   * Update input to match checked. This occurs when the item is toggled, connected, or morphed.
   */
  checkedValueChanged() {
    // ensure that checked matches the form, i.e. if morphed
    this.checkedValue = this.tablesSelectionFormOutlet?.isSelected(this.id);

    // propagate changes
    this.update();
  }

  /**
   * Notify table that id or value may have changed. Note that this may fire when nothing has changed.
   *
   * Debouncing to minimise dom updates.
   */
  async update() {
    this.updating ||= Promise.resolve().then(() => {
      this.#update();
      delete this.updating;
    });

    return this.updating;
  }

  #update() {
    this.element.querySelector("input").checked = this.checkedValue;
    this.dispatch("select", {
      detail: { id: this.id, selected: this.checkedValue },
    });
  }
}
