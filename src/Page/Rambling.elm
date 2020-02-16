module Page.Rambling exposing (Model, Msg, empty, enter, update, view)

import Api
import Browser exposing (Document)
import DateFormat as DF
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class)
import RemoteData exposing (WebData)
import Time exposing (utc)
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


enter : Model -> String -> ( Model, Cmd Msg )
enter model slug =
    Util.initIfNeeded model
        (getBySlug slug model)
        (Dict.insert slug RemoteData.Loading model)
        (Api.rambling (RemoteData.fromResult >> GotResponse slug) slug)


update : Msg -> Model -> ( Model, Cmd Msg )
update (GotResponse slug rambling) model =
    ( Dict.insert slug rambling model, Cmd.none )


view : Model -> String -> Document Msg
view model slug =
    let
        success ramble =
            { title = ramble.title
            , body =
                [ h2 []
                    [ text ramble.title
                    , span [ class "Rambling_date" ]
                        [ text <|
                            DF.format
                                [ DF.monthNameFull
                                , DF.text " "
                                , DF.dayOfMonthSuffix
                                , DF.text ", "
                                , DF.yearNumber
                                ]
                                utc
                                ramble.time
                        ]
                    ]
                , ramble.body
                    |> Maybe.withDefault "<!-- missing body -->"
                    |> Util.dangerouslySetInnerHtml
                ]
            }
    in
    getBySlug slug model |> RemoteData.map success |> Util.handleRemoteFailure
