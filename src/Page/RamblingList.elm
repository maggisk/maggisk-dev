module Page.RamblingList exposing (Model, Msg, empty, enter, update, view)

import Api
import Browser exposing (Document)
import DateFormat as DF
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import List.Extra exposing (gatherEqualsBy)
import RemoteData exposing (WebData)
import Route
import Time exposing (utc)
import Util


type alias Model =
    WebData (List Api.Ramble)


type Msg
    = GotResponse (WebData (List Api.Ramble))


empty : Model
empty =
    RemoteData.NotAsked


enter : Model -> ( Model, Cmd Msg )
enter model =
    Util.initIfNeeded model model RemoteData.Loading <|
        Api.allRamblings (RemoteData.fromResult >> GotResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update (GotResponse ramblings) _ =
    ( ramblings, Cmd.none )


view : Model -> Document Msg
view model =
    let
        success ramblings =
            { title = "Ramblings"
            , body =
                List.map year (gatherEqualsBy (.time >> Time.toYear Time.utc) ramblings)
            }

        year ( r, rambles ) =
            div []
                [ h2 []
                    [ text <| DF.format [ DF.yearNumber ] utc r.time ]
                , ul [] (List.map ramble (r :: rambles))
                ]

        ramble r =
            li [ class "RamblingList_line" ]
                [ span [ class "RamblingList_date" ]
                    [ text <| DF.format [ DF.monthNameAbbreviated, DF.text " ", DF.dayOfMonthSuffix ] utc r.time ]
                , a [ class "RamblingList_title", Route.href (Route.Rambling r.slug) ]
                    [ text r.title ]
                ]
    in
    RemoteData.map success model |> Util.handleRemoteFailure
