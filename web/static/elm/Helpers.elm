module Helpers exposing (uniq)

import Set

uniq list =
    Set.toList (Set.fromList list)
