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


buildGameInput : (GameInputOptionalFields -> GameInputOptionalFields) -> GameInput
buildGameInput fillOptionals =
    let
        optionals =
            fillOptionals
                { user = Absent, network = Absent, amount = Absent, start = Absent, end = Absent, shows = Absent }
    in
    GameInput { user = optionals.user, network = optionals.network, amount = optionals.amount, start = optionals.start, end = optionals.end, shows = optionals.shows }


type alias GameInputOptionalFields =
    { user : OptionalArgument GameUserRelation
    , network : OptionalArgument String
    , amount : OptionalArgument Int
    , start : OptionalArgument Api.ScalarCodecs.Date
    , end : OptionalArgument Api.ScalarCodecs.Date
    , shows : OptionalArgument GameShowsRelation
    }


{-| Type alias for the `GameInput` attributes. Note that this type
needs to use the `GameInput` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias GameInputRaw =
    { user : OptionalArgument GameUserRelation
    , network : OptionalArgument String
    , amount : OptionalArgument Int
    , start : OptionalArgument Api.ScalarCodecs.Date
    , end : OptionalArgument Api.ScalarCodecs.Date
    , shows : OptionalArgument GameShowsRelation
    }


{-| Type for the GameInput input object.
-}
type GameInput
    = GameInput GameInputRaw


{-| Encode a GameInput into a value that can be used as an argument.
-}
encodeGameInput : GameInput -> Value
encodeGameInput (GameInput input) =
    Encode.maybeObject
        [ ( "user", encodeGameUserRelation |> Encode.optional input.user ), ( "network", Encode.string |> Encode.optional input.network ), ( "amount", Encode.int |> Encode.optional input.amount ), ( "start", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecDate) |> Encode.optional input.start ), ( "end", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecDate) |> Encode.optional input.end ), ( "shows", encodeGameShowsRelation |> Encode.optional input.shows ) ]


buildGameShowsRelation : (GameShowsRelationOptionalFields -> GameShowsRelationOptionalFields) -> GameShowsRelation
buildGameShowsRelation fillOptionals =
    let
        optionals =
            fillOptionals
                { create = Absent, connect = Absent, disconnect = Absent }
    in
    GameShowsRelation { create = optionals.create, connect = optionals.connect, disconnect = optionals.disconnect }


type alias GameShowsRelationOptionalFields =
    { create : OptionalArgument (List (Maybe ShowInput))
    , connect : OptionalArgument (List (Maybe Api.ScalarCodecs.Id))
    , disconnect : OptionalArgument (List (Maybe Api.ScalarCodecs.Id))
    }


