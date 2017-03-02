module ViewTest exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String

import Test exposing (test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (..)

import View exposing (..)
import Model exposing (..)
import Animation
import Material

mockModel = put Username "carl" { init
                                    | messages = [ (ChatMessage "carl" "hello" "ID1", Animation.style []) ]
                                    , connected = ["carl", "bob"]
                                }

viewTest : Test
viewTest = describe "View"
           [ test "users are all displayed" <|
                 \() ->
                     (usersView mockModel
                     |> Query.fromHtml
                     |> Query.find [ tag "ul" ]
                     |> Query.has [ text "bob" ])
           , test "login should show the username" <|
               \() ->
                   let
                       model = put Username "carl" init
                   in
                       (loginView model
                       |> Query.fromHtml
                       |> Query.find [ tag "input" ]
                       |> Query.has [ attribute "value" "carl" ])
           , test "messages should all be displayed" <|
               \() ->
                   (messagesView mockModel
                   |> Query.fromHtml
                   |> Query.find [ tag "p" ]
                   |> Query.has [ text "hello" ])
           , test "chat should have an message input" <|
               \() ->
                   (chatView init
                   |> Query.fromHtml
                   |> Query.has [ tag "input" ])
           , test "messages should have a delete feature" <|
               \() ->
                   (messagesView mockModel
                   |> Query.fromHtml
                   |> Query.has [ class "delete-me" ])
           , test "delete is only shown on owned messages" <|
               \() ->
                   let
                       model = put Username "bob" mockModel
                   in
                       (messagesView model
                       |> Query.fromHtml
                       |> Query.findAll [ class "delete-me" ]
                       |> Query.count (Expect.equal 0))
           ]
