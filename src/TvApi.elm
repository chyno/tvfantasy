module TvApi exposing (userSelection, GameQueryResponse, Response, gameSelection)

import Shared exposing (GameInfo, UserInfo, ShowInfo)
import Api.Object
import Api.Object.Game as Game
import Api.Object.Show as Show
import Api.Object.GamePage as GamePage
import Api.Object.ShowPage as ShowPage
import Api.Object.User as User
import Api.Scalar exposing (Id(..))
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)
import Graphql.Http exposing (Error)
import Api.Scalar exposing (defaultCodecs)
import Json.Decode as  Decode
import Json.Decode exposing (Error)
import Graphql.OptionalArgument exposing (..)
type alias GameData =
    { data : List (Maybe GameInfo)
    }
type alias ShowIdInfo = 
    {
        id: String
    }

type alias ShowData =
    { data : List  (Maybe ShowInfo)
    }

showDataParser : ShowData ->  List ShowInfo
showDataParser ndata =
     List.foldr foldrValues [] ndata.data

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


fillGameArgs : User.GamesOptionalArguments -> User.GamesOptionalArguments
fillGameArgs x =
    x

fillShowArgs : Game.ShowsOptionalArguments -> Game.ShowsOptionalArguments
fillShowArgs x =
    x
userSelection : SelectionSet UserInfo Api.Object.User
userSelection =
    SelectionSet.map3 UserInfo
        User.userName
        User.walletAddress
        (User.games fillGameArgs gamePageSelection |> SelectionSet.map gameDataParser)



gamePageSelection : SelectionSet GameData Api.Object.GamePage
gamePageSelection =
    SelectionSet.map GameData
        (GamePage.data gameSelection)

showPageSelection : SelectionSet ShowData Api.Object.ShowPage 
showPageSelection =
    SelectionSet.map ShowData
        (ShowPage.data showSelection)


showSelection : SelectionSet ShowInfo Api.Object.Show 
showSelection =
    SelectionSet.map4 ShowInfo
        Show.showName
        Show.rating
        Show.showDescription
        (SelectionSet.map fromId  Show.id_)

-- showIdSelection : SelectionSet ShowData Api.Object.Show
-- showIdSelection =
--   SelectionSet.map ShowData
--     Show.id_ 

gameSelection : SelectionSet GameInfo Api.Object.Game
gameSelection =
    SelectionSet.map6 GameInfo
        Game.gameName
        Game.walletAmount
        Game.networkName
        Game.networkDescription
        (SelectionSet.map fromId  Game.id_)
        (Game.shows fillShowArgs showPageSelection |> SelectionSet.map showDataParser)


-- (Game.ShowsOptionalArguments -> Game.ShowsOptionalArguments) -> SelectionSet decodesTo Api.Object.ShowPage  -> SelectionSet decodesTo Api.Object.Game

 
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

