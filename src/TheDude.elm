module TheDude exposing (viewTheDude)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, style)
import Util exposing (Point)


viewTheDude : Point -> Html msg
viewTheDude mousePos =
    div []
        [ div [ css dudeStyle ] []

        -- , viewEye 60 90 mousePos
        -- , viewEye 140 90 mousePos
        ]


viewEye : Float -> Float -> Point -> Html msg
viewEye x y mouse =
    div
        [ css eyeStyle
        , style "top" (String.fromFloat y ++ "px")
        , style "left" (String.fromFloat x ++ "px")
        , style "transform-origin" "left top"
        ]
        [ div
            [ css rotaterStyle
            , style "transform-origin" "top left"
            , style "width" (String.fromFloat (eyeballDistance x y mouse |> min 30.0) ++ "px")
            , style "rotate" (String.fromFloat (atan2 (mouse.y - y) (mouse.x - x)) ++ "rad")
            ]
            [ div [ css eyeballStyle ] []
            ]
        ]


eyeballDistance : Float -> Float -> Point -> Float
eyeballDistance x y mouse =
    sqrt ((x - mouse.x) ^ 2 + (y - mouse.y) ^ 2)


dudeStyle : List Style
dudeStyle =
    [ position absolute
    , top (px 15)
    , right (px 15)
    , backgroundImage (url "/dude.png")
    , backgroundSize contain
    , backgroundRepeat noRepeat
    , Css.width (px 80)
    , Css.height (px 80)
    ]


eyeStyle : List Style
eyeStyle =
    [ position absolute
    ]


rotaterStyle : List Style
rotaterStyle =
    [ position absolute
    , top zero
    ]


eyeballStyle : List Style
eyeballStyle =
    [ position absolute
    , right zero
    , top (px -5)
    , width (px 10)
    , height (px 10)
    , borderRadius (pct 50)
    , backgroundColor (hex "000")
    ]
