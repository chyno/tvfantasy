port module Page.Game exposing (Model, view, Msg(..), update, subscriptions, init)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Routes exposing (showsPath)
import Shared exposing (..)
import Graphql.Http
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Button as Button
import Bootstrap.ListGroup as ListGroup

import Graphql.Document as Document
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
-- import Api.Object.User as User
import RemoteData exposing (RemoteData)
import Api.Object
import Api.Object.User as User
import Api.Query as Query
import Api.Scalar
import Api.Scalar exposing (Id(..))


-- Model
type alias Show =
    {
        name: String
        , rating: Int
        , description: String
    }

type alias Network = 
    {
        name: String
        , rating: Int
        , description: String 
        , shows: List Show
    }

type alias UserInfo =
    { 
        walletAddress :  String
        , amount : Maybe Int
        , networks:  List Network
       
    }

type alias Model =
    {
        message: Maybe String
        , currentShows: List String
        , walletAddress :  String
        , amount : Maybe Int
        , networks:  List Network
        , selectedNetwork:  String
        
    }



type Msg =     NavigateShows 
                | SelectNetwork
                | NetworkChange String
                | GotUserInfoResponse (RemoteData (Graphql.Http.Error (Maybe UserInfo)) (Maybe UserInfo))
                | ChangeNetwork



initPage: Model
initPage = {
    message = Nothing
    , walletAddress = ""
    , amount = Nothing
    , networks = []
    , selectedNetwork = ""
    ,  currentShows = [] 
    }


init : String  -> ( Model, Cmd Msg )
init username = 
    ( initPage, makeUserInfoRequest username )

               

--Subcriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


--Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of
        ChangeNetwork ->
         ({model | selectedNetwork = "" }, Cmd.none)
        NavigateShows ->
            ({ model | message = Just "navigate shows" }, (Nav.load  Routes.showsPath) )
        SelectNetwork  ->
            (model, Cmd.none)
            --  ({model | network = Just model.selectedNetwork }, Cmd.none)
        NetworkChange netwrk -> 
            ( {model | selectedNetwork =  netwrk }, Cmd.none) 
        GotUserInfoResponse response ->
            case response of
                RemoteData.Loading ->
                    ({ model | message = Just "loading..." }, Cmd.none)
                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            -- TODOE: get networks
                            ({ model | walletAddress =  data.walletAddress, amount = data.amount,  message = Nothing }, Cmd.none)
                            -- ({ model | walletAddress =  data.walletAddress, amount = data.amount, network = Just data.network,  message = Nothing }, Cmd.none)
                        Nothing ->
                            ({ model | message = Just "could not return data", walletAddress =  "", amount = Nothing, networks = [] }, Cmd.none)
                RemoteData.Failure err ->
                    ({ model | message = Just "err" }, Cmd.none)
                RemoteData.NotAsked ->
                    ({ model | message = Just "Not Asked" }, Cmd.none)


-- View
view : Model -> Html Msg
view model =
    let
        msgText = 
                case model.message of
                    Just messg ->
                        messg
                    Nothing ->
                        ""
        ntwrk = "TODO: need to get child info"
        bodyView = viewChooseNetwork
                -- case model.network of
                --     Just val ->
                --         viewNetworkShows val 
                --     Nothing ->
                --         viewChooseNetwork 
    in
        div [] 
        [
            div [][text ("address : "  ++ model.walletAddress)]
            , h3[][text ntwrk]
            , (bodyView model)
            , div[][text msgText]
         ]
        

viewChooseNetwork : Model -> Html Msg
viewChooseNetwork model =
    div[][
        Form.form []
        [   
            Form.group []
            [ Form.label [ for "mynetworks" ] [ text "Avaliable Networks" ]
            , Select.select [ Select.id "mynetworks", Select.onChange NetworkChange ]
                (List.map (\x ->  Select.item [] [ text x ]) ["need to iplment"]) 
                           
            ]
        ]
        ,    
        Button.button [ Button.primary,  Button.onClick SelectNetwork ] [ text "Select" ]
    ]
    
viewNetworkShows : String -> Model -> Html Msg
viewNetworkShows network model = 
    div [] [
        ListGroup.ul
            (List.map (\x ->  ListGroup.li [] [ text x ]) model.currentShows)
        , Button.button [ Button.primary,  Button.onClick NavigateShows ] [ text "Choose Available Shows" ]
        , Button.button [Button.secondary, Button.onClick ChangeNetwork][ text "Change Network"]
    ]


-- User Info Query
queryUserInfo : String ->  SelectionSet (Maybe UserInfo) RootQuery
queryUserInfo un =
    Query.userByUserName { username = Id un } userSelection


--  SelectionSet (List Network) Api.Object.User
emptyNetwork :  List Network
emptyNetwork  = []

type alias Foo = List Network

userSelection : SelectionSet UserInfo Api.Object.User
userSelection =
    SelectionSet.map3 UserInfo
        User.walletAddress
        User.amount
        (SelectionSet.succeed emptyNetwork)
        -- SelectionSet.map emptyNetwork  User.networks
        
        
       

makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest username =
    queryUserInfo username
        |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
        |> Graphql.Http.withHeader "Authorization" ("Bearer fnADbMd3RLACEpjT90hoJSn6SXhN281PIgIZg375" )
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)


-- Helper
stringFragment : SelectionSet (Maybe String) Api.Object.User -> SelectionSet String Api.Object.User
stringFragment userSelectionMaybeVal =
    SelectionSet.map mapToString userSelectionMaybeVal

mapToString : Maybe String -> String
mapToString maybeVal =
    case maybeVal of
        Just val ->
            val
        Nothing ->
            ""
