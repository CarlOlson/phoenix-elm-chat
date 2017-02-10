module Update exposing (Msg(..), Form(..), update)

import Model exposing (..)
import Forms exposing (..)

import Material

type Form
    = FLogin
    | FRegister

type Msg
    = NoOp
    | Mdl (Material.Msg Msg)
    | Put Key String
    | Submit Form

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            model ! []
        Mdl msg_ ->
            Material.update Mdl msg_ model
        Put key value ->
            put key value model ! []
        Submit form ->
            handleForm model form

handleForm : Model -> Form -> (Model, Cmd Msg)
handleForm model form =
    case form of
        FRegister ->
            -- TODO show to server verification
            model ! [ postForm (\_ -> NoOp) "/users"
                          <| "username" := withDefault "" Username model
                          & "password" := withDefault "" Password model
                    ]
        FLogin ->
            { model | state = Chat } ! []
