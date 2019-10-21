module Shared exposing (Flags, RemoteDataMsg(..), mapRemoteData)


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
