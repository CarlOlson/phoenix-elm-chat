module UpdateTest exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String

import Update exposing (..)
import Model exposing (..)

updateTest : Test
updateTest =
    describe "Update"
        [ test "NoOp should do nothing" <|
              \() ->
                  Expect.equal (update NoOp init) (init ! [])
        , test "Put stores values in our model store" <|
            \() ->
                let
                    model = case (update (Put Username "carl") init) of
                               (model, cmd) -> model
                in
                    Expect.equal (get Username model) (Just "carl")
        , test "Submit Message clears the input box" <|
            \() ->
                let
                    init_model = put Message "hello" init
                    final_model = case (update (Submit FMessage) init_model) of
                                      (model, cmd) -> model
                in
                    Expect.equal (get Message final_model) (Just "")
        , test "Submit FLogin changes the view to chat" <|
            \() ->
                let
                    init_model = put Username "bob" init
                    final_model = case (update (Submit FLogin) init_model) of
                                      (model, cmd) -> model
                in
                    Expect.equal final_model.state Chat
        ]
