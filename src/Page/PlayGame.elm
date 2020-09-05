module Page.PlayGame exposing (Model, Msg(..), init, subscriptions, update, view)

import Api.InputObject exposing (GameInput, GameInputOptionalFields, buildGameInput)
import Api.Mutation as Mutation
import Api.Query as Query
import Api.Scalar exposing (Id(..))
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Table as Table
import Browser.Navigation as Nav
import Graphql.Http exposing (Error)
import Graphql.OptionalArgument exposing (..)
import Html exposing (Html, div, label, span, table, td, text, th, tr, ul)
import Html.Attributes exposing (class, for, id, style)
import Html.Events exposing (onClick)
import Page.ShowsManage as ShowsManage
import RemoteData exposing (RemoteData)
import Shared exposing (Flags, GameInfo, UserInfo, faunaAuth, faunaEndpoint)
import TvApi exposing (GameQueryResponse, Response, gameSelection, userSelection)



--  Model


type alias Model =
    { userName : String
    , flags : Flags
    , playGameModel : PlayGameModel
    }


type GameEditModes
    = GameManageMode (Maybe GameInfo)
    | ShowManageMode ShowsManage.Model


type alias GameModel =
    { userInfo : UserInfo
    , editGame : GameEditModes
    , selectedGame : String
    }


type PlayGameModel
    = LoadingUserResults String
    | UserInformation GameModel


type GameEditMsg
    = UpdateGameName String
    | UpdateWalletAmount String
    | UpdateNetworkName String
    | UpdateDescription String
    | CancelEdit
    | SaveGame
    | DisplayShow
    | ShowMsg ShowsManage.Msg

type Msg
    = AddNewGame
    | EditExistingGame
    | GameEdit GameEditMsg
    | GameChange String
    | GotUserInfoResponse GameQueryResponse
    | GotGameUpdateResponse (RemoteData (Graphql.Http.Error (Maybe GameInfo)) (Maybe GameInfo))
    | GotGameAddResponse (RemoteData (Graphql.Http.Error GameInfo) GameInfo)
    



--  Graphql.Http.Request #(Maybe GameInfo)


initNewGame : GameInfo
initNewGame =
    { gameName = ""
    , walletAmount = Nothing
    , networkName = ""
    , networkDescription = ""
    , id = Nothing
    , shows = []
    }



-- View


view : Model -> Html Msg
view model =
    case model.playGameModel of
        LoadingUserResults mdl ->
            loadingView mdl

        UserInformation mdl ->
            case mdl.editGame of
                GameManageMode maybeGameInfo ->
                    case maybeGameInfo of
                        Nothing ->
                            chooseGameView mdl

                        Just selGame ->
                            Html.map GameEdit (playGameView selGame)

                ShowManageMode showModel ->
                    let
                        page =  Html.map  ShowMsg (ShowsManage.view showModel)
                    in
                        Html.map GameEdit page
                   

loadingView : String -> Html Msg
loadingView msg =
    div []
        [ div [] [ text msg ]
        , Html.button [] [ text "Reload" ]
        ]


chooseGameView : GameModel -> Html Msg
chooseGameView model =
    div []
        [ div []
            [ label [ style "margin-right" "2em" ] [ text "Wallet Address: " ]
            , span [] [ text model.userInfo.walletAddress ]
            ]
        , div []
            [ label [ for "mygmes" ] [ text "Avaliable Games" ]
            , Select.select [ Select.id "mygmes", Select.onChange GameChange ]
                (List.map (\x -> Select.item [] [ text x.gameName ]) model.userInfo.games)
            ]
        , div [ class "button-group" ]
            [ Button.button [ Button.primary, Button.onClick EditExistingGame ] [ text "Select" ]
            , Button.button [ Button.success, Button.onClick AddNewGame ] [ text "Add New" ]
            ]
        ]


playGameView : GameInfo -> Html GameEditMsg
playGameView model =
    div []
        [ div []
            [ Form.label [ for "gameName" ] [ text "Game Name" ]
            , Input.text [ Input.id "gameName", Input.onInput UpdateGameName, Input.value model.gameName ]
            , Form.help [] [ text "Enter Game Name" ]
            ]
        , div []
            [ Form.label [ for "myrating" ] [ text "Amount" ]
            , Input.text [ Input.id "myrating", Input.onInput UpdateWalletAmount, Input.value "0" ]
            , Form.help [] [ text "Enter Wallet Amount" ]
            ]
        , div []
            [ Form.label [ for "networkName" ] [ text "Network Name" ]
            , Input.text [ Input.id "networkName", Input.onInput UpdateNetworkName, Input.value model.networkName ]
            , Form.help [] [ text "Enter Network Name" ]
            ]
        , div []
            [ Form.label [ for "mydescription" ] [ text "Description" ]
            , Input.text [ Input.id "mydescription", Input.onInput UpdateDescription, Input.value model.networkDescription ]
            , Form.help [] [ text "Enter Description" ]
            ]
        , div [ class "button-group" ]
            [ Button.button [ Button.primary, Button.onClick SaveGame ] [ text "Save Changes" ]
            , Button.button [ Button.primary, Button.onClick DisplayShow ] [ text "Manage Shows" ]
            , Button.button [ Button.secondary, Button.onClick CancelEdit ] [ text "Cancel" ]
            ]
        , showsTable model.shows
        ]


