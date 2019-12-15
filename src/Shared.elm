module Shared exposing (Flags, RemoteDataMsg(..), mapRemoteData, toString, ShowInfo, NetworkInfo, UserInfo)
import Graphql.Http.GraphqlError as GraphqlError exposing(..)
import Graphql.Http exposing (..)
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
toString err  =
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
                errorMessages =   List.map (\a  -> a.message) errors |>
                    List.foldl (\ x acc -> (acc   ++ ", [ " ++ x ++ " ]")) "" 
            in
            case parsedData of
                ParsedData prs ->
                    errorMessages ++ ". Has Parsed data."
                UnparsedData value ->
                    errorMessages ++ ". Has Unparsed data."
                    
                
          
-- Shared data
type alias ShowInfo =
    {
        name: String
        , rating: Int
        , description: String
    }

type alias NetworkInfo = 
    {
        name: String
        , rating: Int
        , description: String 
        , shows: List ShowInfo
    }

type alias UserInfo =
    { 
        walletAddress :  String
        , amount : Maybe Int
        , networks:  List (Maybe NetworkInfo)
       
    }

