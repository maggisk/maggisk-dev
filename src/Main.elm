module Main exposing (main)

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Common
import Url exposing (Url)
import Json.Decode as Decode
import Route exposing (Route)
import Style
import Api
import TheDude
import Types exposing (Point)
import Page.RamblingIndex
import Page.Rambling


type alias Model =
    { key : Nav.Key
    , route : Maybe Route
    , loading : Bool
    , mousePos : Point
    , ramblingIndexPage : Page.RamblingIndex.Model
    , ramblingPage : Page.Rambling.Model
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | MouseMove Point
    | RamblingIndexMsg Page.RamblingIndex.Msg
    | RamblingMsg Page.Rambling.Msg


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
    navigate
        { key = key
        , route = Nothing
        , loading = True
        , mousePos = Point 0.0 0.0
        , ramblingIndexPage = Page.RamblingIndex.empty
        , ramblingPage = Page.Rambling.empty
        }
        url


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LinkClicked (Browser.Internal url) ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        LinkClicked (Browser.External href) ->
            ( model, Nav.load href )

        UrlChanged url ->
            navigate model url

        MouseMove pos ->
            ( { model | mousePos = pos }, Cmd.none )

        RamblingIndexMsg submsg ->
            let
                ( submodel, cmd ) = Page.RamblingIndex.update submsg model.ramblingIndexPage
            in
                ( { model | ramblingIndexPage = submodel }, Cmd.map RamblingIndexMsg cmd )

        RamblingMsg submsg ->
            let
                ( submodel, cmd ) = Page.Rambling.update submsg model.ramblingPage
            in
                ( { model | ramblingPage = submodel }, Cmd.map RamblingMsg cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onMouseMove (Decode.map MouseMove decodeMousePos)


decodeMousePos : Decode.Decoder Point
decodeMousePos =
    Decode.map2 Point
        (Decode.field "pageX" Decode.float)
        (Decode.field "pageY" Decode.float)


navigate : Model -> Url -> (Model, Cmd Msg)
navigate model url =
    initPage { model | route = Route.fromUrl url }


initPage : Model -> (Model, Cmd Msg)
initPage model =
    case model.route of
        Just Route.RamblingIndex ->
            Page.RamblingIndex.init model.ramblingIndexPage
                |> mergeModelCmd RamblingIndexMsg (\page -> { model | ramblingIndexPage = page} )

        Just (Route.Rambling slug) ->
            Page.Rambling.init model.ramblingPage slug
                |> mergeModelCmd RamblingMsg (\page -> { model | ramblingPage = page} )

        Nothing ->
            ( model, Cmd.none )


mergeModelCmd : (cmd -> Msg) -> (a -> Model) -> (a, Cmd cmd) -> (Model, Cmd Msg)
mergeModelCmd mapCmd updateModel (submodel, subcmd) =
    ( updateModel submodel, Cmd.map mapCmd subcmd )


view : Model -> Browser.Document Msg
view model =
    let
        { title, body } = viewPage model
    in
    { title = title ++ " |> maggisk"
    , body =
        List.map toUnstyled
            [ Style.global
            , viewHeader
            , TheDude.viewTheDude model.mousePos
            , div [ css Style.main_ ] body
            , viewMouse model.mousePos
            ]
    }





leftEyeStyle : List Style
leftEyeStyle =
    []


rightEyeStyle : List Style
rightEyeStyle =
    []


viewPage : Model -> Common.StyledDocument Msg
viewPage model =
    case model.route of
        Just Route.RamblingIndex ->
            Page.RamblingIndex.view model.ramblingIndexPage
                |> mapHtml RamblingIndexMsg

        Just (Route.Rambling slug) ->
            Page.Rambling.view model.ramblingPage slug
                |> mapHtml RamblingMsg

        Nothing ->
            { title = "404"
            , body =
                [ h2 [] [ text "Not Found" ]
                , div [] [ text "Sorry :(" ]
                ]
            }


mapHtml : (a -> msg) -> Common.StyledDocument a -> Common.StyledDocument msg
mapHtml toMsg { title, body } =
    { title = title
    , body = List.map (Html.Styled.map toMsg) body
    }


viewHeader : Html Msg
viewHeader =
    let
        links =
            [ ("Ramblings", Route.RamblingIndex)
            , ("Projects", Route.RamblingIndex)
            , ("CV", Route.RamblingIndex)
            ]
    in
    header [css Style.header]
        [ h1 [ css Style.headerTitle ]
            [ text "Maggisk"
            , span [ css [ fontSize (px 14) ] ] [ text " |> Ramblings of a software developer" ]
            ]
        , div [ css Style.headerLinks ]
            [ a [ Route.href Route.RamblingIndex
                , Style.list
                    [ (Style.headerLink, True)
                    , (Style.headerLinkSelected, True)
                    ]
                ]
                [ text "Ramblings" ]
            , a [ css Style.headerLink, href "" ] [ text "Projects" ]
            , a [ css Style.headerLink, href "" ] [ text "CV" ]
            ]
        ]


viewMain : Html Msg
viewMain =
    main_ [ css Style.main_ ]
        [
        ]


viewMouse : Point -> Html Msg
viewMouse pos =
    div
        [ css Style.mouse
        , style "left" ((String.fromFloat pos.x) ++ "px")
        , style "top" ((String.fromFloat pos.y) ++ "px")
        ]
        []
