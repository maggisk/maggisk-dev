module Snippets exposing (projectMeta)

import Api
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Style
import Url


projectMeta : Api.Project -> Html msg
projectMeta p =
    div [ css [ Style.subtle ] ]
        [ a [ css (styleSubtle ++ styleSubtleLink), href p.link ]
            [ text (domain p.link) ]
        , span [ css styleSubtle ]
            [ text <| "Written in " ++ p.language ]
        , span [ css styleSubtle ]
            [ text <| String.fromInt p.progress ++ "% done" ]

        -- , span [ css styleSubtle ]
        --     [ text <| "pleased: " ++ String.fromInt p.proudness ++ "/10" ]
        ]


styleSubtle : List Style
styleSubtle =
    [ Style.subtle
    , marginRight (px 20)
    ]


styleSubtleLink : List Style
styleSubtleLink =
    [ textDecoration underline
    , hover
        [ color Style.dark
        , backgroundColor transparent
        ]
    ]


domain : String -> String
domain url =
    url
        |> Url.fromString
        |> Maybe.andThen (Just << .host)
        |> Maybe.withDefault url
