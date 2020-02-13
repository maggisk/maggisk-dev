module Page.Rambling exposing (Model, Msg, empty, init, update, view)

import Api
import Common exposing (maybeInit)
import Dict exposing (Dict)
import Html.Styled exposing (..)
import Misc
import RemoteData exposing (WebData)


type alias Model =
    Dict String (WebData Api.Ramble)


type Msg
    = GotResponse String (WebData Api.Ramble)


empty : Model
empty =
    Dict.empty


getBySlug : String -> Dict String (WebData Api.Ramble) -> WebData Api.Ramble
getBySlug slug ramblings =
    Dict.get slug ramblings
        |> Maybe.withDefault RemoteData.NotAsked


init : Model -> String -> ( Model, Cmd Msg )
init model slug =
    maybeInit model
        (getBySlug slug model)
        ( Dict.insert slug RemoteData.Loading model
        , Api.rambling (RemoteData.fromResult >> GotResponse slug) slug
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update (GotResponse slug rambling) model =
    ( Dict.insert slug rambling model, Cmd.none )


view : Model -> String -> Common.StyledDocument Msg
view model slug =
    RemoteData.map viewSuccess (getBySlug slug model)
        |> Misc.handleRemoteFailure


viewSuccess : Api.Ramble -> Common.StyledDocument Msg
viewSuccess ramble =
    { title = ramble.title
    , body =
        [ h2 [] [ text ramble.title ]
        , Misc.innerHtml (ramble.body |> Maybe.withDefault "<!-- missing body -->")
        ]
    }
