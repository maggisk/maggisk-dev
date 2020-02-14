module TheDude exposing (viewTheDude)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, id, style)
import Util exposing (Point)


viewTheDude : Point -> Float -> Point -> Html msg
viewTheDude mouse headRadius center =
    let
        eyeRadius =
            headRadius * 0.6

        lEye =
            { x = center.x - (headRadius * 0.7), y = center.y + headRadius * 0.1 }

        rEye =
            { x = center.x + (headRadius * 0.6), y = center.y + headRadius * 0.1 }
    in
    div []
        [ div [ css (headStyle headRadius center) ] []
        , div [ css (eyeStyle eyeRadius lEye) ] []
        , div [ css (eyeStyle eyeRadius rEye) ] []
        , eyeball eyeRadius mouse lEye
        , eyeball eyeRadius mouse rEye
        ]


eyeball : Float -> Point -> Point -> Html msg
eyeball eyeRadius mouse center =
    let
        distance =
            sqrt (((mouse.x - center.x) ^ 2) + ((mouse.y - center.y) ^ 2))
                |> min (eyeRadius * 0.75)

        angle =
            atan2 (mouse.y - center.y) (mouse.x - center.x)
    in
    div
        [ css (eyeballStyle center)
        , style "left" (String.fromFloat (center.x + (cos angle * distance)) ++ "px")
        , style "top" (String.fromFloat (center.y + (sin angle * distance)) ++ "px")
        ]
        []


headStyle : Float -> Point -> List Style
headStyle radius center =
    [ batch (circle radius)
    , position fixed
    , top (px center.y)
    , left (px center.x)
    ]


eyeStyle : Float -> Point -> List Style
eyeStyle radius center =
    [ batch (circle radius)
    , position fixed
    , left (px center.x)
    , top (px center.y)
    ]


eyeballStyle : Point -> List Style
eyeballStyle pos =
    [ position fixed
    , border3 (px 3) solid (hex "000")
    , borderRadius (pct 50)
    , margin4 (px -3) zero zero (px -3)
    ]


circle : Float -> List Style
circle radius =
    [ width (px (radius * 2))
    , height (px (radius * 2))
    , backgroundColor (hex "fff")
    , border3 (px 2) solid (hex "000")
    , borderRadius (pct 50)
    , margin4 (px -radius) zero zero (px -radius)
    ]
