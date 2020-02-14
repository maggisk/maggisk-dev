module Header exposing (viewHeader)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, style)
import Route exposing (Route)
import Style
import Url exposing (Url)


viewHeader : Url -> Maybe Route -> Html msg
viewHeader url route =
    header [ css headerStyle ]
        [ div [ css leftSectionStyle ]
            [ h1 [ css titleStyle ]
                [ a [ css linkStyle, Route.href Route.default ] [ text "Maggisk.dev" ]
                ]
            , div [ css siteSummaryStyle ]
                [ a [ css linkStyle, Route.href Route.default ]
                    [ span [ style "font-family" "monospace" ] [ text "|> " ]
                    , text "Ramblings of a software developer"
                    ]
                ]
            ]
        , div [ css centerSectionStyle ]
            [ div [] <|
                List.map viewLink
                    [ ( "Ramblings", Route.RamblingList, isMatch url route "/" "/ramble/" )
                    , ( "Projects", Route.ProjectList, isMatch url route "/projects" "/projects/" )
                    ]
            ]
        , div [ css sectionStyle ]
            []
        ]


logoLink : List (Html msg) -> Html msg
logoLink content =
    a [ Route.href Route.default ] content


sectionStyle : List Style
sectionStyle =
    [ displayFlex
    , flex (int 1)
    , flexDirection column
    , padding (px 20)
    ]


leftSectionStyle : List Style
leftSectionStyle =
    [ batch sectionStyle
    , textAlign left
    , padding (px 20)
    ]


centerSectionStyle : List Style
centerSectionStyle =
    [ batch sectionStyle
    , justifyContent flexEnd
    ]


viewLink : ( String, Route, Bool ) -> Html msg
viewLink ( title, route, selected ) =
    a
        [ Route.href route
        , Style.list
            [ ( headerLinkStyle, True )
            , ( headerLinkSelectedStyle, selected )
            ]
        ]
        [ text title ]


isMatch : Url -> Maybe Route -> String -> String -> Bool
isMatch { path } route exact prefix =
    route /= Nothing && (path == exact || String.startsWith prefix path)


headerStyle : List Style
headerStyle =
    [ textAlign center
    , color Style.white
    , backgroundColor Style.dark
    , displayFlex
    , Css.property "justify-content" "space-evenly"
    ]


titleStyle : List Style
titleStyle =
    [ margin zero
    , fontSize (px 22)
    ]


linkStyle : List Style
linkStyle =
    [ color Style.white
    , hover [ backgroundColor transparent ]
    ]


siteSummaryStyle : List Style
siteSummaryStyle =
    [ fontSize (px 14) ]


headerLinkStyle : List Style
headerLinkStyle =
    [ batch linkStyle
    , display inlineBlock
    , padding (px 5)
    , margin2 zero (px 10)
    , fontSize (px 20)
    , hover [ batch headerLinkSelectedStyle ]
    ]


headerLinkSelectedStyle : List Style
headerLinkSelectedStyle =
    [ borderBottom3 (px 2) solid Style.white
    ]
