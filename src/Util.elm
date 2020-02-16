module Util exposing (..)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (attribute)
import Http
import RemoteData exposing (RemoteData, WebData)


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


handleRemoteFailure : WebData (Document msg) -> Document msg
handleRemoteFailure data =
    case data of
        RemoteData.Failure (Http.BadStatus 404) ->
            error404

        RemoteData.Failure (Http.BadBody _) ->
            error500

        RemoteData.Failure _ ->
            error500

        RemoteData.NotAsked ->
            error500

        RemoteData.Loading ->
            loading

        RemoteData.Success doc ->
            doc


error404 : Document msg
error404 =
    { title = "Not Found"
    , body =
        [ h2 [] [ text "404 Not Found" ]
        , div [] [ text "Sorry :(" ]
        ]
    }


error500 : Document msg
error500 =
    { title = "Whoops"
    , body =
        [ h2 [] [ text "Whoops - that's an error" ]
        , div [] [ text "Sorry :(" ]
        ]
    }


loading : Document msg
loading =
    -- loading should be fast enough for this to be barely noticable
    { title = ""
    , body = []
    }
