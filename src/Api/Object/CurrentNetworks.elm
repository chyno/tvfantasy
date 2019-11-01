-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.CurrentNetworks exposing (..)

import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.ScalarCodecs
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


{-| The document's ID.
-}
id_ : SelectionSet Api.ScalarCodecs.Id Api.Object.CurrentNetworks
id_ =
    Object.selectionForField "ScalarCodecs.Id" "_id" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecId |> .decoder)


{-| The document's timestamp.
-}
ts_ : SelectionSet Api.ScalarCodecs.Long Api.Object.CurrentNetworks
ts_ =
    Object.selectionForField "ScalarCodecs.Long" "_ts" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecLong |> .decoder)


networkNames : SelectionSet (Maybe (List String)) Api.Object.CurrentNetworks
networkNames =
    Object.selectionForField "(Maybe (List String))" "NetworkNames" [] (Decode.string |> Decode.list |> Decode.nullable)
