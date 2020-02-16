module Api exposing (Project, Ramble, allProjects, allRamblings, project, rambling)

import Http
import Json.Decode as Decode exposing (Decoder, nullable, string)
import Json.Decode.Extra exposing (parseInt)
import Json.Decode.Pipeline exposing (optional, required)
import Time


type alias Ramble =
    { title : String
    , slug : String
    , time : Time.Posix
    , body : Maybe String
    }


type alias Project =
    { title : String
    , slug : String
    , time : Time.Posix
    , summary : String
    , link : String
    , language : String
    , progress : Int
    , proudness : Int
    , body : Maybe String
    }


allRamblings : (Result Http.Error (List Ramble) -> msg) -> Cmd msg
allRamblings toMsg =
    getJson toMsg "/api/rambling.json" (Decode.list rambleDecoder)


rambling : (Result Http.Error Ramble -> msg) -> String -> Cmd msg
rambling toMsg slug =
    getJson toMsg ("/api/rambling/" ++ slug ++ ".json") rambleDecoder


allProjects : (Result Http.Error (List Project) -> msg) -> Cmd msg
allProjects toMsg =
    getJson toMsg "/api/projects.json" (Decode.list projectDecoder)


project : (Result Http.Error Project -> msg) -> String -> Cmd msg
project toMsg slug =
    getJson toMsg ("/api/projects/" ++ slug ++ ".json") projectDecoder


getJson : (Result Http.Error a -> msg) -> String -> Decoder a -> Cmd msg
getJson toMsg url decoder =
    Http.get
        { url = url
        , expect = Http.expectJson toMsg decoder
        }


rambleDecoder : Decoder Ramble
rambleDecoder =
    Decode.succeed Ramble
        |> required "title" string
        |> required "slug" string
        |> required "time" timeDecoder
        |> optional "body" (nullable string) Nothing


projectDecoder : Decoder Project
projectDecoder =
    Decode.succeed Project
        |> required "title" string
        |> required "slug" string
        |> required "time" timeDecoder
        |> required "summary" string
        |> required "link" string
        |> required "language" string
        |> required "progress" parseInt
        |> required "proudness" parseInt
        |> optional "body" (nullable string) Nothing


timeDecoder : Decoder Time.Posix
timeDecoder =
    Decode.int |> Decode.map Time.millisToPosix
