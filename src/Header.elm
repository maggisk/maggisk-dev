module Header exposing (viewHeader)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Route exposing (Route)
import Url exposing (Url)


viewHeader : Url -> Maybe Route -> Html msg
viewHeader url route =
    header [ class "Header" ]
        [ div [ class "Header_section Header_section--left" ]
            [ h1 [ class "Header_title" ]
                [ a [ Route.href Route.default ] [ text "Maggisk.dev" ]
                ]
            , div [ class "Header_summary" ]
                [ a [ Route.href Route.default ]
                    [ span [ class "Header_code" ] [ text "|> " ]
                    , text "Ramblings of a software developer"
                    ]
                ]
            ]
        , div [ class "Header_section Header_section--center" ]
            [ div [] <|
                List.map viewLink
                    [ ( "Ramblings", Route.RamblingList, isMatch url route "/" "/ramble/" )
                    , ( "Projects", Route.ProjectList, isMatch url route "/projects" "/projects/" )
                    ]
            ]
        , div [ class "Header_section" ]
            []
        ]


viewLink : ( String, Route, Bool ) -> Html msg
viewLink ( title, route, selected ) =
    a
        [ Route.href route
        , classList
            [ ( "Header_tab", True )
            , ( "Header_tab--selected", selected )
            ]
        ]
        [ text title ]


isMatch : Url -> Maybe Route -> String -> String -> Bool
isMatch { path } route exact prefix =
    route /= Nothing && (path == exact || String.startsWith prefix path)
