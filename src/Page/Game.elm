module Page.Game exposing (Model, Msg(.. ), init, subscriptions, update, view)
import Html exposing (..)
import GameApi exposing(queryUserInfo)
import  Shared exposing  (ShowInfo, NetworkInfo, UserInfo)
import RemoteData exposing (RemoteData)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.Document as Document
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)


type Msg =  GotUserInfoResponse (RemoteData (Graphql.Http.Error (Maybe UserInfo)) (Maybe UserInfo))


-- type Problem = Problem String

type Model =    Loading String
                | LoadingProblem String
                | Success LoadedModel 
                | Details LoadedModel

type alias LoadedModel =
    {
         currentShows: List String
        , walletAddress :  String
        , amount : Maybe Int
        , networks:  List NetworkInfo
        , selectedNetwork:  Maybe NetworkInfo
       
    }


init : String  -> ( Model, Cmd Msg )
init username = 
    (Loading username, makeUserInfoRequest username )

makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest username =
    queryUserInfo username
        |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
        |> Graphql.Http.withHeader "Authorization" ("Bearer fnADbMd3RLACEpjT90hoJSn6SXhN281PIgIZg375" )
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)


-- Subcriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUserInfoResponse response ->
            case response of
                RemoteData.Loading ->
                    (Loading "loading..." , Cmd.none)
                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            -- TODOE: get networks
                            (
                                Success {
                                     walletAddress = data.walletAddress
                                    , amount = data.amount
                                    , networks = []
                                    , selectedNetwork = Nothing
                                    , currentShows = [] 
    
                                }
                            , Cmd.none)                            
                        Nothing ->
                            (LoadingProblem  "Can not get data", Cmd.none)
                RemoteData.Failure err ->
                    (LoadingProblem  "err", Cmd.none)
                RemoteData.NotAsked ->
                    (LoadingProblem  "Not Asked", Cmd.none)
            
-- View
view : Model -> Html Msg
view model =  
    div[][]



