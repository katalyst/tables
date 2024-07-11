import { Controller } from "@hotwired/stimulus";

export default class QueryInputController extends Controller {
  static targets = ["input", "highlight"];
  static values = { query: String };

  connect() {
    this.queryValue = this.inputTarget.value;
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

  beforeMorph(e) {
    console.log(e);
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

    return new Token(query.matched());
  }

  takeUntagged(query) {
    if (!query.scan(/\S+/)) return;

    return new Untagged(query.matched());
  }

  takeTagged(query) {
    if (!query.scan(/(\w+(?:\.\w+)?)(:\s*)/)) return;

    const key = query.valueAt(1);
    const separator = query.valueAt(2);

    const value =
      this.takeArrayValue(query) || this.takeSingleValue(query) || new Token();

    return new Tagged(key, separator, value);
  }

  takeArrayValue(query) {
    if (!query.scan(/\[\s*/)) return;

    const start = new Token(query.matched());
    const values = (this.values = []);

    while (!query.isEos()) {
      if (!this.push(this.takeSingleValue(query))) break;
      if (!this.push(this.takeDelimiter(query))) break;
    }

    query.scan(/\s*]/);
    const end = new Token(query.matched());

    this.values = null;

    return new Array(start, values, end);
  }

  takeDelimiter(query) {
    if (!query.scan(/\s*,\s*/)) return;

    return new Token(query.matched());
  }

  takeSingleValue(query) {
    return this.takeQuotedValue(query) || this.takeUnquotedValue(query);
  }

  takeQuotedValue(query) {
    if (!query.scan(/"([^"]*)"/)) return;

    return new Value(query.matched());
  }

  takeUnquotedValue(query) {
    if (!query.scan(/[^ \],]*/)) return;

    return new Value(query.matched());
  }
}

class Token {
  constructor(value = "") {
    this.value = value;
  }

  render() {
    return document.createTextNode(this.value);
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
  constructor(key, separator, value) {
    super();

    this.key = key;
    this.separator = separator;
    this.value = value;
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
}

class Untagged extends Token {
  render() {
    const span = document.createElement("span");
    span.className = "untagged";
    span.innerText = this.value;
    return span;
  }
}

class Array extends Token {
  constructor(start, values, end) {
    super();

    this.start = start;
    this.values = values;
    this.end = end;
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
