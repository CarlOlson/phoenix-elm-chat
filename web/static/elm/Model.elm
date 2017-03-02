module Model exposing (Key(..), State(..), ChatMessage, Model, init, put, get, withDefault, try)

import Dict exposing (Dict)

import Animation

import Material

type Key
    = Username
    | Password
    | Message

type State
    = Login
    | Chat

type alias ChatMessage =
    { username : String
    , body : String
    , uuid : String
    }

type alias Model =
    { mdl : Material.Model
    , store : Dict String String
    , state : State
    , messages : List (ChatMessage, Animation.State)
    , connected : List String
    }

init =
    Model Material.model Dict.empty Login [] []

keyString : Key -> String
keyString key =
    case key of
        Username -> "username"
        Password -> "password"
        Message -> "message"

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
