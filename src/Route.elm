module Route exposing (Route(..), default, href, toUrl, fromUrl)

import Html.Styled exposing (Attribute)
import Html.Styled.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s, string)


type Route
    = RamblingIndex
    | Rambling String


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map RamblingIndex Parser.top
        , map Rambling (s "ramble" </> string)
        ]


reverse : Route -> List String
reverse route =
    case route of
        RamblingIndex ->
            []

        Rambling slug ->
            [ "ramble", slug ]


default : Route
default =
    RamblingIndex


href : Route -> Html.Styled.Attribute msg
href route =
    Html.Styled.Attributes.href (toUrl route)


toUrl : Route -> String
toUrl route =
    "/" ++ String.join "/" (reverse route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url
