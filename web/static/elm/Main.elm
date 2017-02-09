module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

import Material
import Material.Scheme
import Material.Button as Button
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Grid as Grid exposing (grid, cell, Device(..))
import Material.Layout as Layout
import Material.Options as Options exposing (css)
import Material.Textfield as Textfield
import Material.Typography as Typo

main = Html.program
       { init = (init, Cmd.none)
       , update = update
       , view = view
       , subscriptions = (always Sub.none)
       }

-- MODEL
type alias Model =
    { mdl : Material.Model
    }

init =
    Model Material.model

-- UPDATE
type Msg
    = NoOp
    | Mdl (Material.Msg Msg)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            model ! []
        Mdl msg_ ->
            Material.update Mdl msg_ model

-- VIEW
view : Model -> Html.Html Msg
view model =
    Layout.render Mdl model.mdl []
        { header = []
        , drawer = []
        , tabs = ([], [])
        , main = [mainView model]
        }
        |> (Material.Scheme.topWithScheme Color.Teal Color.Red)

mainView model =
    Options.div [ Options.center
                , css "padding-top" "8%" ]
        [ loginView model ]

loginView model =
    Options.div [ Elevation.e2
                , css "width" "auto" ]
        [ Options.styled p
              [ Typo.center
              , Typo.headline
              , css "padding-top" "8%" ]
              [ text "Login / Register" ]
        , textfield 0 model
            [ Textfield.label "Username"
            ] []
        , textfield 1 model
            [ Textfield.label "Password"
            , Textfield.password
            ] []
        , freeDiv [ css "padding" "0% 8% 8% 8%" ]
            [ Button.render Mdl [2] model.mdl
                  [ Button.raised
                  , Button.ripple ]
                  [ text "Submit" ]
            ]
        ]

textfield id model =
    \a b ->
        freeDiv []
            [ Textfield.render Mdl [id] model.mdl a b ]

freeDiv attrs body =
    Options.div (attrs ++ [ Options.center
                          , css "padding" "0% 8% 0% 8%"
                          ])
        body
