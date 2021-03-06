module Shared exposing (Flags, GameInfo, NetworkInfo, RemoteDataMsg(..), ShowInfo, UserInfo, faunaAuth, faunaEndpoint, mapRemoteData, toString)

import Date exposing (Date)
import Graphql.Http exposing (..)
import Graphql.Http.GraphqlError as GraphqlError exposing (..)
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument exposing (..)
import Graphql.SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)


type alias Flags =
    { api : String
    }


type RemoteDataMsg a
    = NotAsked
    | Loading
    | Loaded a
    | Failure


mapRemoteData : (a -> b) -> RemoteDataMsg a -> RemoteDataMsg b
mapRemoteData fn remoteData =
    case remoteData of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Loaded data ->
            Loaded (fn data)

        Failure ->
            Failure



--  https://package.elm-lang.org/packages/dillonkearns/elm-graphql/latest/Graphql-Http#Error


toString : Graphql.Http.Error a -> String
toString err =
    case err of
        Graphql.Http.HttpError httpError ->
            case httpError of
                BadUrl url ->
                    "Bad Url"

                Timeout ->
                    "Timeout"

                NetworkError ->
                    "Netwqork Error"

                BadStatus dt val ->
                    "Bad Status"

                BadPayload err2 ->
                    "Bad Payload "

        Graphql.Http.GraphqlError parsedData errors ->
            let
                errorMessages =
                    List.map (\a -> a.message) errors
                        |> List.foldl (\x acc -> acc ++ ", [ " ++ x ++ " ]") ""
            in
            case parsedData of
                ParsedData prs ->
                    errorMessages ++ ". Has Parsed data."

                UnparsedData value ->
                    errorMessages ++ ". Has Unparsed data."



-- Shared data
-- { #description# : String
--                 , #name# : String
--                 , #rating# : Int
--                 , #shows# : List ShowInfo
--                 }


type alias GameInfo =
    { gameName : String
    , walletAmount : Maybe Int
    , networkName : String
    , networkDescription : String
    , id :  Maybe String
    , shows : List ShowInfo
    }


type alias ShowInfo =
    { name : String
    , rating : Int
    , description : String
    , id : String
    }


type alias NetworkInfo =
    { name : String
    , rating : Int
    , description : String
    , shows : List ShowInfo
    }


type alias UserInfo =
    { 
    id :  String
    , userName : String
    , walletAddress : String
    , games : List GameInfo
    }


faunaEndpoint : String
faunaEndpoint =
    "https://graphql.fauna.com/graphql"


faunaAuth : String
faunaAuth =
    "Basic Zm5BRGtRVnpDZkFDRXNFYWp1b2E1YzlSYnNGSU5BWkF5akpxSWVuOTo="



-- fnADjxgmCnACEtcVYQpT4hYzOwJB7iJBhV86zdb9
