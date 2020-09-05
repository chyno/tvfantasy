module TvApi exposing (GameQueryResponse, Response, gameSelection, showSelection, userSelection)

import Api.Object
import Api.Object.Game as Game
import Api.Object.GamePage as GamePage
import Api.Object.Show as Show
import Api.Object.ShowPage as ShowPage
import Api.Object.User as User
import Api.Scalar exposing (Id(..), defaultCodecs)
import Graphql.Http exposing (Error)
import Graphql.OptionalArgument exposing (..)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Error)
import RemoteData exposing (RemoteData)
import Shared exposing (GameInfo, ShowInfo, UserInfo)


type alias GameData =
    { data : List (Maybe GameInfo)
    }


type alias ShowIdInfo =
    { id : String
    }


type alias ShowData =
    { data : List (Maybe ShowInfo)
    }


showDataParser : ShowData -> List ShowInfo
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
    SelectionSet.map4 UserInfo
        (SelectionSet.map fromId User.id_)
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
        (SelectionSet.map fromId Show.id_)



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
        (SelectionSet.map fromIdTOMaybeString Game.id_)
        (Game.shows fillShowArgs showPageSelection |> SelectionSet.map showDataParser)



-- (Game.ShowsOptionalArguments -> Game.ShowsOptionalArguments) -> SelectionSet decodesTo Api.Object.ShowPage  -> SelectionSet decodesTo Api.Object.Game


fromId : Id -> String
fromId idVal =
    let
        encval =
            defaultCodecs.codecId.encoder idVal
                |> Decode.decodeValue Decode.string
    in
    case encval of
        Ok val ->
            val

        Err err ->
            case err of
                Decode.Field errMessage cholderr ->
                    errMessage

                _ ->
                    "Some unhandled error occured"

fromIdTOMaybeString : Id -> Maybe String
fromIdTOMaybeString idVal =
    let
        encval =
            defaultCodecs.codecId.encoder idVal
                |> Decode.decodeValue Decode.string
    in
    case encval of
        Ok val ->
            Just val

        Err err ->
            case err of
                Decode.Field errMessage cholderr ->
                    Nothing

                _ ->
                    Nothing



type alias Response =
    Maybe UserInfo




type alias GameQueryResponse =
    RemoteData (Graphql.Http.Error Response) Response



-- (Result (Error decodesTo) decodesTo -> msg) -> Request decodesTo -> Cmd msg
