module Misc exposing (handleRemoteFailure, innerHtml, shortMonthName)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (attribute)
import Http
import RemoteData exposing (WebData)
import Time
import Types exposing (StyledDoc)


handleRemoteFailure : WebData (StyledDoc msg) -> StyledDoc msg
handleRemoteFailure data =
    case data of
        RemoteData.Failure (Http.BadStatus 404) ->
            error404

        RemoteData.Failure (Http.BadBody _) ->
            error404

        RemoteData.Failure _ ->
            error500

        RemoteData.NotAsked ->
            error500

        RemoteData.Loading ->
            loading

        RemoteData.Success doc ->
            doc


error404 : StyledDoc msg
error404 =
    { title = "Not Found"
    , body =
        [ h2 [] [ text "404 Not Found" ]
        , div [] [ text "Sorry :(" ]
        ]
    }


error500 : StyledDoc msg
error500 =
    { title = "Whoops"
    , body =
        [ h2 [] [ text "Whoops - error occured" ]
        , div [] [ text "Sorry :(" ]
        ]
    }


loading : StyledDoc msg
loading =
    { title = "..."
    , body =
        []
    }


shortMonthName : Time.Month -> String
shortMonthName month =
    case month of
        Time.Jan ->
            "jan"

        Time.Feb ->
            "feb"

        Time.Mar ->
            "mar"

        Time.Apr ->
            "apr"

        Time.May ->
            "mai"

        Time.Jun ->
            "jun"

        Time.Jul ->
            "jul"

        Time.Aug ->
            "aug"

        Time.Sep ->
            "sep"

        Time.Oct ->
            "okt"

        Time.Nov ->
            "nov"

        Time.Dec ->
            "dec"


innerHtml : String -> Html msg
innerHtml html =
    node "elm-innerhtml" [ attribute "html" html ] []
