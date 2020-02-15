module TheDude exposing (viewTheDude)

import Css exposing (..)
import Css.Transitions exposing (transition)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, style)
import Util exposing (Point)


viewTheDude : Point -> Float -> Point -> Bool -> Html msg
viewTheDude mouse headRadius center surprised =
    let
        eyeRadius =
            headRadius * 0.6

        lEye =
            { x = center.x - (headRadius * 0.7), y = center.y + headRadius * 0.1 }

        rEye =
            { x = center.x + (headRadius * 0.6), y = center.y + headRadius * 0.1 }

        mouthPos =
            { x = (lEye.x + rEye.x) / 2, y = center.y + headRadius * 0.65 }
    in
    div []
        [ head headRadius center
        , glasses eyeRadius lEye rEye
        , eyeball eyeRadius mouse lEye
        , eyeball eyeRadius mouse rEye
        , mouth surprised mouthPos
        ]


head : Float -> Point -> Html msg
head radius center =
    div [ css (circle radius ++ setPosition center) ] []


glasses : Float -> Point -> Point -> Html msg
glasses eyeRadius l r =
    div []
        [ div [ css (circle eyeRadius ++ setPosition { x = l.x + eyeRadius, y = l.y } ++ [ height (px 0) ]) ] []
        , div [ css (circle eyeRadius ++ setPosition l) ] []
        , div [ css (circle eyeRadius ++ setPosition r) ] []
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
        [ css
            [ position fixed
            , border3 (px 3) solid (hex "000")
            , borderRadius (pct 50)
            , margin4 (px -3) zero zero (px -3)
            ]
        , style "left" (String.fromFloat center.x ++ "px")
        , style "top" (String.fromFloat center.y ++ "px")
        , style "transform" <|
            String.join " "
                [ "translateX(" ++ String.fromFloat (cos angle * distance) ++ "px)"
                , "translateY(" ++ String.fromFloat (sin angle * distance) ++ "px)"
                ]
        ]
        []


mouth : Bool -> Point -> Html msg
mouth surprised pos =
    let
        transitions =
            transition
                [ Css.Transitions.height 100
                , Css.Transitions.width 100
                ]

        openState =
            if surprised then
                []

            else
                [ height (px 0), width (px 10) ]
    in
    div [ css (transitions :: circle 7 ++ setPosition pos ++ openState) ] []


circle : Float -> List Style
circle radius =
    [ width (px (radius * 2))
    , height (px (radius * 2))
    , backgroundColor (hex "fff")
    , border3 (px 2) solid (hex "000")
    , borderRadius (pct 50)
    , transform (translate2 (pct -50) (pct -50))
    ]


setPosition : Point -> List Style
setPosition { x, y } =
    [ position fixed
    , left (px x)
    , top (px y)
    ]
