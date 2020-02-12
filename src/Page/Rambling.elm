module Page.Rambling exposing (Model, Msg, empty, init, update, view)

import RemoteData exposing (WebData)
import Api
import Html.Styled exposing (..)
import Common exposing (maybeInit)
import Dict exposing (Dict)
import Misc


type alias Model =
    { ramblings : Dict String (WebData Api.FullRamble)
    }


type Msg
    = GotResponse String (WebData Api.FullRamble)


empty : Model
empty =
    Model Dict.empty


getBySlug : String -> Dict String (WebData Api.FullRamble) -> WebData Api.FullRamble
getBySlug slug ramblings =
    Dict.get slug ramblings
        |> Maybe.withDefault RemoteData.NotAsked


init : Model -> String -> (Model, Cmd Msg)
init model slug =
    maybeInit model (getBySlug slug model.ramblings)
        ( { model | ramblings = Dict.insert slug RemoteData.Loading model.ramblings }
        , (Api.rambling (RemoteData.fromResult >> (GotResponse slug)) slug)
        )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GotResponse slug rambling ->
            ( { model | ramblings = Dict.insert slug rambling model.ramblings }
            , Cmd.none
            )


view : Model -> String -> Common.StyledDocument Msg
view model slug =
    RemoteData.map viewSuccess (getBySlug slug model.ramblings)
        |> Misc.handleRemoteFailure


viewSuccess : Api.FullRamble -> Common.StyledDocument Msg
viewSuccess r =
    { title = r.metadata.title
    , body =
        [ h2 [] [ text r.metadata.title ]
        , Misc.innerHtml r.body
        ]
    }
