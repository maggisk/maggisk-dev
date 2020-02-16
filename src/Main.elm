module Main exposing (main)

import Browser exposing (Document)
import Browser.Dom
import Browser.Events
import Browser.Navigation as Nav
import Header
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Page.Project
import Page.ProjectList
import Page.Rambling
import Page.RamblingList
import Route exposing (Route)
import Task
import Url exposing (Url)
import Util exposing (Point)


type alias Dimensions =
    { width : Float
    , height : Float
    }


type alias Model =
    { key : Nav.Key
    , url : Url
    , route : Maybe Route
    , loading : Bool
    , window : Dimensions
    , mousePos : Point
    , ramblingListPage : Page.RamblingList.Model
    , ramblingPage : Page.Rambling.Model
    , projectListPage : Page.ProjectList.Model
    , projectPage : Page.Project.Model
    }


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | MouseMove Point
    | SetWindowSize Int Int
    | RamblingListMsg Page.RamblingList.Msg
    | RamblingMsg Page.Rambling.Msg
    | ProjectListMsg Page.ProjectList.Msg
    | ProjectMsg Page.Project.Msg


type Page
    = ProjectPage ( Page.Project.Model, Cmd Page.Project.Msg )
    | ProjectListPage ( Page.ProjectList.Model, Cmd Page.ProjectList.Msg )
    | RamblingListPage ( Page.RamblingList.Model, Cmd Page.RamblingList.Msg )
    | RamblingPage ( Page.Rambling.Model, Cmd Page.Rambling.Msg )


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( model, cmd ) =
            navigate
                { key = key
                , url = url
                , route = Route.fromUrl url
                , loading = True
                , window = Dimensions 0.0 0.0
                , mousePos = Point -30 -30
                , ramblingListPage = Page.RamblingList.empty
                , ramblingPage = Page.Rambling.empty
                , projectListPage = Page.ProjectList.empty
                , projectPage = Page.Project.empty
                }

        toWindowSize { viewport } =
            SetWindowSize (Basics.round viewport.width) (Basics.round viewport.height)

        getWindowSize =
            Task.perform toWindowSize Browser.Dom.getViewport
    in
    ( model, Cmd.batch [ cmd, getWindowSize ] )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked (Browser.Internal url) ->
            ( model
            , Cmd.batch
                [ Nav.pushUrl model.key (Url.toString url)
                , Task.perform (always NoOp) (Browser.Dom.setViewport 0 0)
                ]
            )

        LinkClicked (Browser.External href) ->
            ( model, Nav.load href )

        UrlChanged url ->
            navigate { model | url = url, route = Route.fromUrl url }

        MouseMove pos ->
            ( { model | mousePos = pos }, Cmd.none )

        SetWindowSize width height ->
            ( { model | window = { width = toFloat width, height = toFloat height } }, Cmd.none )

        RamblingListMsg submsg ->
            merge model (RamblingListPage (Page.RamblingList.update submsg model.ramblingListPage))

        RamblingMsg submsg ->
            merge model (RamblingPage (Page.Rambling.update submsg model.ramblingPage))

        ProjectListMsg submsg ->
            merge model (ProjectListPage (Page.ProjectList.update submsg model.projectListPage))

        ProjectMsg submsg ->
            merge model (ProjectPage (Page.Project.update submsg model.projectPage))


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize SetWindowSize
        , Browser.Events.onMouseMove (Decode.map MouseMove decodeMousePos)
        ]


decodeMousePos : Decode.Decoder Point
decodeMousePos =
    Decode.map2 Point
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)


navigate : Model -> ( Model, Cmd Msg )
navigate model =
    case model.route of
        Just Route.RamblingList ->
            merge model (RamblingListPage (Page.RamblingList.enter model.ramblingListPage))

        Just (Route.Rambling slug) ->
            merge model (RamblingPage (Page.Rambling.enter model.ramblingPage slug))

        Just Route.ProjectList ->
            merge model (ProjectListPage (Page.ProjectList.enter model.projectListPage))

        Just (Route.Project slug) ->
            merge model (ProjectPage (Page.Project.enter model.projectPage slug))

        Nothing ->
            ( model, Cmd.none )


merge : Model -> Page -> ( Model, Cmd Msg )
merge model page =
    case page of
        RamblingListPage ( submodel, cmd ) ->
            ( { model | ramblingListPage = submodel }, Cmd.map RamblingListMsg cmd )

        RamblingPage ( submodel, cmd ) ->
            ( { model | ramblingPage = submodel }, Cmd.map RamblingMsg cmd )

        ProjectListPage ( submodel, cmd ) ->
            ( { model | projectListPage = submodel }, Cmd.map ProjectListMsg cmd )

        ProjectPage ( submodel, cmd ) ->
            ( { model | projectPage = submodel }, Cmd.map ProjectMsg cmd )


mapDoc : (a -> msg) -> Document a -> Document msg
mapDoc toMsg { title, body } =
    { title = title
    , body = List.map (Html.map toMsg) body
    }


view : Model -> Browser.Document Msg
view model =
    let
        { title, body } =
            viewPage model
    in
    { title = title ++ " |> maggisk"
    , body =
        [ Header.viewHeader model.url model.route
        , div [ class "Main_content" ] body
        , viewDude model.window model.mousePos
        , viewMouse model.mousePos
        ]
    }


viewPage : Model -> Document Msg
viewPage model =
    case model.route of
        Just Route.RamblingList ->
            mapDoc RamblingListMsg <| Page.RamblingList.view model.ramblingListPage

        Just (Route.Rambling slug) ->
            mapDoc RamblingMsg <| Page.Rambling.view model.ramblingPage slug

        Just Route.ProjectList ->
            mapDoc ProjectListMsg <| Page.ProjectList.view model.projectListPage

        Just (Route.Project slug) ->
            mapDoc ProjectMsg <| Page.Project.view model.projectPage slug

        Nothing ->
            Util.error404


viewDude : Dimensions -> Point -> Html Msg
viewDude window mouse =
    div [ class "Main_dude", style "left" (String.fromFloat (window.width - 80) ++ "px") ]
        [ img [ class "Main_dude", src "/img/dude.png" ] []
        , eyeball mouse (window.width - 67)
        , eyeball mouse (window.width - 37)
        ]


eyeball : Point -> Float -> Html Msg
eyeball mouse x =
    let
        y =
            47.0

        distance =
            sqrt (((mouse.x - x) ^ 2) + ((mouse.y - y) ^ 2))
                |> Basics.min 10.0

        angle =
            atan2 (mouse.y - y) (mouse.x - x)
    in
    div
        [ class "Main_eyeball"
        , style "left" (String.fromFloat (x + cos angle * distance) ++ "px")
        , style "top" (String.fromFloat (y + sin angle * distance) ++ "px")
        ]
        []


viewMouse : Point -> Html Msg
viewMouse pos =
    div
        [ class "Main_mouse"
        , style "left" (String.fromFloat pos.x ++ "px")
        , style "top" (String.fromFloat pos.y ++ "px")
        ]
        []
