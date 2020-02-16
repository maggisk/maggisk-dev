module Snippets exposing (projectMeta)

import Api
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Url


projectMeta : Api.Project -> Html msg
projectMeta p =
    div []
        [ a [ class "Snippets_subtle Snippets_subtle--link", href p.link ]
            [ text (domain p.link) ]
        , span [ class "Snippets_subtle" ]
            [ text <| "Written in " ++ p.language ]
        , span [ class "Snippets_subtle" ]
            [ text <| String.fromInt p.progress ++ "% done" ]
        ]


domain : String -> String
domain url =
    url
        |> Url.fromString
        |> Maybe.map .host
        |> Maybe.withDefault url
