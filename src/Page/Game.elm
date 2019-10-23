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
--Model
-- https://github.com/dillonkearns/elm-graphql/blob/master/examples/src/Example01BasicQuery.elm
query : String ->  SelectionSet (Maybe UserInfo) RootQuery
query userId =
    Query.findUserByID { id = Id "246935414112256530" } userSelection

type alias UserInfo =
    { address :  String }

userSelection : SelectionSet UserInfo Api.Object.User
userSelection =
    SelectionSet.map UserInfo
        User.walletAddress


makeRequest : String -> Cmd Msg
makeRequest userId =
    query userId
        |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
        |> Graphql.Http.withHeader "Authorization" ("Bearer fnADbMd3RLACEpjT90hoJSn6SXhN281PIgIZg375" )
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)


type alias CurrentGameModel =
    {
        network:  String
        ,  currentShows: List String
            
    }

type alias Model =
    {
    
        address: String
        , selectedNetwork :  String
        , possibleNetworks: List String
        , currentGame : Maybe CurrentGameModel
    }



initPage: Model
initPage = {
     address = "init page",   possibleNetworks = ["ABC", "NBC", "CBS", "ESPN"], selectedNetwork = "", currentGame = Nothing
    }

getUserId : String -> Cmd Msg
getUserId userName =
    userIdRequest "john123"

init : String  -> ( Model, Cmd Msg )
init userName = 
    ( initPage, getUserId userName )

-- Msg
-- fnADbMd3RLACEpjT90hoJSn6SXhN281PIgIZg375
type Msg =     NavigateShows 
                | SelectNetwork
                | NetworkChange String
                | GotResponse (RemoteData (Graphql.Http.Error (Maybe UserInfo)) (Maybe UserInfo))
                | LoadGameInfo String

--Subcriptions
-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [userIdResult LoadGameInfo]

--Update
valOrEmpty: Maybe String -> String
valOrEmpty maybeVal =
    case maybeVal of
        Just val ->
            val
    
        Nothing ->
            ""
            

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of 
        LoadGameInfo userId ->
            ({ model | address = "Load Game Info" }, makeRequest userId)
        NavigateShows ->
            ({ model | address = "navigate shows" }, (Nav.load  Routes.showsPath) )
        SelectNetwork  ->
            let
                slcGame = { network = model.selectedNetwork ,  currentShows = ["some show", "Another show"] }
            in
              ({model | currentGame = Just slcGame }, Cmd.none)
        NetworkChange netwrk -> 
            ( {model | selectedNetwork =  netwrk }, Cmd.none) 
        GotResponse response ->
            case response of
                RemoteData.Loading ->
                    ({ model | address = "loading..." }, Cmd.none)
                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            ({ model | address =  data.address }, Cmd.none)
                        Nothing ->
                            ({ model | address = "no address" }, Cmd.none)
                RemoteData.Failure err ->
                    ({ model | address = "err" }, Cmd.none)
                RemoteData.NotAsked ->
                    ({ model | address = "Not Asked" }, Cmd.none)
      
view : Model -> Html Msg
view model =
    let
        vw =
             case model.currentGame of
                Just mdl ->
                    viewCurrentGame mdl
                Nothing ->
                    viewSelectGame model
                    
    in
        div [] 
        [ vw ]
        

   

-- View
viewSelectGame : Model -> Html Msg
viewSelectGame model =
    div[][
        div [][text ("address : "  ++ model.address)]
        , Form.form []
        [   
            Form.group []
            [ Form.label [ for "mynetworks" ] [ text "My Networks" ]
            , Select.select [ Select.id "mynetworks", Select.onChange NetworkChange ]
                (List.map (\x ->  Select.item [] [ text x ]) model.possibleNetworks) 
                           
            ]
        ]
        ,    
            
         div[][  Button.button [ Button.primary,  Button.onClick SelectNetwork ] [ text "Select Network" ]]
    ]
    
viewCurrentGame : CurrentGameModel -> Html Msg
viewCurrentGame model =
 div[][
        h3[][text model.network]
        
        , ListGroup.ul
            (List.map (\x ->  ListGroup.li [] [ text x ]) model.currentShows)
        , Button.button [ Button.primary,  Button.onClick NavigateShows ] [ text "View Available Shows" ]
    
       
    ]

port userIdRequest : String -> Cmd msg
port userIdResult : (String -> msg) -> Sub msg