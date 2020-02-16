module Route exposing (Route(..), default, fromUrl, href, toUrl)

import Html
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s, string)


type Route
    = RamblingList
    | Rambling String
    | ProjectList
    | Project String


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map RamblingList Parser.top
        , map Rambling (s "ramble" </> string)
        , map ProjectList (s "projects")
        , map Project (s "projects" </> string)
        ]


reverse : Route -> List String
reverse route =
    case route of
        RamblingList ->
            []

        Rambling slug ->
            [ "ramble", slug ]

        ProjectList ->
            [ "projects" ]

        Project slug ->
            [ "projects", slug ]


default : Route
default =
    RamblingList


href : Route -> Html.Attribute msg
href route =
    Html.Attributes.href (toUrl route)


toUrl : Route -> String
toUrl route =
    "/" ++ String.join "/" (reverse route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url