showRow : Shared.ShowInfo -> Html GameEditMsg
showRow show =
    tr []
        [ td [] [ text show.name ]
        , td [] [ text (String.fromInt show.rating) ]
        , td [] [ text show.description ]
        ]


showsTable : List Shared.ShowInfo -> Html GameEditMsg
showsTable shows =
    div [ id "wrapper" ]
        [ table []
            (tr []
                [ th [] [ text "Name" ]
                , th [] [ text "Rating" ]
                , th [] [ text "Description" ]
                ]
                :: List.map showRow shows
            )
        ]



-- Update


updateGame : Flags -> String -> GameEditMsg -> GameEditModes -> ( GameEditModes, Cmd Msg )
updateGame flags userId msg model =
    case model of
        GameManageMode maybeModel ->
            case maybeModel of
                Nothing ->
                    ( model, Cmd.none )

                Just gmModel ->
                    case msg of
                        DisplayShow ->
                            let
                               command = Cmd.map ShowMsg (ShowsManage.fetchShows flags) 
                            in
                                ( ShowManageMode { gameId = Maybe.withDefault "" gmModel.id, modelData = ShowsManage.StartLoad flags }, Cmd.map GameEdit command  )

                        UpdateGameName newName ->
                            ( GameManageMode (Just { gmModel | gameName = newName }), Cmd.none )

                        UpdateWalletAmount val ->
                            ( GameManageMode (Just { gmModel | walletAmount = String.toInt val }), Cmd.none )

                        UpdateNetworkName val ->
                            ( GameManageMode (Just { gmModel | networkName = val }), Cmd.none )

                        UpdateDescription val ->
                            ( GameManageMode (Just { gmModel | networkDescription = val }), Cmd.none )

                        CancelEdit ->
                            ( GameManageMode Nothing, Cmd.none )

                        SaveGame ->
                            ( GameManageMode (Just gmModel), saveGameCmd userId gmModel )
                        ShowMsg yamsg ->
                            Debug.todo "should not get here"
                            
        ShowManageMode showModel ->
            case msg of
                ShowMsg yamsg ->
                    let
                        ( updatedmodel, smessage ) = ShowsManage.update yamsg showModel
                        command = Cmd.map ShowMsg smessage
                    in
                        Debug.log "------- ShowManageMode shwModel -----"
                        ( ShowManageMode updatedmodel, Cmd.map GameEdit command )
                _ ->
                  Debug.todo "ShowManageMode shwModel"  
            

updateNewGame : List GameInfo -> GameInfo -> List GameInfo
updateNewGame games game =
    game :: List.filter (\x -> not (x.gameName == game.gameName)) games


updateGameHelper : Model -> GameModel -> Model
updateGameHelper model gameMode =
    { model | playGameModel = UserInformation gameMode }


