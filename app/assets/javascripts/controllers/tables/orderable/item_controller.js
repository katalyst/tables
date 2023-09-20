import { Controller } from "@hotwired/stimulus";

export default class OrderableRowController extends Controller {
  static values = {
    params: Object,
  };

  get index() {
    return this.paramsValue.index_value;
  }
}
