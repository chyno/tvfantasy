-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Query exposing (..)

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
import Json.Decode as Decode exposing (Decoder)


type alias AvailableNetworkOptionalArguments =
    { size_ : OptionalArgument Int
    , cursor_ : OptionalArgument String
    }


{-|

  - size\_ - The number of items to return per page.
  - cursor\_ - The pagination cursor.

-}
availableNetwork : (AvailableNetworkOptionalArguments -> AvailableNetworkOptionalArguments) -> SelectionSet decodesTo Api.Object.AvailableNetworkPage -> SelectionSet decodesTo RootQuery
availableNetwork fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { size_ = Absent, cursor_ = Absent }

        optionalArgs =
            [ Argument.optional "_size" filledInOptionals.size_ Encode.int, Argument.optional "_cursor" filledInOptionals.cursor_ Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "availableNetwork" optionalArgs object_ identity


type alias UserByUserNameRequiredArguments =
    { username : Api.ScalarCodecs.Id }


userByUserName : UserByUserNameRequiredArguments -> SelectionSet decodesTo Api.Object.User -> SelectionSet (Maybe decodesTo) RootQuery
userByUserName requiredArgs object_ =
    Object.selectionForCompositeField "userByUserName" [ Argument.required "username" requiredArgs.username (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias FindAvailableNetworkByIDRequiredArguments =
    { id : Api.ScalarCodecs.Id }


{-| Find a document from the collection of 'AvailableNetwork' by its id.

  - id - The 'AvailableNetwork' document's ID

-}
findAvailableNetworkByID : FindAvailableNetworkByIDRequiredArguments -> SelectionSet decodesTo Api.Object.AvailableNetwork -> SelectionSet (Maybe decodesTo) RootQuery
findAvailableNetworkByID requiredArgs object_ =
    Object.selectionForCompositeField "findAvailableNetworkByID" [ Argument.required "id" requiredArgs.id (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias AllUsersOptionalArguments =
    { size_ : OptionalArgument Int
    , cursor_ : OptionalArgument String
    }


{-|

  - size\_ - The number of items to return per page.
  - cursor\_ - The pagination cursor.

-}
allUsers : (AllUsersOptionalArguments -> AllUsersOptionalArguments) -> SelectionSet decodesTo Api.Object.UserPage -> SelectionSet decodesTo RootQuery
allUsers fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { size_ = Absent, cursor_ = Absent }

        optionalArgs =
            [ Argument.optional "_size" filledInOptionals.size_ Encode.int, Argument.optional "_cursor" filledInOptionals.cursor_ Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "allUsers" optionalArgs object_ identity


type alias FindUserByIDRequiredArguments =
    { id : Api.ScalarCodecs.Id }


{-| Find a document from the collection of 'User' by its id.

  - id - The 'User' document's ID

-}
findUserByID : FindUserByIDRequiredArguments -> SelectionSet decodesTo Api.Object.User -> SelectionSet (Maybe decodesTo) RootQuery
findUserByID requiredArgs object_ =
    Object.selectionForCompositeField "findUserByID" [ Argument.required "id" requiredArgs.id (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)
