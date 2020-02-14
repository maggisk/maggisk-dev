module Page.ProjectList exposing (Model, Msg, empty, enter, update, view)

import Api
import Css exposing (..)
import Html.Styled exposing (..)
import RemoteData exposing (WebData)
import Route
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
    RemoteData.map viewSuccess model
        |> Util.handleRemoteFailure


viewSuccess : List Api.Project -> Util.StyledDoc Msg
viewSuccess projects =
    { title = "Projects"
    , body =
        [ h2 [] [ text "My stupid little pet projects" ]
        , div [] (List.map viewProject projects)
        ]
    }


viewProject : Api.Project -> Html Msg
viewProject project =
    div []
        [ a [ Route.href (Route.Project project.slug) ] [ text project.title ]
        , span [] [ Util.dangerouslySetInnerHtml project.summary ]
        ]
