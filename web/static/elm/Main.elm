module Main exposing (main)

import Html exposing (..)

main = Html.program
       { init = (init, Cmd.none)
       , update = update
       , view = view
       , subscriptions = (always Sub.none)
       }

-- MODEL
type alias Model =
    {
    }

init = {}

-- UPDATE
type Msg
    = NoOp

update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    (model, Cmd.none)

-- VIEW
view : model -> Html.Html msg
view model =
    div [] []
