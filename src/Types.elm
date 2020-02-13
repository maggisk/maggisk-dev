module Types exposing (Point, StyledDoc)

import Html.Styled exposing (Html)


type alias StyledDoc msg =
    { title : String
    , body : List (Html msg)
    }


type alias Point =
    { x : Float
    , y : Float
    }
