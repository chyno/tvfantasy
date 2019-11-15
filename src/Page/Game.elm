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
type alias UserInfo =
    { 
        walletAddress :  String
        , amount : Maybe Int
        , network:  String
       
    }

type alias Model =
    {
        message: Maybe String
        , currentShows: List String
        , possibleNetworks: List String
        , walletAddress :  String
        , amount : Maybe Int
        , network:  Maybe String
        , selectedNetwork:  String
    }



type Msg =     NavigateShows 
                | SelectNetwork
                | NetworkChange String
                | GotResponse (RemoteData (Graphql.Http.Error (Maybe UserInfo)) (Maybe UserInfo))
                | ChangeNetowrk



initPage: Model
initPage = {
    message = Nothing
    , walletAddress = ""
    , amount = Nothing
    , network = Nothing
    , selectedNetwork = ""
    ,  currentShows = []
    , possibleNetworks = ["ABC", "NBC", "CBS", "ESPN"]
    }


init : String  -> ( Model, Cmd Msg )
init username = 
    ( initPage, makeRequest username )

               

--Subcriptions
-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


--Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of
        ChangeNetowrk ->
         ({model | network = Nothing }, Cmd.none)
        NavigateShows ->
            ({ model | message = Just "navigate shows" }, (Nav.load  Routes.showsPath) )
        SelectNetwork  ->
             ({model | network = Just model.selectedNetwork }, Cmd.none)
        NetworkChange netwrk -> 
            ( {model | selectedNetwork =  netwrk }, Cmd.none) 
        GotResponse response ->
            case response of
                RemoteData.Loading ->
                    ({ model | message = Just "loading..." }, Cmd.none)
                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            ({ model | walletAddress =  data.walletAddress, amount = data.amount, network = Just data.network,  message = Nothing }, Cmd.none)
                        Nothing ->
                            ({ model | message = Just "could not return data", walletAddress =  "", amount = Nothing, network = Nothing }, Cmd.none)
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
        bodyView = 
                case model.network of
                    Just val ->
                        viewNetworkShows val 
                    Nothing ->
                        viewChooseNetwork 
    in
        div [] 
        [
            div [][text ("address : "  ++ model.walletAddress)]
            , (bodyView model)
            , div[][text msgText]
         ]
        

viewChooseNetwork : Model -> Html Msg
viewChooseNetwork model =
    div[][
        
        label [] [text model.selectedNetwork]
        , Form.form []
        [   
            Form.group []
            [ Form.label [ for "mynetworks" ] [ text "Avaliable Networks" ]
            , Select.select [ Select.id "mynetworks", Select.onChange NetworkChange ]
                (List.map (\x ->  Select.item [] [ text x ]) model.possibleNetworks) 
                           
            ]
        ]
        ,    
        Button.button [ Button.primary,  Button.onClick SelectNetwork ] [ text "Select" ]
    ]
    
viewNetworkShows : String -> Model -> Html Msg
viewNetworkShows network model = 
    div [] [
        h3[][text network]
        
        , ListGroup.ul
            (List.map (\x ->  ListGroup.li [] [ text x ]) model.currentShows)
        , Button.button [ Button.primary,  Button.onClick NavigateShows ] [ text "Choose Available Shows" ]

      , Button.button [Button.secondary, Button.onClick ChangeNetowrk][ text "Change Netowrk"]
    ]

-- viewCurrentGame : CurrentGameModel -> Html Msg
-- viewCurrentGame model =
--  div[][
--         h3[][text model.network]
        
--         , ListGroup.ul
--             (List.map (\x ->  ListGroup.li [] [ text x ]) model.currentShows)
--         , Button.button [ Button.primary,  Button.onClick NavigateShows ] [ text "View Available Shows" ]
    
       
--     ]


-- Query
-- https://github.com/dillonkearns/elm-graphql/blob/master/examples/src/Example01BasicQuery.elm
query : String ->  SelectionSet (Maybe UserInfo) RootQuery
query un =
    Query.userByUserName { username = Id un } userSelection


mapToString : Maybe String -> String
mapToString maybeVal =
    case maybeVal of
        Just val ->
            val
        Nothing ->
            ""


stringFragment : SelectionSet (Maybe String) Api.Object.User -> SelectionSet String Api.Object.User
stringFragment userSelectionMaybeVal =
    SelectionSet.map mapToString userSelectionMaybeVal
               
   
userSelection : SelectionSet UserInfo Api.Object.User
userSelection =
    SelectionSet.map3 UserInfo
        User.walletAddress
        User.amount
        (User.network |> stringFragment)
       

makeRequest : String -> Cmd Msg
makeRequest username =
    query username
        |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
        |> Graphql.Http.withHeader "Authorization" ("Bearer fnADbMd3RLACEpjT90hoJSn6SXhN281PIgIZg375" )
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)

