module Forms exposing (..)

import Http exposing (encodeUri)
import Json.Decode as Json
import Task exposing (Task)

-- postForm : msg -> String -> String -> Task
postForm msg url body =
    Http.send msg
        <| Http.post url (formRequest body)
        <| Json.succeed 0

formRequest : String -> Http.Body
formRequest string =
    Http.stringBody "application/x-www-form-urlencoded" string

infix 2 :=
(:=) : String -> String -> String
(:=) key value =
    encodeUri key ++ "=" ++ encodeUri value

infix 1 &
(&) : String -> String -> String
(&) left right =
    left ++ "&" ++ right
