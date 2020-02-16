module Page.ProjectList exposing (Model, Msg, empty, enter, update, view)

import Api
import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import RemoteData exposing (WebData)
import Route
import Snippets
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


view : Model -> Document Msg
view model =
    let
        success projects =
            { title = "Projects"
            , body =
                [ h2 [] [ text "My dorky little pet projects" ]
                , div [] (List.map project projects)
                ]
            }

        project p =
            div []
                [ a [ class "ProjectList_title", Route.href (Route.Project p.slug) ] [ text p.title ]
                , Snippets.projectMeta p
                , div [ class "ProjectList_summary" ] [ Util.dangerouslySetInnerHtml p.summary ]
                ]
    in
    RemoteData.map success model |> Util.handleRemoteFailure
