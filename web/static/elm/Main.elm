module Main exposing (main)

import Model exposing (init)
import View exposing (view)
import Update exposing (update, subscriptions)

import Html

main = Html.program
       { init = (init, Cmd.none)
       , update = update
       , view = view
       , subscriptions = subscriptions
       }
