module Shared exposing (Flags, RemoteDataMsg(..), mapRemoteData, toString)
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
            List.map (\a  -> a.message) errors |>
                List.foldl (\ x acc -> (acc   ++ ", [ " ++ x ++ " ]")) "" 
            