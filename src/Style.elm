module Style exposing (..)

import Css exposing (..)
import Css.Global as Global
import Css.Transitions
import Html.Styled exposing (Html)
import Html.Styled.Attributes exposing (css)


white : Color
white =
    hex "#ecf0f1"


dark : Color
dark =
    hex "#2c3e50"


gray : Color
gray =
    hex "#979daf"


linkColor : Color
linkColor =
    hex "#2980b9"


prominent : Style
prominent =
    fontSize (px 24)


subtle : Style
subtle =
    batch
        [ fontSize (px 14)
        , color gray
        , fontWeight normal
        ]


list : List ( List Style, Bool ) -> Html.Styled.Attribute msg
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
            , boxSizing borderBox
            ]
        , Global.selector "h1, h2, h3, h4, h5, h6"
            [ fontFamilies [ "'Proza Libre'", "sans-serif" ]
            , margin2 (px 30) zero
            ]
        , Global.selector "p"
            [ margin2 (px 25) zero
            ]
        , Global.selector "a"
            [ color linkColor
            , textDecoration none
            , Css.Transitions.transition
                [ Css.Transitions.backgroundColor 200
                , Css.Transitions.color 200
                ]
            , hover
                [ color (hex "fff")
                , backgroundColor linkColor
                ]
            ]
        , Global.selector "li"
            [ listStylePosition inside
            ]
        , Global.selector "code"
            [ backgroundColor (rgba 244 224 77 0.25)
            ]
        , Global.selector "pre code"
            [ display block
            , overflowX auto
            , backgroundColor (hex "fff")
            , padding (px 10)
            , fontSize (px 16)
            ]
        ]
