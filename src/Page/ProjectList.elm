module Page.ProjectList exposing (Model, Msg, empty, init, update, view)

import Api
import Common exposing (maybeInit)
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes
import Misc
import RemoteData exposing (WebData)
import Route


type alias Model =
    WebData (List Api.Project)


type Msg
    = GotResponse (WebData (List Api.Project))


empty : Model
empty =
    RemoteData.NotAsked


init : Model -> ( Model, Cmd Msg )
init model =
    maybeInit model
        model
        ( RemoteData.Loading
        , Api.allProjects (RemoteData.fromResult >> GotResponse)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update (GotResponse projects) model =
    ( projects, Cmd.none )


view : Model -> Common.StyledDocument Msg
view model =
    RemoteData.map viewSuccess model
        |> Misc.handleRemoteFailure


viewSuccess : List Api.Project -> Common.StyledDocument Msg
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
        , span [] [ Misc.innerHtml project.summary ]
        ]
