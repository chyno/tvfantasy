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


-- Model
type alias ShowData =
    {
       data : List (Maybe ShowInfo)
    }

type alias ShowInfo =
    {
        name: String
        , rating: Int
        , description: String
    }

type alias NetworkData =
    {
       data : List (Maybe NetworkInfo)
    }

type alias NetworkInfo = 
    {
        name: String
        , rating: Int
        , description: String 
        , shows: List ShowInfo
    }

type alias UserInfo =
    { 
        walletAddress :  String
        , amount : Maybe Int
        , networks:  List (Maybe NetworkInfo)
       
    }

type alias Model =
    {
        message: Maybe String
        , currentShows: List String
        , walletAddress :  String
        , amount : Maybe Int
        , networks:  List NetworkInfo
        , selectedNetwork:  String
        , currentNetwork :  NetworkInfo
    }

initNetwork : NetworkInfo
initNetwork = 
    {
        name  = ""
        , rating   = 0
        , description   = ""
        , shows = []
    }

-- Message
type Msg =  UpdateNetworkName String
            | UpdateRating String
            | UpdateDescription String
            | UpdateNetwork
            | CancelUpdateNetwork
            | NavigateShows 
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
    , currentShows = [] 
    , currentNetwork = initNetwork
    
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
        UpdateNetworkName networkName ->
            (model, Cmd.none)
        UpdateRating rating ->
            (model, Cmd.none)
        UpdateDescription description ->
            (model, Cmd.none)
        UpdateNetwork ->
            let
                wn = model.currentNetwork
        
            in
                ({ model | currentNetwork = initNetwork, networks = (wn::model.networks)} , Cmd.none)
        CancelUpdateNetwork ->
            ({ model | currentNetwork = initNetwork }, Cmd.none)
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
       
        bodyView = 
                case (List.length model.networks )  of
                    0 ->
                        viewAddNetwork initNetwork 
                    _ ->
                        viewChooseNetwork model
    in
        div [] 
        [
            div [][text ("address : "  ++ model.walletAddress)]
            , bodyView 
            , div[][text msgText]
         ]
    

viewChooseNetwork : Model -> Html Msg
viewChooseNetwork model =
    div[][
        Form.form []
        [   
            Form.group []
            [ Form.label [ for "mynetworks" ] [ text "Avaliable Networks" ]
            , Select.select [ Select.id "mynetworks", Select.onChange NetworkChange  ]
                (List.map (\x ->  Select.item [] [ text x ]) ["need to iplment"]) 
                           
            ]
        ]
        ,    
        Button.button [ Button.primary,  Button.onClick SelectNetwork ] [ text "Select" ]
    ]

viewAddNetwork : NetworkInfo -> Html Msg
viewAddNetwork model =
      div []
    [ 
        Form.form []
        [   Form.group []
                [ Form.label [for "networkname"] [ text "Network Name"]
                , Input.text [ Input.id "networkname", Input.onInput  UpdateNetworkName, Input.value model.name ]
                , Form.help [] [ text "Enter Network" ]
                ]
            
            , Form.group []
                [ Form.label [for "myrating"] [ text "Rating"]
                , Input.password [ Input.id "myrating", Input.onInput   UpdateRating, Input.value (String.fromInt model.rating) ]
                , Form.help [] [ text "Enter Rating" ]
                ]
            , Form.group []
                [ Form.label [for "mydescription"] [ text "Description"]
                , Input.password [ Input.id "mydescription", Input.onInput  UpdateDescription, Input.value model.description ]
                , Form.help [] [ text "Enter Description" ]

                ]
            
        ]
        , div[class "button-group"][
                Button.button [ Button.primary,  Button.onClick   UpdateNetwork ] [ text "Add Network" ]
                , Button.button [ Button.secondary, Button.onClick  CancelUpdateNetwork ] [ text "Cancel" ]
            ]
    ]


-- viewNetworkShows : String -> Model -> Html Msg
-- viewNetworkShows network model = 
--     div [] [
--         ListGroup.ul
--             (List.map (\x ->  ListGroup.li [] [ text x ]) model.currentShows)
--         , Button.button [ Button.primary,  Button.onClick NavigateShows ] [ text "Choose Available Shows" ]
--         , Button.button [Button.secondary, Button.onClick ChangeNetwork][ text "Change Network"]
--     ]


-- User Info Query
queryUserInfo : String ->  SelectionSet (Maybe UserInfo) RootQuery
queryUserInfo un =
    Query.userByUserName { username = Id un } userSelection


--  SelectionSet (List Network) Api.Object.User
emptyNetwork :  List NetworkInfo
emptyNetwork  = []


networkDataParser : NetworkData -> (List (Maybe NetworkInfo))
networkDataParser ndata = 
    ndata.data

userSelection : SelectionSet UserInfo Api.Object.User
userSelection =
    SelectionSet.map3 UserInfo
        User.walletAddress
        User.amount
        ((User.networks fillArgs networkPageSelection) |> SelectionSet.map networkDataParser)
        

showPageSelection : SelectionSet ShowData Api.Object.ShowPage
showPageSelection =
    SelectionSet.map ShowData
        (ShowPage.data showSelection)

networkPageSelection : SelectionSet NetworkData Api.Object.NetworkPage
networkPageSelection =
    SelectionSet.map NetworkData
        (NetworkPage.data networkSelection)

showSelection : SelectionSet ShowInfo Api.Object.Show
showSelection =
    SelectionSet.map3 ShowInfo
        Show.name
        Show.rating
        Show.description

emptyShow : List ShowInfo
emptyShow  = []

fillArgs : Network.ShowsOptionalArguments -> Network.ShowsOptionalArguments
fillArgs x = x 

showDataParser : ShowData -> List ShowInfo
showDataParser sdata = 
    sdata.data |> values


networkSelection : SelectionSet NetworkInfo Api.Object.Network
networkSelection =
    SelectionSet.map4 NetworkInfo
        Network.name
        Network.rating
        Network.description
        ((Network.shows fillArgs showPageSelection) |> SelectionSet.map showDataParser)
        -- ((User.networks fillArgs networkPageSelection) |> SelectionSet.map networkDataParser)
        -- (SelectionSet.succeed emptyShow)
       



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
foldrValues : Maybe a -> List a -> List a
foldrValues item list =
    case item of
        Nothing ->
            list

        Just v ->
            v :: list

values : List (Maybe a) -> List a
values =
    List.foldr foldrValues []
