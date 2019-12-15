module Page.Game exposing (Model, Msg(.. ), init, subscriptions, update, view)
import Html exposing (..)

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


type Msg =  GotUserInfoResponse (RemoteData (Graphql.Http.Error (Maybe UserInfo)) (Maybe UserInfo))


type Problem = Problem String

type Model =    Loading String
                | LoadingProblem Problem
                | Success LoadedModel 
                | Details LoadedModel


type alias LoadedModel =
    {
        message: Maybe String
        , currentShows: List String
        , walletAddress :  String
        , amount : Maybe Int
        , networks:  List NetworkInfo
        , selectedNetwork:  String
        , problem: Maybe Problem
       
    }

type alias UserInfo =
    { 
        walletAddress :  String
        , amount : Maybe Int
        , networks:  List (Maybe NetworkInfo)
       
    }

type alias NetworkInfo = 
    {
        name: String
        , rating: Int
        , description: String 
        , shows: List ShowInfo
    }

type alias ShowInfo =
    {
        name: String
        , rating: Int
        , description: String
    }


init : String  -> ( Model, Cmd Msg )
init username = 
    (Loading username, makeUserInfoRequest username )

-- Subcriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    (model, Cmd.none)

-- View
view : Model -> Html Msg
view model =  
    div[][]




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


makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest username =
    queryUserInfo username
        |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
        |> Graphql.Http.withHeader "Authorization" ("Bearer fnADbMd3RLACEpjT90hoJSn6SXhN281PIgIZg375" )
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)

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

