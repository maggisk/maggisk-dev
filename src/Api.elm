module Api exposing (FullRamble, ShortRamble, allRamblings, rambling)

import Time
import Http
import Json.Decode as Decode
import Html exposing (Html)


type alias FullRamble =
    { metadata : ShortRamble
    , body : String
    }


type alias ShortRamble =
    { title : String
    , slug : String
    , time : Time.Posix
    }


allRamblings : (Result Http.Error (List ShortRamble) -> msg) -> Cmd msg
allRamblings toMsg =
    getJson toMsg "/api/rambling.json" (Decode.list (rambleDetailsDecoder))


rambling : (Result Http.Error FullRamble -> msg) -> String -> Cmd msg
rambling toMsg slug =
    getJson toMsg ("/api/rambling/" ++ slug ++ ".json") rambleDecoder


getJson : (Result Http.Error a -> msg) -> String -> Decode.Decoder a -> Cmd msg
getJson toMsg url decoder =
    Http.get
        { url = url
        , expect = Http.expectJson toMsg decoder
        }


rambleDetailsDecoder : Decode.Decoder ShortRamble
rambleDetailsDecoder =
    Decode.map3 ShortRamble
        (Decode.field "title" Decode.string)
        (Decode.field "slug" Decode.string)
        (Decode.field "time" timeDecoder)


rambleDecoder : Decode.Decoder (FullRamble)
rambleDecoder =
    Decode.map2 FullRamble
        (Decode.at [] rambleDetailsDecoder)
        (Decode.field "body" Decode.string)


timeDecoder : Decode.Decoder Time.Posix
timeDecoder =
    Decode.int |> Decode.map Time.millisToPosix
