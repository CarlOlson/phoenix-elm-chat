port module Update exposing (Msg(..), Form(..), update, subscriptions)

import Model exposing (..)
import Forms exposing (..)

import Material

type Form
    = FLogin
    | FRegister
    | FMessage

type Msg
    = NoOp
    | Mdl (Material.Msg Msg)
    | Put Key String
    | Submit Form
    | Receive ChatMessage

port connect : String -> Cmd msg
port shout : String -> Cmd msg
port receive : (ChatMessage -> msg) -> Sub msg

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
        Receive message ->
            { model
                | messages = ((Debug.log "message" message) :: model.messages)
            } ! []

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
            { model | state = Chat } ! [ connect (withDefault "" Username model) ]
        FMessage ->
            (put Message "" model) ! [ shout (withDefault "" Message model) ]

subscriptions : Model -> Sub Msg
subscriptions model =
    receive Receive
