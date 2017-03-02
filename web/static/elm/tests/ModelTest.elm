module ModelTest exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String

import Model exposing (..)
import Dict

modelTest : Test
modelTest = describe "Model"
        [ describe "upon initialization"
              [ test "will contain an empty data store" <|
                    \() ->
                  Expect.equal init.store Dict.empty
              , test "will start at Login state" <|
                  \() ->
                      Expect.equal init.state Login
              , test "will start with no messages" <|
                  \() ->
                      Expect.equal init.messages []
              , test "will contain no connected in users" <|
                  \() ->
                      Expect.equal init.connected []
              ]
        , describe "withDefault"
            [ test "will return the default" <|
                  \() ->
                      Expect.equal (withDefault "default" Username init) "default"
            , test "will return store value over default" <|
                \() ->
                    let
                        model = put Username "carl" init
                    in
                        Expect.equal (withDefault "default" Username model) "carl"
            ]
        , describe "try"
            [ test "will return the default" <|
                  \() ->
                      Expect.equal (try (\i -> i) "default" Username init) "default"
            , test "will apply function when key is found" <|
                \() ->
                    let
                        model = put Username "carl" init
                    in
                        Expect.equal (try ((++) "!") "" Username model) "!carl"
            ]
        ]
