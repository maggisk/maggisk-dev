module Page.RamblingList exposing (Model, Msg, empty, enter, update, view)

import Api
import Css exposing (..)
import DateFormat as DF
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import List.Extra exposing (gatherEqualsBy)
import RemoteData exposing (WebData)
import Route
import Style
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


view : Model -> Util.StyledDoc Msg
view model =
    let
        success ramblings =
            { title = "Ramblings"
            , body =
                List.map year (gatherEqualsBy (.time >> Time.toYear Time.utc) ramblings)
            }

        year ( r, rambles ) =
            ul [] (List.indexedMap ramble (r :: rambles))

        ramble i r =
            li [ css style.line ]
                [ span [ Style.list [ ( [ visibility hidden ], i > 0 ) ] ]
                    [ text <| DF.format [ DF.yearNumber, DF.text " " ] utc r.time ]
                , span [ css style.monthDay ]
                    [ text <| DF.format [ DF.monthNameAbbreviated, DF.text " ", DF.dayOfMonthSuffix ] utc r.time ]
                , a [ Route.href (Route.Rambling r.slug) ]
                    [ text r.title ]
                ]
    in
    RemoteData.map success model
        |> Util.handleRemoteFailure


style : { line : List Style, monthDay : List Style }
style =
    { line =
        [ Style.prominent
        , listStyleType none
        , margin2 (px 15) zero
        ]
    , monthDay =
        [ fontSize (px 16)
        , padding2 zero (px 20)
        ]
    }
