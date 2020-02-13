module Page.Rambling exposing (Model, Msg, empty, init, update, view)

import Api
import Dict exposing (Dict)
import Html.Styled exposing (..)
import RemoteData exposing (WebData)
import Util


type alias Model =
    Dict String (WebData Api.Ramble)


type Msg
    = GotResponse String (WebData Api.Ramble)


empty : Model
empty =
    Dict.empty


getBySlug : String -> Dict String (WebData Api.Ramble) -> WebData Api.Ramble
getBySlug slug ramblings =
    Dict.get slug ramblings |> Maybe.withDefault RemoteData.NotAsked


init : Model -> String -> ( Model, Cmd Msg )
init model slug =
    Util.initIfNeeded model
        (getBySlug slug model)
        (Dict.insert slug RemoteData.Loading model)
        (Api.rambling (RemoteData.fromResult >> GotResponse slug) slug)


update : Msg -> Model -> ( Model, Cmd Msg )
update (GotResponse slug rambling) model =
    ( Dict.insert slug rambling model, Cmd.none )


view : Model -> String -> Util.StyledDoc Msg
view model slug =
    RemoteData.map viewSuccess (getBySlug slug model)
        |> Util.handleRemoteFailure


viewSuccess : Api.Ramble -> Util.StyledDoc Msg
viewSuccess ramble =
    { title = ramble.title
    , body =
        [ h2 [] [ text ramble.title ]
        , Util.dangerouslySetInnerHtml (ramble.body |> Maybe.withDefault "<!-- missing body -->")
        ]
    }
