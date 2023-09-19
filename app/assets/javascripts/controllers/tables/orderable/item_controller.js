import { Controller } from "@hotwired/stimulus";

export default class OrderableRowController extends Controller {
  static values = {
    name: String,
    value: Number,
  };
}
