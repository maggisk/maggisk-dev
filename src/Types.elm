module Types exposing (StyledDoc, Point)

import Html.Styled exposing (Html)


type alias StyledDoc msg =
    { title : String
    , body : List (Html msg)
    }


type alias Point =
    { x : Float
    , y : Float
    }
