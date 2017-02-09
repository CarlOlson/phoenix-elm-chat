module Forms exposing (..)

import Http
import Json.Decode as Json
import Task

postForm : String -> Http.Body -> Task
postForm msg url body =
    Http.send msg
        <| Http.post url body
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
