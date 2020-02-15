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

var app = Elm.Main.init();

document.body.addEventListener('mouseover', function(e) {
    if (e.target.tagName == 'A')
        app.ports.linkHover.send(true);
});

document.body.addEventListener('mouseout', function(e) {
    if (e.target.tagName == 'A')
        app.ports.linkHover.send(false);
});
