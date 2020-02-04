module TvApi exposing (userSelection, GameQueryResponse, Response, gameSelection)

import Shared exposing (GameInfo, UserInfo)
import Api.Object
import Api.Object.Game as Game
import Api.Object.GamePage as GamePage
import Api.Object.User as User
import Api.Scalar exposing (Id(..))
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)
import Graphql.Http exposing (Error)
import Api.Scalar exposing (defaultCodecs)
import Json.Decode as  Decode
import Json.Decode exposing (Error)

type alias GameData =
    { data : List (Maybe GameInfo)
    }


gameDataParser : GameData -> List GameInfo
gameDataParser ndata =
    List.foldr foldrValues [] ndata.data


foldrValues : Maybe a -> List a -> List a
foldrValues item list =
    case item of
        Nothing ->
            list

        Just v ->
            v :: list


fillArgs : User.GamesOptionalArguments -> User.GamesOptionalArguments
fillArgs x =
    x


userSelection : SelectionSet UserInfo Api.Object.User
userSelection =
    SelectionSet.map3 UserInfo
        User.userName
        User.walletAddress
        (User.games fillArgs gamePageSelection |> SelectionSet.map gameDataParser)



gamePageSelection : SelectionSet GameData Api.Object.GamePage
gamePageSelection =
    SelectionSet.map GameData
        (GamePage.data gameSelection)


gameSelection : SelectionSet GameInfo Api.Object.Game
gameSelection =
    SelectionSet.map5 GameInfo
        Game.gameName
        Game.walletAmount
        Game.networkName
        Game.networkDescription
        (SelectionSet.map fromId  Game.id_)

-- Result Decode.Error String
fromId: Id -> String
fromId idVal =
    let 
        encval = defaultCodecs.codecId.encoder idVal |>
                 Decode.decodeValue Decode.string
    in
        case encval of
            (Ok val) ->
                val
            Err err->
                case err of
                    Decode.Field errMessage cholderr ->
                        errMessage
                    _ ->
                        "Some unhandled error occured"

 
type alias Response =
    Maybe UserInfo

type alias GameQueryResponse =
    RemoteData (Graphql.Http.Error Response) Response


-- (Result (Error decodesTo) decodesTo -> msg) -> Request decodesTo -> Cmd msg