loadingGameHelper : Model -> String -> Model
loadingGameHelper model message =
    { model | playGameModel = LoadingUserResults message }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.playGameModel ) of
        ( EditExistingGame, UserInformation gcmdl ) ->
            ( updateGameHelper model { gcmdl | editGame = getGame gcmdl.selectedGame gcmdl.userInfo.games }, Cmd.none )

        ( AddNewGame, UserInformation mdl ) ->
            ( updateGameHelper model (setDefaultEditGame mdl), Cmd.none )

        ( AddNewGame, LoadingUserResults loadMessage ) ->
            ( loadingGameHelper model loadMessage, Cmd.none )

        ( GameEdit gmsg, UserInformation mdl ) ->
            let
                ( newSelectedGameModel, cmd ) =
                    updateGame model.flags mdl.userInfo.id gmsg mdl.editGame
            in
                Debug.log "$$$$$$$$$$$$ GameEdit gmsg -----"
                ( updateGameHelper model { mdl | editGame = newSelectedGameModel }, cmd )

        ( GameChange newGame, UserInformation gcmdl ) ->
            ( updateGameHelper model { gcmdl | selectedGame = newGame }, Cmd.none )

        ( GotGameAddResponse response, UserInformation gmmdl ) ->
            case response of
                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Success data ->
                    let
                        userInf =
                            gmmdl.userInfo

                        addeddUser =
                            { gmmdl | editGame = GameManageMode Nothing, userInfo = { userInf | games = data :: gmmdl.userInfo.games } }
                    in
                    ( updateGameHelper model addeddUser, Cmd.none )

                RemoteData.Failure err ->
                    ( loadingGameHelper model "error", Cmd.none )

                --(errorToString err), Cmd.none )
                RemoteData.NotAsked ->
                    ( loadingGameHelper model "Not Asked", Cmd.none )

        ( GotGameUpdateResponse response, UserInformation gmmdl ) ->
            case response of
                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            let
                                updatedGames =
                                    updateNewGame gmmdl.userInfo.games data

                                userInf =
                                    gmmdl.userInfo

                                updatedUser =
                                    { gmmdl | userInfo = { userInf | games = updatedGames } }
                            in
                            ( updateGameHelper model updatedUser, Cmd.none )

                        Nothing ->
                            ( loadingGameHelper model "Can not get data", Cmd.none )

                RemoteData.Failure err ->
                    ( loadingGameHelper model "error", Cmd.none )

                --(errorToString err), Cmd.none )
                RemoteData.NotAsked ->
                    ( loadingGameHelper model "Not Asked", Cmd.none )

        ( GotUserInfoResponse response, LoadingUserResults message ) ->
            case response of
                RemoteData.Loading ->
                    ( loadingGameHelper model message, Cmd.none )

                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            ( updateGameHelper model { userInfo = data, editGame = GameManageMode Nothing, selectedGame = getFirstGameName data.games }, Cmd.none )

                        Nothing ->
                            ( loadingGameHelper model "User has no games", Cmd.none )

                RemoteData.Failure err ->
                    ( loadingGameHelper model (errorToString err), Cmd.none )

                RemoteData.NotAsked ->
                    ( loadingGameHelper model "Not Asked", Cmd.none )
        ( _, _ ) ->
            Debug.todo "Should not get here"



-- Helpers


setDefaultEditGame : GameModel -> GameModel
setDefaultEditGame model =
    { model | editGame = GameManageMode (Just initNewGame) }


getGame : String -> List GameInfo -> GameEditModes
getGame gameName games =
    GameManageMode
        (List.filter (\x -> x.gameName == gameName) games
            |> List.head
        )


getFirstGameName : List GameInfo -> String
getFirstGameName games =
    case List.head games of
        Nothing ->
            ""

        Just gm ->
            gm.gameName


errorToString : Error Response -> String
errorToString err =
    "Error Response. Error: "


init : Flags -> String -> ( Model, Cmd Msg )
init flags username =
    ( { userName = username
      , flags = flags
      , playGameModel = LoadingUserResults "Making Remote Call"
      }
    , makeUserInfoRequest username
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



--API Request - Query and Mytatutions


unWrap : Api.InputObject.GameUserRelationRaw -> Api.InputObject.GameUserRelation
unWrap x =
    Api.InputObject.GameUserRelation x


getUserRelationData : String -> Api.InputObject.GameUserRelationRaw
getUserRelationData userId =
    { create = Absent
    , connect = Present (Id userId)
    , disconnect = Absent
    }


gameOptBuilder : String -> GameInputOptionalFields -> GameInputOptionalFields
gameOptBuilder userId gStart =
    { gStart
        | user = Present (unWrap (getUserRelationData userId))
    }


makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest userName =
    Query.userByUserName { userName = userName } userSelection
        |> Graphql.Http.queryRequest faunaEndpoint
        |> Graphql.Http.withHeader "Authorization" faunaAuth
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)


gameIntputData : String -> GameInfo -> GameInput
gameIntputData userId gameData =
    buildGameInput
        { gameName = gameData.gameName, networkDescription = gameData.networkDescription, networkName = gameData.networkName }
        (gameOptBuilder userId)


saveGameCmd : String -> GameInfo -> Cmd Msg
saveGameCmd userId gmData =
    case gmData.id of
        Just idVal ->
            Debug.log ("has id " ++ idVal)
                Mutation.updateGame
                { data = gameIntputData userId gmData, id = Id idVal }
                gameSelection
                |> Graphql.Http.mutationRequest faunaEndpoint
                |> Graphql.Http.withHeader "Authorization" faunaAuth
                |> Graphql.Http.send (RemoteData.fromResult >> GotGameUpdateResponse)

        Nothing ->
            Debug.log "no id should be an add "
                Mutation.createGame
                { data = gameIntputData userId gmData }
                gameSelection
                |> Graphql.Http.mutationRequest faunaEndpoint
                |> Graphql.Http.withHeader "Authorization" faunaAuth
                |> Graphql.Http.send (RemoteData.fromResult >> GotGameAddResponse)
