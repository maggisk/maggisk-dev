module Page.Project exposing (Model, Msg, empty, init, update, view)

import RemoteData exposing (WebData)
import Api
import Html.Styled exposing (..)
import Common exposing (maybeInit)
import Dict exposing (Dict)
import Misc


type alias Model = Dict String (WebData Api.Project)


type Msg
    = GotResponse String (WebData Api.Project)


empty : Model
empty =
    Dict.empty


getBySlug : String -> Dict String (WebData Api.Project) -> WebData Api.Project
getBySlug slug ramblings =
    Dict.get slug ramblings
        |> Maybe.withDefault RemoteData.NotAsked


init : Model -> String -> (Model, Cmd Msg)
init model slug =
    maybeInit model (getBySlug slug model)
        ( Dict.insert slug RemoteData.Loading model
        , Api.project (RemoteData.fromResult >> (GotResponse slug)) slug
        )


update : Msg -> Model -> (Model, Cmd Msg)
update (GotResponse slug project) model =
    ( Dict.insert slug project model, Cmd.none )


view : Model -> String -> Common.StyledDocument Msg
view model slug =
    RemoteData.map viewSuccess (getBySlug slug model)
        |> Misc.handleRemoteFailure


viewSuccess : Api.Project -> Common.StyledDocument Msg
viewSuccess project =
    { title = project.title
    , body =
        [ h2 [] [ text project.title ]
        , Misc.innerHtml (project.body |> Maybe.withDefault "<!-- missing body -->")
        ]
    }
