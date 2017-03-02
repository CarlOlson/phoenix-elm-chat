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
        , test "Receive should add a message to model" <|
            \() ->
                let
                    final_model = case (update (Receive <| ChatMessage "" "" "") init) of
                                      (model, cmd) -> model
                in
                    Expect.equal (List.length final_model.messages) 1
        , test "DeleteMessage removes the specified message" <|
            \() ->
                let
                    first_model = case (update (Receive <| ChatMessage "" "" "ID1") init) of
                                      (model, cmd) -> model
                    second_model = case (update (Receive <| ChatMessage "" "" "ID2") first_model) of
                                       (model, cmd) -> model
                    final_model = case (update (DeleteMessage "ID1") second_model) of
                                      (model, cmd) -> model
                in
                    case final_model.messages of
                        (message, _) :: [] ->
                            Expect.equal message (ChatMessage "" "" "ID2")
                        _ ->
                            Expect.fail "Incorrect number of messages"
        , test "Connected should add user to connected list" <|
            \() ->
                let
                    model = case (update (Connected "carl") init) of
                                (model, cmd) -> model
                in
                    Expect.equal model.connected ["carl"]
        , test "Connected should not add duplicate usernames" <|
            \() ->
                let
                    first_model = case (update (Connected "carl") init) of
                                      (model, cmd) -> model
                    final_model = case (update (Connected "carl") first_model) of
                                      (model, cmd) -> model
                in
                    Expect.equal final_model.connected ["carl"]
        , test "Disconnected should remove users from connected list" <|
            \() ->
                let
                    model = case (update (Disconnected "carl") {init | connected = ["carl"]}) of
                                (model, cmd) -> model
                in
                    Expect.equal model.connected []
        ]
