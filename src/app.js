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

const app = Elm.Main.init();
const gaId = window.GAID;

if (gaId && gaId !== "") {
  window.dataLayer = window.dataLayer || [];
  window.gtag = function(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', gaId);

  let script = document.createElement('script');
  script.setAttribute('src', 'https://www.googletagmanager.com/gtag/js?id=' + gaId);
  document.body.appendChild(script);

  app.ports.onUrlChange.subscribe(function(path) {
    gtag('config', gaId, {'page_path': path});
  });
}
