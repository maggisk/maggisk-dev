module Page.RamblingIndex exposing (Model, Msg, empty, init, update, view)

import Css exposing (..)
import RemoteData exposing (WebData)
import Api
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Common exposing (maybeInit)
import Misc
import Types exposing (StyledDoc)
import Route
import Time
import List.Extra exposing (gatherEqualsBy)


type alias Model =
    { ramblings : WebData (List Api.ShortRamble)
    }


type Msg
    = GotResponse (WebData (List Api.ShortRamble))


empty : Model
empty =
    Model RemoteData.NotAsked


init : Model -> (Model, Cmd Msg)
init model =
    maybeInit model model.ramblings
        ( { model | ramblings = RemoteData.Loading }
        , Api.allRamblings (RemoteData.fromResult >> GotResponse)
        )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GotResponse ramblings ->
            ( { model | ramblings = ramblings }, Cmd.none )


view : Model -> Common.StyledDocument Msg
view model =
    RemoteData.map viewSuccess model.ramblings
        |> Misc.handleRemoteFailure


viewSuccess : List Api.ShortRamble -> StyledDoc Msg
viewSuccess ramblings =
    { title = "Ramblings"
    , body =
        List.map viewYear (gatherEqualsBy (.time >> (Time.toYear Time.utc)) ramblings)
    }


viewYear : (Api.ShortRamble, List Api.ShortRamble) -> Html Msg
viewYear (r, rambles) =
    div []
        [ h2 [] [ text <| String.fromInt <| Time.toYear Time.utc r.time ]
        , div [] (List.map viewRamble (r :: rambles))
        ]


viewRamble : Api.ShortRamble -> Html Msg
viewRamble r =
    li [ css lineStyle ]
        [ span [ css dateStyle ]
            [ span [] [ text <| Misc.shortMonthName <| Time.toMonth Time.utc r.time ]
            , span [] [ text " " ]
            , span [] [ text <| String.fromInt <| Time.toDay Time.utc r.time ]
            ]
        , a [ Route.href (Route.Rambling r.slug), css linkStyle ]
            [ text r.title ]
        ]


lineStyle : List Style
lineStyle =
    [ listStyleType none
    , fontSize (px 24)
    , margin2 (px 15) zero
    ]


linkStyle : List Style
linkStyle =
    [ textDecoration none
    ]


dateStyle : List Style
dateStyle =
    [ fontSize (px 16)
    , display inlineBlock
    , paddingRight (px 20)
    ]
