import {Controller} from "@hotwired/stimulus";

export default class SearchController extends Controller {
    static targets = ["form", "input"];

    update = debounce(() => {
        // suppress input when empty, setting form hides the input from its container
        this.inputTargets.forEach((e) => e.toggleAttribute("form", e.value === ""));
        this.formTarget.requestSubmit();
    });
}

function debounce(f, timeout = 300) {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => {
            f.apply(this, args);
        }, timeout);
    }
}
