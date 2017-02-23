module View exposing (view, usersView, loginView, messagesView, chatView)

import Model exposing (..)
import Update exposing (..)
import Helpers exposing (..)

import Html exposing (p, text, Html, br)
import Html.Attributes
import Html.Events exposing (..)

import Json.Decode as Json

import Animation exposing (turn, percent, px)

import Material
import Material.Scheme
import Material.Button as Button
import Material.Chip as Chip
import Material.Color as Color
import Material.Dialog as Dialog
import Material.Elevation as Elevation
import Material.Layout as Layout
import Material.List as Lists
import Material.Options as Options exposing (div, css, cs, id, center)
import Material.Textfield as Textfield
import Material.Typography as Typo

view : Model -> Html.Html Msg
view model =
    Layout.render Mdl model.mdl [ Layout.fixedDrawer ]
        { header = []
        , drawer = [ usersView model ]
        , tabs = ([], [])
        , main = [mainView model]
        }
        |> (Material.Scheme.topWithScheme Color.Teal Color.Red)

mainView model =
        (case model.state of
             Login ->
                 div [ center
                     , css "padding-top" "8%" ]
                 [ loginView model ]
             Chat ->
                 chatView model)

chatView model =
    div [ id "chat-container" ]
        [ div [ id "chat-expander" ] [ messagesView model ]
        , textfield Message 2 model
            [ Textfield.label "Chat now..."
            , onEnter (Submit FMessage)
            ] []
        ]

messagesView model =
    let
        rec messages acc =
            case messages of
                [] ->
                    acc
                message :: rest ->
                    rec rest (messageView message (-1 * (List.length acc)) :: acc)
    in
        div [ id "messages" ]
            (rec model.messages [])

messageView model zindex =
    case model of
        (message, style) ->
            Html.div ( Animation.render style
                           ++ [ Html.Attributes.style
                                    [ ("z-index", toString zindex) ]
                              ]
                     )
                [ div [ cs "message" ]
                      [ p []
                            [ text (message.username ++ ":")
                            , br [] []
                            , text message.message ]
                      ]
                , div [ cs "delete-me"
                      , Options.onClick (DeleteMessage message.uuid)
                      ]
                      [ text "DELETE" ]
                ]

loginView model =
    div [ Elevation.e2
        , css "width" "auto" ]
        [ Options.styled p
              [ Typo.center
              , Typo.headline
              , css "padding-top" "8%" ]
              [ text "Login" ]
        , textfield Username 0 model
            [ Textfield.label "Username"
            ] []
        , div [ center
              , css "padding" "0% 8% 8% 8%" ]
              [ Button.render Mdl [2] model.mdl
                    [ Button.raised
                    , Button.ripple
                    , Options.onClick (Submit FLogin) ]
                    [ text "Submit" ]
              ]
        ]

textfield : Key -> Int -> Model -> List (Textfield.Property Msg) -> List b -> Html Msg
textfield key id model =
    \a b ->
        div [ center
            , css "padding" "0% 8% 0% 8%" ]
            [ Textfield.render Mdl [id] model.mdl
                  (a ++ [ Textfield.value <| withDefault "" key model
                        , Options.onInput <| Put key
                        ])
                  b ]

onEnter : Msg -> Options.Property c Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                msg
            else
                NoOp
    in
        Options.on "keydown" (Json.map isEnter keyCode)

usersView model =
    let
        userView username =
            Lists.li [] [
                 Lists.content [] [
                      Chip.span []
                          [ Chip.content []
                                [ text username ]
                          ]
                     ]
                ]
    in
        div [] [ Lists.ul []
                     (List.map userView (uniq <| allUsers model)) ]
