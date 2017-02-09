module Model exposing (..)

import Material

type alias Model =
    { mdl : Material.Model
    }

init =
    Model Material.model
