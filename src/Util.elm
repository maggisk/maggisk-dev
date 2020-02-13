module Util exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (attribute)
import Http
import RemoteData exposing (RemoteData, WebData)
import Time


type alias StyledDoc msg =
    { title : String
    , body : List (Html msg)
    }


type alias Point =
    { x : Float
    , y : Float
    }


dangerouslySetInnerHtml : String -> Html msg
dangerouslySetInnerHtml html =
    node "elm-innerhtml" [ attribute "html" html ] []


isFetchNeeded : RemoteData e a -> Bool
isFetchNeeded currentData =
    RemoteData.isNotAsked currentData || RemoteData.isFailure currentData


initIfNeeded : model -> RemoteData e a -> model -> Cmd cmd -> ( model, Cmd cmd )
initIfNeeded currentModel data newModel cmd =
    if isFetchNeeded data then
        ( newModel, cmd )

    else
        ( currentModel, Cmd.none )


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


ordinalSuffix : Int -> String
ordinalSuffix i =
    if modBy (abs i) 100 // 10 == 1 then
        "th"

    else
        case modBy (abs i) 10 of
            1 ->
                "st"

            2 ->
                "nd"

            3 ->
                "rd"

            _ ->
                "th"


ordinal : Int -> String
ordinal i =
    String.fromInt i ++ ordinalSuffix i
