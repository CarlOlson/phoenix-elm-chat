port module Main exposing (..)

import ModelTest exposing (..)
import ViewTest exposing (..)
import HelpersTest exposing (..)

import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)
import Test exposing (describe)

main : TestProgram
main =
    run emit <| describe "" [ modelTest, viewTest, helpersTest ]


port emit : ( String, Value ) -> Cmd msg
