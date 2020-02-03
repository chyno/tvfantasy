module Page.PlayGame exposing (Model, Msg(..), init, subscriptions, update, view)

import Api.Query as Query
import Graphql.Http exposing (Error)
import Html.Attributes exposing (for, class)
import Html exposing (Html,  div, h1, label, li, text, ul)
import Html.Events exposing (onClick)
import RemoteData exposing (RemoteData)
import Shared exposing ( UserInfo, GameInfo)
import TvApi exposing (userSelection, GameResponse, Response)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Button as Button
import Bootstrap.ListGroup as ListGroup


--  Model
type alias GameModel =
    { 
        userInfo : UserInfo
       , editGame : Maybe GameInfo
       , selectedGame : String
    } 



type Model
    = LoadingResults String
    | HasGame GameModel
   

type GameEditMsg
    =   UpdateGameName String
    | UpdateWalletAmount String
    | UpdateNetworkName String
    | UpdateDescription String
    | CancelEdit


type Msg 
    =  AddNewGame
    | EditExistingGame
    | GameEdit GameEditMsg
    | GameChange String
    | GotUserInfoResponse GameResponse



-- View
view : Model -> Html Msg
view model =
    case model of
        LoadingResults mdl ->
            loadingView mdl
        HasGame mdl ->
            case mdl.editGame of
                Nothing ->
                    viewChooseGame mdl        
                Just selGame ->
                    Html.map  GameEdit (playGame selGame)
    
loadingView : String -> Html Msg
loadingView msg =
    div []
        [ div [] [ text msg ]
        , Html.button [  ] [ text "Reload" ]
        ]

viewChooseGame : GameModel -> Html Msg
viewChooseGame model =
    div[][
        Form.form []
        [   
            Form.group []
            [ Form.label [ for "mygmes" ] [ text "Avaliable Games" ]
            , Select.select [ Select.id "mygmes", Select.onChange GameChange  ]
                (
                    List.map (\x ->  Select.item [] [ text x.gameName ]) model.userInfo.games
                ) 
                           
            ]
            , Button.button [ Button.primary,  Button.onClick  EditExistingGame ] [ text "Select" ]
           

        ]
        
    ]

playGame : GameInfo -> Html GameEditMsg
playGame model =
         div []
    [ 
        Form.form []
        [   Form.group []
                [ Form.label [for "gameName"] [ text "Game Name"]
                , Input.text [ Input.id "gameName", Input.onInput  UpdateGameName, Input.value model.gameName ]
                , Form.help [] [ text "Enter Game Name" ]
                ]
            
            , Form.group []
                [ Form.label [for "myrating"] [ text "Amount"]
                , Input.text [ Input.id "myrating", Input.onInput   UpdateWalletAmount, Input.value "0" ]
                , Form.help [] [ text "Enter Wallet Amount" ]
                ]
             , Form.group []
                [ Form.label [for "networkName"] [ text "Network Name"]
                , Input.text [ Input.id "networkName", Input.onInput   UpdateNetworkName, Input.value  model.networkName ]
                , Form.help [] [ text "Enter Network Name" ]
                ]
            , Form.group []
                [ Form.label [for "mydescription"] [ text "Description"]
                , Input.text [ Input.id "mydescription", Input.onInput  UpdateDescription, Input.value model.networkDescription ]
                , Form.help [] [ text "Enter Description" ]

                ]
            
        ]
        , div[class "button-group"][
                -- Button.button [ Button.primary   ] [ text "Save Changes" ]
                Button.button [ Button.secondary, Button.onClick  CancelEdit ] [ text "Cancel" ]
            ]
    ]



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


updateGame : GameEditMsg ->  (Maybe GameInfo) -> ( (Maybe GameInfo), Cmd Msg )
updateGame msg maybeModel  =
    case maybeModel of
        Nothing ->
            (maybeModel, Cmd.none)
        Just model ->
            case msg of
                UpdateGameName newName ->
                    (Just model, Cmd.none)
                UpdateWalletAmount val->
                    (Just model, Cmd.none)
                UpdateNetworkName  val->
                    (Just model, Cmd.none)
                UpdateDescription val ->
                    (Just model, Cmd.none)
                CancelEdit ->
                   (Nothing, Cmd.none)

-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (msg, model) of
        (EditExistingGame, HasGame gcmdl) ->
             ( HasGame { gcmdl |  editGame = getGame gcmdl.selectedGame gcmdl.userInfo.games }, Cmd.none )
        (AddNewGame, HasGame mdl)  ->
            ( model, makeUserInfoRequest "user123" )
        (GameEdit gmsg, HasGame mdl) ->
            let
                (newSelectedGameModel, cmd) = (updateGame gmsg mdl.editGame)
            in
                (HasGame {mdl | editGame = newSelectedGameModel }, cmd)
          
        (GameChange newGame, HasGame gcmdl) ->
             ( HasGame { gcmdl |  selectedGame = newGame }, Cmd.none )
        (GotUserInfoResponse response, LoadingResults message) ->
            case response of
                RemoteData.Loading ->
                    ( LoadingResults message, Cmd.none )

                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            ( HasGame {userInfo = data, editGame = Nothing, selectedGame = "" }, Cmd.none )
                        Nothing ->
                            ( LoadingResults "Can not get data", Cmd.none )

                RemoteData.Failure err ->
                    ( LoadingResults (errorToString err), Cmd.none )

                RemoteData.NotAsked ->
                    ( LoadingResults "Not Asked", Cmd.none )
        (GotUserInfoResponse response,  HasGame mdl) ->
             ( LoadingResults "Loaded Game with Unandled message. This state should not happen", Cmd.none )
        (_,  LoadingResults loadingResults) ->
             ( LoadingResults ("Loaded Game with Unandled message. This state should not happen. Loading Results: " ++ loadingResults), Cmd.none )
        -- (_, _) ->
        --      ( LoadingResults ("Loaded Game with Unandled message. This state should not happen. Loading Results: "), Cmd.none )
        
        
-- Helpers
getGame :  String ->   List  GameInfo -> Maybe GameInfo
getGame gameName games =
    List.filter ( \x -> x.gameName == gameName ) games
    |> List.head
    

errorToString : Error Response -> String
errorToString err =
    "Error Response. Error: "


init : String -> ( Model, Cmd Msg )
init username =
    ( LoadingResults "Making Remote Call", makeUserInfoRequest username )


makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest userName =
    Query.userByUserName { userName = userName } userSelection
        |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
        |> Graphql.Http.withHeader "Authorization" " Basic Zm5BRGprSEpKa0FDRkNvZThnamFsMC13bWJEVDZPZkdBWXpORVo1UDp0dmZhbnRhc3k6c2VydmVy"
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)
