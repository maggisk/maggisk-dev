import 'delayed-scroll-restoration-polyfill';

if ('scrollRestoration' in history) {
  window.history.scrollRestoration = 'manual';
}

customElements.define(
  "elm-innerhtml",
  class ElmInnerHTML extends HTMLElement {
    static get observedAttributes() {
      return ["html"];
    }

    attributeChangedCallback(name, oldValue, newValue) {
      if (name == "html")
        this.innerHTML = newValue;
    }
  }
);

Elm.Main.init();
