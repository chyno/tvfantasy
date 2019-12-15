module GameApi exposing (queryUserInfo)

import  Shared exposing  (ShowInfo, NetworkInfo, UserInfo)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.Document as Document
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
-- import Api.Object.User as User
import RemoteData exposing (RemoteData)
import Api.Object
import Api.Object.User as User
import Api.Object.Network as Network
import Api.Object.NetworkPage as NetworkPage
import Api.Object.Show as Show
import Api.Object.ShowPage as ShowPage
import Api.Object.NetworkPage as NetworkPage
import Api.Query as Query
import Api.Scalar
import Api.Scalar exposing (Id(..))


-- Graph QL
type alias NetworkData =
    {
       data : List (Maybe NetworkInfo)
    }

type alias ShowData =
    {
       data : List (Maybe ShowInfo)
    }

showPageSelection : SelectionSet ShowData Api.Object.ShowPage
showPageSelection =
    SelectionSet.map ShowData
        (ShowPage.data showSelection)

showSelection : SelectionSet ShowInfo Api.Object.Show
showSelection =
    SelectionSet.map3 ShowInfo
        Show.name
        Show.rating
        Show.description


showDataParser : ShowData -> List ShowInfo
showDataParser sdata = 
    sdata.data |> values


networkDataParser : NetworkData -> (List (Maybe NetworkInfo))
networkDataParser ndata = 
    ndata.data

networkSelection : SelectionSet NetworkInfo Api.Object.Network
networkSelection =
    SelectionSet.map4 NetworkInfo
        Network.name
        Network.rating
        Network.description
        ((Network.shows fillArgs showPageSelection) |> SelectionSet.map showDataParser)
        -- ((User.networks fillArgs networkPageSelection) |> SelectionSet.map networkDataParser)
        -- (SelectionSet.succeed emptyShow)
 

networkPageSelection : SelectionSet NetworkData Api.Object.NetworkPage
networkPageSelection =
    SelectionSet.map NetworkData
        (NetworkPage.data networkSelection)


userSelection : SelectionSet UserInfo Api.Object.User
userSelection =
    SelectionSet.map3 UserInfo
        User.walletAddress
        User.amount
        ((User.networks fillArgs networkPageSelection) |> SelectionSet.map networkDataParser)
   

-- User Info Query
queryUserInfo : String ->  SelectionSet (Maybe UserInfo) RootQuery
queryUserInfo un =
    Query.userByUserName { username = Id un } userSelection


values : List (Maybe a) -> List a
values =
    List.foldr foldrValues []

fillArgs : Network.ShowsOptionalArguments -> Network.ShowsOptionalArguments
fillArgs x = x 

foldrValues : Maybe a -> List a -> List a
foldrValues item list =
    case item of
        Nothing ->
            list

        Just v ->
            v :: list

