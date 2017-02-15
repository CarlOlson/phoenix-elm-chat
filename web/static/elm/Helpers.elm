module Helpers exposing (uniq, allUsers)

import Set

uniq list =
    Set.toList (Set.fromList list)

allUsers model =
    let
        rec messages =
            case messages of
                [] ->
                    []
                (message, style) :: rest ->
                    message.username :: (rec rest)
    in
        rec model.messages