{-| Type alias for the `GameShowsRelation` attributes. Note that this type
needs to use the `GameShowsRelation` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias GameShowsRelationRaw =
    { create : OptionalArgument (List (Maybe ShowInput))
    , connect : OptionalArgument (List (Maybe Api.ScalarCodecs.Id))
    , disconnect : OptionalArgument (List (Maybe Api.ScalarCodecs.Id))
    }


{-| Type for the GameShowsRelation input object.
-}
type GameShowsRelation
    = GameShowsRelation GameShowsRelationRaw


{-| Encode a GameShowsRelation into a value that can be used as an argument.
-}
encodeGameShowsRelation : GameShowsRelation -> Value
encodeGameShowsRelation (GameShowsRelation input) =
    Encode.maybeObject
        [ ( "create", (encodeShowInput |> Encode.maybe |> Encode.list) |> Encode.optional input.create ), ( "connect", ((Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.maybe |> Encode.list) |> Encode.optional input.connect ), ( "disconnect", ((Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.maybe |> Encode.list) |> Encode.optional input.disconnect ) ]


buildGameUserRelation : (GameUserRelationOptionalFields -> GameUserRelationOptionalFields) -> GameUserRelation
buildGameUserRelation fillOptionals =
    let
        optionals =
            fillOptionals
                { create = Absent, connect = Absent, disconnect = Absent }
    in
    GameUserRelation { create = optionals.create, connect = optionals.connect, disconnect = optionals.disconnect }


type alias GameUserRelationOptionalFields =
    { create : OptionalArgument UserInput
    , connect : OptionalArgument Api.ScalarCodecs.Id
    , disconnect : OptionalArgument Bool
    }


{-| Type alias for the `GameUserRelation` attributes. Note that this type
needs to use the `GameUserRelation` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias GameUserRelationRaw =
    { create : OptionalArgument UserInput
    , connect : OptionalArgument Api.ScalarCodecs.Id
    , disconnect : OptionalArgument Bool
    }


{-| Type for the GameUserRelation input object.
-}
type GameUserRelation
    = GameUserRelation GameUserRelationRaw


{-| Encode a GameUserRelation into a value that can be used as an argument.
-}
encodeGameUserRelation : GameUserRelation -> Value
encodeGameUserRelation (GameUserRelation input) =
    Encode.maybeObject
        [ ( "create", encodeUserInput |> Encode.optional input.create ), ( "connect", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.optional input.connect ), ( "disconnect", Encode.bool |> Encode.optional input.disconnect ) ]


buildShowGameRelation : (ShowGameRelationOptionalFields -> ShowGameRelationOptionalFields) -> ShowGameRelation
buildShowGameRelation fillOptionals =
    let
        optionals =
            fillOptionals
                { create = Absent, connect = Absent }
    in
    ShowGameRelation { create = optionals.create, connect = optionals.connect }


type alias ShowGameRelationOptionalFields =
    { create : OptionalArgument GameInput
    , connect : OptionalArgument Api.ScalarCodecs.Id
    }


{-| Type alias for the `ShowGameRelation` attributes. Note that this type
needs to use the `ShowGameRelation` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias ShowGameRelationRaw =
    { create : OptionalArgument GameInput
    , connect : OptionalArgument Api.ScalarCodecs.Id
    }


{-| Type for the ShowGameRelation input object.
-}
type ShowGameRelation
    = ShowGameRelation ShowGameRelationRaw


{-| Encode a ShowGameRelation into a value that can be used as an argument.
-}
encodeShowGameRelation : ShowGameRelation -> Value
encodeShowGameRelation (ShowGameRelation input) =
    Encode.maybeObject
        [ ( "create", encodeGameInput |> Encode.optional input.create ), ( "connect", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.optional input.connect ) ]


buildShowInput : ShowInputRequiredFields -> (ShowInputOptionalFields -> ShowInputOptionalFields) -> ShowInput
buildShowInput required fillOptionals =
    let
        optionals =
            fillOptionals
                { game = Absent, rating = Absent, description = Absent }
    in
    ShowInput { game = optionals.game, name = required.name, rating = optionals.rating, description = optionals.description }


type alias ShowInputRequiredFields =
    { name : String }


type alias ShowInputOptionalFields =
    { game : OptionalArgument ShowGameRelation
    , rating : OptionalArgument Int
    , description : OptionalArgument String
    }


{-| Type alias for the `ShowInput` attributes. Note that this type
needs to use the `ShowInput` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias ShowInputRaw =
    { game : OptionalArgument ShowGameRelation
    , name : String
    , rating : OptionalArgument Int
    , description : OptionalArgument String
    }


{-| Type for the ShowInput input object.
-}
type ShowInput
    = ShowInput ShowInputRaw


{-| Encode a ShowInput into a value that can be used as an argument.
-}
encodeShowInput : ShowInput -> Value
encodeShowInput (ShowInput input) =
    Encode.maybeObject
        [ ( "game", encodeShowGameRelation |> Encode.optional input.game ), ( "name", Encode.string input.name |> Just ), ( "rating", Encode.int |> Encode.optional input.rating ), ( "description", Encode.string |> Encode.optional input.description ) ]


buildUserGamesRelation : (UserGamesRelationOptionalFields -> UserGamesRelationOptionalFields) -> UserGamesRelation
buildUserGamesRelation fillOptionals =
    let
        optionals =
            fillOptionals
                { create = Absent, connect = Absent, disconnect = Absent }
    in
    UserGamesRelation { create = optionals.create, connect = optionals.connect, disconnect = optionals.disconnect }


type alias UserGamesRelationOptionalFields =
    { create : OptionalArgument (List (Maybe GameInput))
    , connect : OptionalArgument (List (Maybe Api.ScalarCodecs.Id))
    , disconnect : OptionalArgument (List (Maybe Api.ScalarCodecs.Id))
    }


{-| Type alias for the `UserGamesRelation` attributes. Note that this type
needs to use the `UserGamesRelation` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias UserGamesRelationRaw =
    { create : OptionalArgument (List (Maybe GameInput))
    , connect : OptionalArgument (List (Maybe Api.ScalarCodecs.Id))
    , disconnect : OptionalArgument (List (Maybe Api.ScalarCodecs.Id))
    }


{-| Type for the UserGamesRelation input object.
-}
type UserGamesRelation
    = UserGamesRelation UserGamesRelationRaw


{-| Encode a UserGamesRelation into a value that can be used as an argument.
-}
encodeUserGamesRelation : UserGamesRelation -> Value
encodeUserGamesRelation (UserGamesRelation input) =
    Encode.maybeObject
        [ ( "create", (encodeGameInput |> Encode.maybe |> Encode.list) |> Encode.optional input.create ), ( "connect", ((Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.maybe |> Encode.list) |> Encode.optional input.connect ), ( "disconnect", ((Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.maybe |> Encode.list) |> Encode.optional input.disconnect ) ]


buildUserInput : UserInputRequiredFields -> (UserInputOptionalFields -> UserInputOptionalFields) -> UserInput
buildUserInput required fillOptionals =
    let
        optionals =
            fillOptionals
                { address = Absent, networks = Absent, games = Absent }
    in
    UserInput { username = required.username, address = optionals.address, networks = optionals.networks, games = optionals.games }


type alias UserInputRequiredFields =
    { username : Api.ScalarCodecs.Id }


type alias UserInputOptionalFields =
    { address : OptionalArgument String
    , networks : OptionalArgument (List (Maybe String))
    , games : OptionalArgument UserGamesRelation
    }


{-| Type alias for the `UserInput` attributes. Note that this type
needs to use the `UserInput` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias UserInputRaw =
    { username : Api.ScalarCodecs.Id
    , address : OptionalArgument String
    , networks : OptionalArgument (List (Maybe String))
    , games : OptionalArgument UserGamesRelation
    }


{-| Type for the UserInput input object.
-}
type UserInput
    = UserInput UserInputRaw


{-| Encode a UserInput into a value that can be used as an argument.
-}
encodeUserInput : UserInput -> Value
encodeUserInput (UserInput input) =
    Encode.maybeObject
        [ ( "username", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) input.username |> Just ), ( "address", Encode.string |> Encode.optional input.address ), ( "networks", (Encode.string |> Encode.maybe |> Encode.list) |> Encode.optional input.networks ), ( "games", encodeUserGamesRelation |> Encode.optional input.games ) ]
