module Update exposing (..)

import Model exposing (Model)

import Material

type Msg
    = NoOp
    | Mdl (Material.Msg Msg)
    | Submit

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            model ! []
        Mdl msg_ ->
            Material.update Mdl msg_ model
        Submit ->
            model ! []
