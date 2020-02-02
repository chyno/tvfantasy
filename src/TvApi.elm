module TvApi exposing (userSelection)

import Shared exposing (GameInfo, UserInfo)
import Api.Object
import Api.Object.Game as Game
import Api.Object.GamePage as GamePage
import Api.Object.User as User
import Api.Scalar exposing (Id(..))
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)

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
    SelectionSet.map4 GameInfo
        Game.gameName
        Game.walletAmount
        Game.networkName
        Game.networkDescription


-- (Result (Error decodesTo) decodesTo -> msg) -> Request decodesTo -> Cmd msg

