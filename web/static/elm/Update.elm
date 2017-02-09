module Update exposing (..)

import Model exposing (..)
import Forms exposing (..)

import Material

type Msg
    = NoOp
    | Mdl (Material.Msg Msg)
    | Put Key String
    | Submit

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            model ! []
        Mdl msg_ ->
            Material.update Mdl msg_ model
        Put key value ->
            put key value model ! []
        Submit ->
            -- TODO show to server verification
            model ! [ postForm (\_ -> NoOp) "/users"
                          <| "username" := withDefault "" Username model
                          & "password" := withDefault "" Password model
                    ]
