module Model exposing (Key(..), Model, init, put, get, withDefault, try)

import Dict exposing (Dict)
import Material

type Key
    = Username
    | Password

type alias Model =
    { mdl : Material.Model
    , store : Dict String String
    }

init =
    Model Material.model Dict.empty

keyString : Key -> String
keyString key =
    case key of
        Username -> "username"
        Password -> "password"

put : Key -> String -> Model -> Model
put key value model =
    { model |
      store = Dict.insert (keyString key) value model.store
    }

get : Key -> Model -> Maybe String
get key model =
    Dict.get (keyString key) model.store

withDefault : String -> Key -> Model -> String
withDefault default key model =
    Maybe.withDefault default <| get key model

try : (String -> v) -> v -> Key -> Model -> v
try fn default key model =
    case get key model of
        Just value ->
            fn value
        Nothing ->
            default
