port module Update exposing (Msg(..), Form(..), update, subscriptions)

import Model exposing (..)
import Forms exposing (..)

import Animation exposing (percent, px)
import Dom.Scroll exposing (..)
import Material
import Task

type Form
    = FLogin
    | FMessage

type Msg
    = NoOp
    | Mdl (Material.Msg Msg)
    | Animate Animation.Msg
    | Put Key String
    | Submit Form
    | Receive ChatMessage
    | DeleteMessage String

port connect : String -> Cmd msg
port shout : String -> Cmd msg
port delete : String -> Cmd msg
port receive : (ChatMessage -> msg) -> Sub msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            model ! []
        Mdl msg_ ->
            Material.update Mdl msg_ model
        Animate animMsg ->
            { model
                | messages = List.map (\m ->
                                           case m of
                                               (message, style) ->
                                                   (message, (Animation.update animMsg style)))
                             model.messages
            } ! []
        Put key value ->
            put key value model ! []
        Submit form ->
            handleForm model form
        Receive message ->
            { model
                | messages = (message, initMessageStyle) :: model.messages
            } ! [ Task.attempt (always NoOp) <| toBottom "messages" ]
        DeleteMessage uuid ->
            { model
                | messages = List.filter (\m -> messageUUID m /= uuid) model.messages
            }! [ delete uuid ]

messageUUID : (ChatMessage, Animation.State) -> String
messageUUID message =
    case message of
        (message, _) -> message.uuid

handleForm : Model -> Form -> (Model, Cmd Msg)
handleForm model form =
    case form of
        FLogin ->
            case get Username model of
                Just username ->
                    { model | state = Chat } ! [ connect username ]
                Nothing ->
                    model ! []
        FMessage ->
            (put Message "" model) ! [ shout (withDefault "" Message model) ]

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Animation.subscription Animate
              <| List.map (\m -> case m of (m, s) -> s) model.messages
        , receive Receive ]

initMessageStyle : Animation.State
initMessageStyle =
    let
        style =
            (Animation.style
                 [ Animation.opacity 0
                 , Animation.translate (px 0) (percent -100)
                 ])
    in
        Animation.interrupt
            [ Animation.to
                  [ Animation.opacity 1
                  , Animation.translate (px 0) (px 0)
                  ]
            ]
            style
