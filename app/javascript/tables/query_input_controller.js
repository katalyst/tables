import { Controller } from "@hotwired/stimulus";

export default class QueryInputController extends Controller {
  static targets = ["input", "highlight"];
  static values = { query: String };

  connect() {
    this.queryValue = this.inputTarget.value;
    this.element.dataset.connected = "";
  }

  disconnect() {
    delete this.element.dataset.connected;
  }

  update() {
    this.queryValue = this.inputTarget.value;
  }

  queryValueChanged(query) {
    this.highlightTarget.innerHTML = "";

    new Parser().parse(query).tokens.forEach((token) => {
      this.highlightTarget.appendChild(token.render());
    });
  }

  replaceToken(e) {
    let tokenToAdd = e.detail.token.toString();

    // wrap in quotes if it contains a spaces or special characters
    if (/\s/.exec(tokenToAdd)) {
      tokenToAdd = `"${tokenToAdd}"`;
    }

    const indexPosition = e.detail.position;
    let caretPosition = indexPosition + tokenToAdd.length;
    let sliceStart = indexPosition;
    let sliceEnd = indexPosition;

    // detect if position has a token already, if so, replace it
    const existingToken = new Parser()
      .parse(this.queryValue)
      .tokenAtPosition(indexPosition);
    if (existingToken) {
      // We don't want to include the trailing space as we are replacing an existing value
      tokenToAdd = tokenToAdd.trim();

      // Slice up to the beginning of the tokens value (not the initial caret position)
      sliceStart = existingToken.startOfValue();

      // Slice after the end of the tokens value
      sliceEnd = existingToken.endOfValue();

      // The end position of the newly added token
      caretPosition = sliceStart + tokenToAdd.length;
    }

    // Replace any text within sliceStart and sliceEnd with tokenToAdd
    this.inputTarget.value =
      this.queryValue.slice(0, sliceStart) +
      tokenToAdd +
      this.queryValue.slice(sliceEnd);

    // Re focus the input at the end of the newly added token
    this.update();
    this.inputTarget.focus();
    this.inputTarget.setSelectionRange(caretPosition, caretPosition);
  }
}

class Parser {
  constructor() {
    this.tokens = [];
    this.values = null;
  }

  parse(input) {
    const query = new StringScanner(input);

    while (!query.isEos()) {
      this.push(this.skipWhitespace(query));

      const value = this.takeTagged(query) || this.takeUntagged(query);

      if (!this.push(value)) break;
    }

    return this;
  }

  push(token) {
    if (token) {
      this.values ? this.values.push(token) : this.tokens.push(token);
    }

    return !!token;
  }

  skipWhitespace(query) {
    if (!query.scan(/\s+/)) return;

    return new Token(query.matched(), query.position);
  }

  takeUntagged(query) {
    if (!query.scan(/\S+/)) return;

    return new Untagged(query.matched(), query.position);
  }

  takeTagged(query) {
    if (!query.scan(/(\w+(?:\.\w+)?)(:\s*)/)) return;

    const key = query.valueAt(1);
    const separator = query.valueAt(2);

    const value =
      this.takeArrayValue(query) || this.takeSingleValue(query) || new Token();

    return new Tagged(key, separator, value, query.position);
  }

  takeArrayValue(query) {
    if (!query.scan(/\[\s*/)) return;

    const start = new Token(query.matched(), query.position);
    const values = (this.values = []);

    while (!query.isEos()) {
      if (!this.push(this.takeSingleValue(query))) break;
      if (!this.push(this.takeDelimiter(query))) break;
    }

    query.scan(/\s*]/);
    const end = new Token(query.matched(), query.position);

    this.values = null;

    return new ArrayToken(start, values, end);
  }

  takeDelimiter(query) {
    if (!query.scan(/\s*,\s*/)) return;

    return new Token(query.matched(), query.position);
  }

  takeSingleValue(query) {
    return this.takeQuotedValue(query) || this.takeUnquotedValue(query);
  }

  takeQuotedValue(query) {
    if (!query.scan(/"([^"]*)"/)) return;

    return new Value(query.matched(), query.position);
  }

  takeUnquotedValue(query) {
    if (!query.scan(/[^ \],]*/)) return;

    return new Value(query.matched(), query.position);
  }

  tokenAtPosition(position) {
    return this.tokens
      .filter((t) => t instanceof Tagged || t instanceof Untagged)
      .find((t) => t.range.includes(position));
  }
}

class Token {
  constructor(value = "", position) {
    this.value = value;
    this.length = this.value.length;
    this.start = position - this.length;
    this.end = this.start + this.length;
    this.range = this.arrayRange(this.start, this.end);
  }

  render() {
    return document.createTextNode(this.value);
  }

  arrayRange(start, stop) {
    return Array.from(
      { length: stop - start + 1 },
      (value, index) => start + index,
    );
  }

  startOfValue() {
    return this.start;
  }

  endOfValue() {
    return this.end;
  }
}

class Value extends Token {
  render() {
    const span = document.createElement("span");
    span.className = "value";
    span.innerText = this.value;

    return span;
  }
}

class Tagged extends Token {
  constructor(key, separator, value, position) {
    super();

    this.key = key;
    this.separator = separator;
    this.value = value;
    this.length = key.length + separator.length + value.value.length;
    this.start = position - this.length;
    this.end = this.start + this.length;
    this.range = this.arrayRange(this.start, this.end);
  }

  render() {
    const span = document.createElement("span");
    span.className = "tag";

    const key = document.createElement("span");
    key.className = "key";
    key.innerText = this.key;

    span.appendChild(key);
    span.appendChild(document.createTextNode(this.separator));
    span.appendChild(this.value.render());

    return span;
  }

  startOfValue() {
    return this.value.startOfValue();
  }

  endOfValue() {
    return this.value.endOfValue();
  }
}

class Untagged extends Token {
  render() {
    const span = document.createElement("span");
    span.className = "untagged";
    span.innerText = this.value;
    return span;
  }
}

class ArrayToken extends Token {
  constructor(start, values, end) {
    super();

    this.start = start;
    this.values = values;
    this.end = end;
    this.range = this.arrayRange(start.start, end.range[end.length]);
    this.length =
      start.length +
      values.reduce((length, value) => length + value.length, 0) +
      end.length;
  }

  render() {
    const array = document.createElement("span");
    array.className = "array-values";
    array.appendChild(this.start.render());

    this.values.forEach((value) => {
      const span = document.createElement("span");
      span.appendChild(value.render());
      array.appendChild(span);
    });

    array.appendChild(this.end.render());

    return array;
  }

  startOfValue() {
    return this.start.start;
  }

  endOfValue() {
    return this.end.end;
  }
}

class StringScanner {
  constructor(input) {
    this.input = input;
    this.position = 0;
    this.last = null;
  }

  isEos() {
    return this.position >= this.input.length;
  }

  scan(regex) {
    const match = regex.exec(this.input.substring(this.position));
    if (match?.index === 0) {
      this.last = match;
      this.position += match[0].length;
      return true;
    } else {
      this.last = {};
      return false;
    }
  }

  matched() {
    return this.last && this.last[0];
  }

  valueAt(index) {
    return this.last && this.last[index];
  }
}
