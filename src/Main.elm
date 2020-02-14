module Main exposing (main)

import Browser
import Browser.Dom exposing (Viewport)
import Browser.Events
import Browser.Navigation as Nav
import Css exposing (..)
import Header
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Json.Decode as Decode
import Page.Project
import Page.ProjectList
import Page.Rambling
import Page.RamblingList
import Ports
import Route exposing (Route)
import Style
import Task
import TheDude
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
    , linkHover : Bool
    , ramblingListPage : Page.RamblingList.Model
    , ramblingPage : Page.Rambling.Model
    , projectListPage : Page.ProjectList.Model
    , projectPage : Page.Project.Model
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | MouseMove Point
    | SetWindowSize Int Int
    | LinkHover Bool
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
                , mousePos = Point 0.0 0.0
                , linkHover = False
                , ramblingListPage = Page.RamblingList.empty
                , ramblingPage = Page.Rambling.empty
                , projectListPage = Page.ProjectList.empty
                , projectPage = Page.Project.empty
                }

        getWindowSize =
            Browser.Dom.getViewport
                |> Task.perform
                    (\{ viewport } ->
                        SetWindowSize (Basics.round viewport.width) (Basics.round viewport.height)
                    )
    in
    ( model, Cmd.batch [ cmd, getWindowSize ] )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked (Browser.Internal url) ->
            ( { model | linkHover = False }
            , Nav.pushUrl model.key (Url.toString url)
            )

        LinkClicked (Browser.External href) ->
            ( model, Nav.load href )

        UrlChanged url ->
            navigate { model | url = url, route = Route.fromUrl url }

        MouseMove pos ->
            ( { model | mousePos = pos }, Cmd.none )

        SetWindowSize width height ->
            ( { model | window = { width = toFloat width, height = toFloat height } }, Cmd.none )

        LinkHover hovering ->
            ( { model | linkHover = hovering }, Cmd.none )

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
        , Ports.linkHover LinkHover
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


mapDoc : (a -> msg) -> Util.StyledDoc a -> Util.StyledDoc msg
mapDoc toMsg { title, body } =
    { title = title
    , body = List.map (Html.Styled.map toMsg) body
    }


view : Model -> Browser.Document Msg
view model =
    let
        { title, body } =
            viewPage model
    in
    { title = title ++ " |> maggisk"
    , body =
        div []
            [ Style.global
            , Header.viewHeader model.url model.route
            , TheDude.viewTheDude
                model.mousePos
                30.0
                { x = model.window.width - 60, y = 45 }
                model.linkHover
            , div [ css mainStyle ] body
            , viewMouse model.mousePos
            ]
            |> toUnstyled
            |> List.singleton
    }


viewPage : Model -> Util.StyledDoc Msg
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


viewMouse : Point -> Html Msg
viewMouse pos =
    div
        [ css mouseStyle
        , style "left" (String.fromFloat pos.x ++ "px")
        , style "top" (String.fromFloat pos.y ++ "px")
        ]
        []


mainStyle : List Style
mainStyle =
    [ maxWidth (px 800)
    , margin3 (px 30) auto zero
    ]


mouseStyle : List Style
mouseStyle =
    [ position fixed
    , Css.width (px 20)
    , Css.height (px 20)
    , borderRadius (pct 50)
    , margin4 (px -10) zero zero (px -10)
    , backgroundColor (rgba 244 224 77 0.25)
    , pointerEvents none
    ]
