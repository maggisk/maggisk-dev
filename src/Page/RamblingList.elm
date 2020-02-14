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
    RemoteData.map viewSuccess model
        |> Util.handleRemoteFailure


viewSuccess : List Api.Ramble -> Util.StyledDoc Msg
viewSuccess ramblings =
    { title = "Ramblings"
    , body =
        List.map viewYear (gatherEqualsBy (.time >> Time.toYear Time.utc) ramblings)
    }


viewYear : ( Api.Ramble, List Api.Ramble ) -> Html Msg
viewYear ( r, rambles ) =
    ul [] (List.indexedMap viewRamble (r :: rambles))


viewRamble : Int -> Api.Ramble -> Html Msg
viewRamble i r =
    li [ css styleLine ]
        [ span [ Style.list [ ( styleYear, True ), ( [ visibility hidden ], i > 0 ) ] ]
            [ text <| DF.format [ DF.yearNumber, DF.text " " ] utc r.time ]
        , span [ css styleMonthDay ]
            [ text <| DF.format [ DF.monthNameAbbreviated, DF.text " ", DF.dayOfMonthSuffix ] utc r.time ]
        , a [ Route.href (Route.Rambling r.slug) ]
            [ text r.title ]
        ]


styleLine : List Style
styleLine =
    [ listStyleType none
    , fontSize (px 24)
    , margin2 (px 15) zero
    ]


styleYear : List Style
styleYear =
    [ fontSize (px 24) ]


styleMonthDay : List Style
styleMonthDay =
    [ fontSize (px 16)
    , padding2 zero (px 20)
    ]
