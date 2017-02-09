module Model exposing (..)

import Dict exposing (Dict)
import Material
import Maybe exposing (..)

type alias Model =
    { mdl : Material.Model
    , store : Dict String String
    }

init =
    Model Material.model Dict.empty

put : String -> String -> Model -> Model
put key value model =
    { model |
      store = Dict.insert key value model.store
    }

get : String -> Model -> Maybe String
get key model =
    Dict.get key model.store

getDefault : String -> String -> Model -> String
getDefault key default model =
    case get key model of
        Just value ->
            value
        Nothing ->
            default
