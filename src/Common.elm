module Common exposing (StyledDocument, maybeInit, shouldFetch)

import Html.Styled exposing (Html)
import RemoteData exposing (RemoteData)


type alias StyledDocument msg =
    { title : String
    , body : List (Html msg)
    }


shouldFetch : RemoteData e a -> Bool
shouldFetch data =
    case data of
        RemoteData.NotAsked ->
            True

        RemoteData.Failure _ ->
            True

        RemoteData.Loading ->
            False

        RemoteData.Success _ ->
            False


maybeInit : model -> RemoteData e a -> ( model, Cmd cmd ) -> ( model, Cmd cmd )
maybeInit currentModel data ( newModel, cmd ) =
    if shouldFetch data then
        ( newModel, cmd )

    else
        ( currentModel, Cmd.none )
