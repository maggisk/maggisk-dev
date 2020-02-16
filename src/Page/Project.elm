module Page.Project exposing (Model, Msg, empty, enter, update, view)

import Api
import Browser exposing (Document)
import Dict exposing (Dict)
import Html exposing (..)
import RemoteData exposing (WebData)
import Snippets
import Util


type alias Model =
    Dict String (WebData Api.Project)


type Msg
    = GotResponse String (WebData Api.Project)


empty : Model
empty =
    Dict.empty


getBySlug : String -> Dict String (WebData Api.Project) -> WebData Api.Project
getBySlug slug ramblings =
    Dict.get slug ramblings |> Maybe.withDefault RemoteData.NotAsked


enter : Model -> String -> ( Model, Cmd Msg )
enter model slug =
    Util.initIfNeeded model
        (getBySlug slug model)
        (Dict.insert slug RemoteData.Loading model)
        (Api.project (RemoteData.fromResult >> GotResponse slug) slug)


update : Msg -> Model -> ( Model, Cmd Msg )
update (GotResponse slug project) model =
    ( Dict.insert slug project model, Cmd.none )


view : Model -> String -> Document Msg
view model slug =
    let
        success project =
            { title = project.title
            , body =
                [ h2 []
                    [ text project.title
                    , Snippets.projectMeta project
                    ]
                , project.body
                    |> Maybe.withDefault "<!-- missing body -->"
                    |> Util.dangerouslySetInnerHtml
                ]
            }
    in
    getBySlug slug model |> RemoteData.map success |> Util.handleRemoteFailure
