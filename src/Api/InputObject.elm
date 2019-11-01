-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.InputObject exposing (..)

import Api.Interface
import Api.Object
import Api.Scalar
import Api.ScalarCodecs
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


buildAvailableNetworkInput : AvailableNetworkInputRequiredFields -> AvailableNetworkInput
buildAvailableNetworkInput required =
    { name = required.name, rating = required.rating, description = required.description }


type alias AvailableNetworkInputRequiredFields =
    { name : String
    , rating : Int
    , description : String
    }


{-| Type for the AvailableNetworkInput input object.
-}
type alias AvailableNetworkInput =
    { name : String
    , rating : Int
    , description : String
    }


{-| Encode a AvailableNetworkInput into a value that can be used as an argument.
-}
encodeAvailableNetworkInput : AvailableNetworkInput -> Value
encodeAvailableNetworkInput input =
    Encode.maybeObject
        [ ( "name", Encode.string input.name |> Just ), ( "rating", Encode.int input.rating |> Just ), ( "description", Encode.string input.description |> Just ) ]


buildAvalableShowInput : AvalableShowInputRequiredFields -> AvalableShowInput
buildAvalableShowInput required =
    { name = required.name, rating = required.rating, description = required.description }


type alias AvalableShowInputRequiredFields =
    { name : String
    , rating : Int
    , description : String
    }


{-| Type for the AvalableShowInput input object.
-}
type alias AvalableShowInput =
    { name : String
    , rating : Int
    , description : String
    }


{-| Encode a AvalableShowInput into a value that can be used as an argument.
-}
encodeAvalableShowInput : AvalableShowInput -> Value
encodeAvalableShowInput input =
    Encode.maybeObject
        [ ( "name", Encode.string input.name |> Just ), ( "rating", Encode.int input.rating |> Just ), ( "description", Encode.string input.description |> Just ) ]


buildCurrentNetworksInput : (CurrentNetworksInputOptionalFields -> CurrentNetworksInputOptionalFields) -> CurrentNetworksInput
buildCurrentNetworksInput fillOptionals =
    let
        optionals =
            fillOptionals
                { networkNames = Absent }
    in
    { networkNames = optionals.networkNames }


type alias CurrentNetworksInputOptionalFields =
    { networkNames : OptionalArgument (List String) }


{-| Type for the CurrentNetworksInput input object.
-}
type alias CurrentNetworksInput =
    { networkNames : OptionalArgument (List String) }


{-| Encode a CurrentNetworksInput into a value that can be used as an argument.
-}
encodeCurrentNetworksInput : CurrentNetworksInput -> Value
encodeCurrentNetworksInput input =
    Encode.maybeObject
        [ ( "NetworkNames", (Encode.string |> Encode.list) |> Encode.optional input.networkNames ) ]


buildGameInput : GameInputRequiredFields -> (GameInputOptionalFields -> GameInputOptionalFields) -> GameInput
buildGameInput required fillOptionals =
    let
        optionals =
            fillOptionals
                { network = Absent, amount = Absent, start = Absent, end = Absent, shows = Absent }
    in
    { userName = required.userName, network = optionals.network, amount = optionals.amount, start = optionals.start, end = optionals.end, shows = optionals.shows }


type alias GameInputRequiredFields =
    { userName : Api.ScalarCodecs.Id }


type alias GameInputOptionalFields =
    { network : OptionalArgument String
    , amount : OptionalArgument Int
    , start : OptionalArgument Api.ScalarCodecs.Date
    , end : OptionalArgument Api.ScalarCodecs.Date
    , shows : OptionalArgument (List ShowInput)
    }


{-| Type for the GameInput input object.
-}
type alias GameInput =
    { userName : Api.ScalarCodecs.Id
    , network : OptionalArgument String
    , amount : OptionalArgument Int
    , start : OptionalArgument Api.ScalarCodecs.Date
    , end : OptionalArgument Api.ScalarCodecs.Date
    , shows : OptionalArgument (List ShowInput)
    }


{-| Encode a GameInput into a value that can be used as an argument.
-}
encodeGameInput : GameInput -> Value
encodeGameInput input =
    Encode.maybeObject
        [ ( "userName", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) input.userName |> Just ), ( "network", Encode.string |> Encode.optional input.network ), ( "amount", Encode.int |> Encode.optional input.amount ), ( "start", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecDate) |> Encode.optional input.start ), ( "end", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecDate) |> Encode.optional input.end ), ( "shows", (encodeShowInput |> Encode.list) |> Encode.optional input.shows ) ]


buildShowGameRelation : (ShowGameRelationOptionalFields -> ShowGameRelationOptionalFields) -> ShowGameRelation
buildShowGameRelation fillOptionals =
    let
        optionals =
            fillOptionals
                { create = Absent, connect = Absent }
    in
    { create = optionals.create, connect = optionals.connect }


type alias ShowGameRelationOptionalFields =
    { create : OptionalArgument GameInput
    , connect : OptionalArgument Api.ScalarCodecs.Id
    }


{-| Type for the ShowGameRelation input object.
-}
type alias ShowGameRelation =
    { create : OptionalArgument GameInput
    , connect : OptionalArgument Api.ScalarCodecs.Id
    }


{-| Encode a ShowGameRelation into a value that can be used as an argument.
-}
encodeShowGameRelation : ShowGameRelation -> Value
encodeShowGameRelation input =
    Encode.maybeObject
        [ ( "create", encodeGameInput |> Encode.optional input.create ), ( "connect", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.optional input.connect ) ]


buildShowInput : ShowInputRequiredFields -> ShowInput
buildShowInput required =
    { game = required.game, name = required.name, rating = required.rating, description = required.description }


type alias ShowInputRequiredFields =
    { game : Api.ScalarCodecs.Id
    , name : String
    , rating : Int
    , description : String
    }


{-| Type for the ShowInput input object.
-}
type alias ShowInput =
    { game : Api.ScalarCodecs.Id
    , name : String
    , rating : Int
    , description : String
    }


{-| Encode a ShowInput into a value that can be used as an argument.
-}
encodeShowInput : ShowInput -> Value
encodeShowInput input =
    Encode.maybeObject
        [ ( "game", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) input.game |> Just ), ( "name", Encode.string input.name |> Just ), ( "rating", Encode.int input.rating |> Just ), ( "description", Encode.string input.description |> Just ) ]


buildUserInput : UserInputRequiredFields -> (UserInputOptionalFields -> UserInputOptionalFields) -> UserInput
buildUserInput required fillOptionals =
    let
        optionals =
            fillOptionals
                { id = Absent, games = Absent }
    in
    { id = optionals.id, username = required.username, walletAddress = required.walletAddress, games = optionals.games }


type alias UserInputRequiredFields =
    { username : String
    , walletAddress : String
    }


type alias UserInputOptionalFields =
    { id : OptionalArgument Api.ScalarCodecs.Id
    , games : OptionalArgument (List Api.ScalarCodecs.Id)
    }


{-| Type for the UserInput input object.
-}
type alias UserInput =
    { id : OptionalArgument Api.ScalarCodecs.Id
    , username : String
    , walletAddress : String
    , games : OptionalArgument (List Api.ScalarCodecs.Id)
    }


{-| Encode a UserInput into a value that can be used as an argument.
-}
encodeUserInput : UserInput -> Value
encodeUserInput input =
    Encode.maybeObject
        [ ( "id", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.optional input.id ), ( "username", Encode.string input.username |> Just ), ( "walletAddress", Encode.string input.walletAddress |> Just ), ( "games", ((Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.list) |> Encode.optional input.games ) ]
