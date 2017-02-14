module ViewTest exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String

import View exposing (..)

viewTest : Test
viewTest = describe "View"
           [ describe "uniq"
                 [ test "should remove duplicates" <|
                       \() ->
                           Expect.equal (uniq [1,1]) [1]
                 , test "should not modify list if no duplicates" <|
                     \() ->
                         Expect.equal (uniq [1,2]) [1,2]
                 ]
           ]
