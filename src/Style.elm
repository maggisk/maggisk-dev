module Style exposing (..)

import Css exposing (..)
import Css.Transitions
import Css.Global as Global
import Html.Styled exposing (Html)
import Html.Styled.Attributes exposing (css)


white = hex "#ecf0f1"
dark = hex "#2c3e50"


list : List (List Style, Bool) -> Html.Styled.Attribute msg
list pairs =
    pairs
    |> List.filter Tuple.second
    |> List.concatMap Tuple.first
    |> css


global : Html msg
global =
    Global.global
        [ Global.selector "html, body"
            [ fontFamilies [ "'Open Sans'", "sans-serif" ]
            , margin zero
            , padding zero
            , fontSize (px 18)
            , lineHeight (pct 150)
            , backgroundColor white
            , color dark
            ]
        , Global.selector "*"
            [ padding zero
            , margin zero
            ]
        , Global.selector "h1, h2, h3, h4, h5, h6"
            [ fontFamilies [ "'Proza Libre'", "sans-serif" ]
            , margin2 (px 30) zero
            ]
        , Global.selector "p"
            [ margin2 (px 20) zero
            ]
        , Global.selector "a"
            [ color (hex "#2980b9")
            , textDecoration none
            , Css.Transitions.transition
                [ Css.Transitions.backgroundColor 200
                , Css.Transitions.color 200
                ]
            , hover
                [ color (hex "fff")
                , backgroundColor (hex "2989b9")
                ]
            ]
        , Global.selector "li"
            [ listStylePosition inside
            ]
        , Global.selector "code"
            [ backgroundColor (hex "#fcf7cf")
            ]
        , Global.selector "pre code"
            [ display block
            , overflowX scroll
            , backgroundColor (hex "fff")
            , padding (px 10)
            , fontSize (px 16)
            ]
        ]



header : List Style
header =
    [ textAlign center
    , color white
    , backgroundColor dark
    ]


headerTitle : List Style
headerTitle =
    [ margin zero
    , padding (px 40)
    , pointerEvents none
    , fontFamily monospace
    ]


headerLinks : List Style
headerLinks =
    [ paddingBottom (px 20)
    ]


headerLink : List Style
headerLink =
    [ display inlineBlock
    , padding (px 5)
    , margin2 (px 0) (px 10)
    , color white
    , fontSize (px 20)
    , textDecoration none
    , hover
        [ batch headerLinkSelected
        , backgroundColor transparent
        ]
    ]


headerLinkSelected : List Style
headerLinkSelected =
    [ borderBottom3 (px 1) solid white
    ]


main_ : List Style
main_ =
    [ maxWidth (px 800)
    , margin3 (px 30) auto zero
    ]


mouse : List Style
mouse =
    [ position absolute
    , width (px 20)
    , height (px 20)
    , borderRadius (pct 50)
    , margin4 (px -10) zero zero (px -10)
    , backgroundColor (rgba 100 40 255 0.2)
    , pointerEvents none
    ]
