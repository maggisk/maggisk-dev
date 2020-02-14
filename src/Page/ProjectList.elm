module Page.ProjectList exposing (Model, Msg, empty, enter, update, view)

import Api
import Css exposing (..)
import Css.Global exposing (descendants, typeSelector)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import RemoteData exposing (WebData)
import Route
import Snippets
import Style
import Util


type alias Model =
    WebData (List Api.Project)


type Msg
    = GotResponse (WebData (List Api.Project))


empty : Model
empty =
    RemoteData.NotAsked


enter : Model -> ( Model, Cmd Msg )
enter model =
    Util.initIfNeeded model model RemoteData.Loading <|
        Api.allProjects (RemoteData.fromResult >> GotResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update (GotResponse projects) _ =
    ( projects, Cmd.none )


view : Model -> Util.StyledDoc Msg
view model =
    let
        success : List Api.Project -> Util.StyledDoc Msg
        success projects =
            { title = "Projects"
            , body =
                [ h2 [] [ text "My dorky little pet projects" ]
                , div [] (List.map project projects)
                ]
            }

        project : Api.Project -> Html Msg
        project p =
            div []
                [ a [ css [ Style.prominent ], Route.href (Route.Project p.slug) ] [ text p.title ]
                , Snippets.projectMeta p
                , div [ css styleSummary ] [ Util.dangerouslySetInnerHtml p.summary ]
                ]
    in
    RemoteData.map success model |> Util.handleRemoteFailure


styleSummary : List Style
styleSummary =
    [ padding3 (px 5) zero (px 30)
    , descendants
        [ typeSelector "p" [ margin zero ]
        ]
    ]
