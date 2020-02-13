module Page.RamblingList exposing (Model, Msg, empty, init, update, view)

import Api
import Common exposing (maybeInit)
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import List.Extra exposing (gatherEqualsBy)
import Misc
import RemoteData exposing (WebData)
import Route
import Time
import Types exposing (StyledDoc)


type alias Model =
    WebData (List Api.Ramble)


type Msg
    = GotResponse (WebData (List Api.Ramble))


empty : Model
empty =
    RemoteData.NotAsked


init : Model -> ( Model, Cmd Msg )
init model =
    maybeInit model
        model
        ( RemoteData.Loading
        , Api.allRamblings (RemoteData.fromResult >> GotResponse)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update (GotResponse ramblings) model =
    ( ramblings, Cmd.none )


view : Model -> Common.StyledDocument Msg
view model =
    RemoteData.map viewSuccess model
        |> Misc.handleRemoteFailure


viewSuccess : List Api.Ramble -> StyledDoc Msg
viewSuccess ramblings =
    { title = "Ramblings"
    , body =
        List.map viewYear (gatherEqualsBy (.time >> Time.toYear Time.utc) ramblings)
    }


viewYear : ( Api.Ramble, List Api.Ramble ) -> Html Msg
viewYear ( r, rambles ) =
    div []
        [ h2 [] [ text <| String.fromInt <| Time.toYear Time.utc r.time ]
        , div [] (List.map viewRamble (r :: rambles))
        ]


viewRamble : Api.Ramble -> Html Msg
viewRamble r =
    li [ css styleLine ]
        [ span [ css styleDate ]
            [ span [] [ text <| Misc.shortMonthName <| Time.toMonth Time.utc r.time ]
            , span [] [ text " " ]
            , span [] [ text <| String.fromInt <| Time.toDay Time.utc r.time ]
            ]
        , a [ Route.href (Route.Rambling r.slug), css styleLink ]
            [ text r.title ]
        ]


styleLine : List Style
styleLine =
    [ listStyleType none
    , fontSize (px 24)
    , margin2 (px 15) zero
    ]


styleLink : List Style
styleLink =
    [ textDecoration none
    ]


styleDate : List Style
styleDate =
    [ fontSize (px 16)
    , display inlineBlock
    , paddingRight (px 20)
    ]
