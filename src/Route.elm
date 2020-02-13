module Route exposing (Route(..), default, fromUrl, href, match, toUrl)

import Html.Styled exposing (Attribute)
import Html.Styled.Attributes
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


href : Route -> Html.Styled.Attribute msg
href route =
    Html.Styled.Attributes.href (toUrl route)


toUrl : Route -> String
toUrl route =
    "/" ++ String.join "/" (reverse route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


match : Route -> Route -> Bool
match a b =
    case ( a, b ) of
        ( RamblingList, RamblingList ) ->
            True

        ( Rambling _, Rambling _ ) ->
            True

        ( ProjectList, ProjectList ) ->
            True

        ( Project _, Project _ ) ->
            True

        _ ->
            False