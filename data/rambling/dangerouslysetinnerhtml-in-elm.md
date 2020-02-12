* @title dangerouslySetInnerHTML in Elm
* @slug dangerouslysetinnerhtml-in-elm
* @time 2020-02-12 13:28

I love the elm language, but sometimes I'm baffled by the decisions made by the authors. How can you have the skill and experience to create something like elm, yet [not realize](https://github.com/elm/html/issues/172) that there are plenty of valid reasons to want to render html provided by the server. Displaying html created using a rich text editor is one very common scenario. Every major web framework provides this feature, yet it was removed from elm.

There are plenty of really ugly suggestions in that issue thread, yet no fully working code examples of how to solve this. So here it is, the least ugly solution using [custom elements](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_custom_elements).

Add this custom element to your javascript.
```javascript
if (window.customElements) {
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
}
```

And a wrapper function on the elm side to use it
```elm
import Html exposing (node)
import Html.Attributes exposing (attribute)


dangerouslySetInnerHtml : String -> Html msg
dangerouslySetInnerHtml html =
    node "elm-innerhtml" [ attribute "html" html ] []
```

Works in every major browser except IE11 and below.
