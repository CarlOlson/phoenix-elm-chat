module View exposing (view, uniq)

import Model exposing (..)
import Update exposing (..)

import Set

import Html exposing (..)
import Html.Attributes exposing (..)
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
import Material.Options as Options exposing (css)
import Material.Textfield as Textfield
import Material.Typography as Typo

min_pass_length = 6

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
                 Options.div [ Options.center
                             , css "padding-top" "8%" ]
                     [ loginView model ]
             Chat ->
                 chatView model)

chatView model =
    div [ style [ ("height", "100vh")
                , ("padding", "1em 1em 1em 1em")
                , ("display", "table") -- container
                ] ]
        [ div [ style [ ("display", "table-row")
                      , ("height", "100%") -- expander
                      ] ] [ messagesView model ]
        , textfield Message 2 model
            [ Textfield.label "Chat now..."
            , onEnter (Submit FMessage)
            ] []
        ]

messagesView model =
    let
        messageView model zindex =
            case model of
                (message, style) ->
                    div ( Animation.render style
                              ++ [ Html.Attributes.style
                                       [ ("padding", "0em 0em 0em 0em")
                                       , ("z-index", toString zindex)
                                       , ("position", "relative")
                                       ]
                         ]
                        )
                    [ Options.div [ css "width"           "100%"
                                  , css "height"          "auto"
                                  , css "padding"         "0em 0em 0em 1em"
                                  , css "backgroundColor" "black"
                                  , css "color"           "white"
                                  ]
                          [ p [ Html.Attributes.style [ ("height", "inherit") ] ]
                                [ text (message.username ++ ":")
                                , br [] []
                                , text message.message ]
                          ]
                    ]
        rec messages acc =
            case messages of
                [] ->
                    acc
                message :: rest ->
                    rec rest (messageView message (-1 * (List.length acc)) :: acc)
    in
        div [ style [ ("overflow-y", "scroll") -- scroller
                             , ("height", "100%")
                             ]
                     , id "messages"
                     ]
            (rec model.messages [])

loginView model =
    Options.div [ Elevation.e2
                , css "width" "auto" ]
        [ Options.styled p
              [ Typo.center
              , Typo.headline
              , css "padding-top" "8%" ]
              [ text "Login" ]
        , textfield Username 0 model
            [ Textfield.label "Username"
            ] []
        -- , textfield Password 1 model
        --     [ Textfield.label "Password"
        --     , Textfield.password
        --     , Textfield.error ("Password too short")
        --     |> Options.when (try (\pass -> String.length pass < min_pass_length)
        --                          False
        --                          Password
        --                          model)
        --     ] []
        , freeDiv [ css "padding" "0% 8% 8% 8%" ]
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
        freeDiv []
            [ Textfield.render Mdl [id] model.mdl
                  (a ++ [ Textfield.value <| withDefault "" key model
                        , Options.onInput <| Put key
                        ])
                  b ]

freeDiv attrs body =
    Options.div (attrs ++ [ Options.center
                          , css "padding" "0% 8% 0% 8%"
                          ])
        body

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
                     (List.map userView (uniq <| allUsers model.messages)) ]

uniq list =
    Set.toList (Set.fromList list)

allUsers messages =
    case messages of
        [] ->
            []
        (message, style) :: rest ->
            message.username :: (allUsers rest)
