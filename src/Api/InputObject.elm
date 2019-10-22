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


buildGameInput : GameInputRequiredFields -> (GameInputOptionalFields -> GameInputOptionalFields) -> GameInput
buildGameInput required fillOptionals =
    let
        optionals =
            fillOptionals
                { user = Absent, shows = Absent }
    in
    GameInput { user = optionals.user, network = required.network, amount = required.amount, start = required.start, end = required.end, shows = optionals.shows }


type alias GameInputRequiredFields =
    { network : String
    , amount : Int
    , start : Api.ScalarCodecs.Date
    , end : Api.ScalarCodecs.Date
    }


type alias GameInputOptionalFields =
    { user : OptionalArgument GameUserRelation
    , shows : OptionalArgument GameShowsRelation
    }


{-| Type alias for the `GameInput` attributes. Note that this type
needs to use the `GameInput` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias GameInputRaw =
    { user : OptionalArgument GameUserRelation
    , network : String
    , amount : Int
    , start : Api.ScalarCodecs.Date
    , end : Api.ScalarCodecs.Date
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
        [ ( "user", encodeGameUserRelation |> Encode.optional input.user ), ( "network", Encode.string input.network |> Just ), ( "amount", Encode.int input.amount |> Just ), ( "start", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecDate) input.start |> Just ), ( "end", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecDate) input.end |> Just ), ( "shows", encodeGameShowsRelation |> Encode.optional input.shows ) ]


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
                { create = Absent, connect = Absent }
    in
    GameUserRelation { create = optionals.create, connect = optionals.connect }


type alias GameUserRelationOptionalFields =
    { create : OptionalArgument UserInput
    , connect : OptionalArgument Api.ScalarCodecs.Id
    }


{-| Type alias for the `GameUserRelation` attributes. Note that this type
needs to use the `GameUserRelation` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias GameUserRelationRaw =
    { create : OptionalArgument UserInput
    , connect : OptionalArgument Api.ScalarCodecs.Id
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
        [ ( "create", encodeUserInput |> Encode.optional input.create ), ( "connect", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.optional input.connect ) ]


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
                { game = Absent }
    in
    ShowInput { game = optionals.game, name = required.name, rating = required.rating, description = required.description }


type alias ShowInputRequiredFields =
    { name : String
    , rating : Int
    , description : String
    }


type alias ShowInputOptionalFields =
    { game : OptionalArgument ShowGameRelation }


{-| Type alias for the `ShowInput` attributes. Note that this type
needs to use the `ShowInput` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias ShowInputRaw =
    { game : OptionalArgument ShowGameRelation
    , name : String
    , rating : Int
    , description : String
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
        [ ( "game", encodeShowGameRelation |> Encode.optional input.game ), ( "name", Encode.string input.name |> Just ), ( "rating", Encode.int input.rating |> Just ), ( "description", Encode.string input.description |> Just ) ]


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
                { id = Absent, games = Absent }
    in
    UserInput { id = optionals.id, username = required.username, walletAddress = required.walletAddress, games = optionals.games }


type alias UserInputRequiredFields =
    { username : String
    , walletAddress : String
    }


type alias UserInputOptionalFields =
    { id : OptionalArgument Api.ScalarCodecs.Id
    , games : OptionalArgument UserGamesRelation
    }


{-| Type alias for the `UserInput` attributes. Note that this type
needs to use the `UserInput` type (not just a plain type alias) because it has
references to itself either directly (recursive) or indirectly (circular). See
<https://github.com/dillonkearns/elm-graphql/issues/33>.
-}
type alias UserInputRaw =
    { id : OptionalArgument Api.ScalarCodecs.Id
    , username : String
    , walletAddress : String
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
        [ ( "id", (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) |> Encode.optional input.id ), ( "username", Encode.string input.username |> Just ), ( "walletAddress", Encode.string input.walletAddress |> Just ), ( "games", encodeUserGamesRelation |> Encode.optional input.games ) ]
