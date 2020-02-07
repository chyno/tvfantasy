module Page.PlayGame exposing (Model, Msg(..), init, subscriptions, update, view)

import Api.InputObject exposing (GameInput, GameInputRaw, buildGameInput)
import Api.Mutation as Mutation
import Api.Query as Query
import Api.Scalar exposing (Id(..))
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Table as Table

import Bootstrap.Form.Select as Select
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.ListGroup as ListGroup
import Graphql.Http exposing (Error)
import Graphql.OptionalArgument exposing (..)
import Html exposing (Html, div, h1, label, li, text, ul)
import Html.Attributes exposing (class, for)
import Html.Events exposing (onClick)
import RemoteData exposing (RemoteData)
import Shared exposing (GameInfo, UserInfo, faunaEndpoint, faunaAuth)
import TvApi exposing (GameQueryResponse, Response, gameSelection, userSelection)
import Browser.Navigation as Nav
import Routes exposing (showsPath)

--  Model


type alias GameModel =
    { userInfo : UserInfo
    , editGame : Maybe GameInfo
    , selectedGame : String
    }


type Model
    = LoadingResults String
    | HasGame GameModel


type GameEditMsg
    = UpdateGameName String
    | UpdateWalletAmount String
    | UpdateNetworkName String
    | UpdateDescription String
    | CancelEdit
    | SaveGame
    | NavigateShows


type Msg
    = AddNewGame
    | EditExistingGame
    | GameEdit GameEditMsg
    | GameChange String
    | GotUserInfoResponse GameQueryResponse
    | GotGameUpdateResponse (RemoteData (Graphql.Http.Error (Maybe GameInfo)) (Maybe GameInfo))



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
                    Html.map GameEdit (playGame selGame)


loadingView : String -> Html Msg
loadingView msg =
    div []
        [ div [] [ text msg ]
        , Html.button [] [ text "Reload" ]
        ]


viewChooseGame : GameModel -> Html Msg
viewChooseGame model =
    div []
        [ Form.form []
            [ Form.group []
                [ Form.label [ for "mygmes" ] [ text "Avaliable Games" ]
                , Select.select [ Select.id "mygmes", Select.onChange GameChange ]
                    (List.map (\x -> Select.item [] [ text x.gameName ]) model.userInfo.games)
                ]
            , Button.button [ Button.primary, Button.onClick EditExistingGame ] [ text "Select" ]
            ]
        ]


playGame : GameInfo -> Html GameEditMsg
playGame model =
    div []
        [ Form.form [Html.Events.onSubmit SaveGame]
            [ Form.group []
                [ Form.label [ for "gameName" ] [ text "Game Name" ]
                , Input.text [ Input.id "gameName", Input.onInput UpdateGameName, Input.value model.gameName ]
                , Form.help [] [ text "Enter Game Name" ]
                ]
            , Form.group []
                [ Form.label [ for "myrating" ] [ text "Amount" ]
                , Input.text [ Input.id "myrating", Input.onInput UpdateWalletAmount, Input.value "0" ]
                , Form.help [] [ text "Enter Wallet Amount" ]
                ]
            , Form.group []
                [ Form.label [ for "networkName" ] [ text "Network Name" ]
                , Input.text [ Input.id "networkName", Input.onInput UpdateNetworkName, Input.value model.networkName ]
                , Form.help [] [ text "Enter Network Name" ]
                ]
            , Form.group []
                [ Form.label [ for "mydescription" ] [ text "Description" ]
                , Input.text [ Input.id "mydescription", Input.onInput UpdateDescription, Input.value model.networkDescription ]
                , Form.help [] [ text "Enter Description" ]
                ]
            ]
        , div [ class "button-group" ]
            [ Button.submitButton [ Button.primary ] [ text "Save Changes" ]
            ,  Button.button [ Button.secondary, Button.onClick NavigateShows ] [ text "Manage Shows" ]
            , Button.linkButton [ Button.secondary, Button.onClick CancelEdit ] [ text "Done" ]
            ]
        ]

showsTable : List Shared.ShowInfo -> Html Msg
showsTable shows = 
 div [] []

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


updateGame : GameEditMsg -> Maybe GameInfo -> ( Maybe GameInfo, Cmd Msg )
updateGame msg maybeModel =
    case maybeModel of
        Nothing ->
            ( maybeModel, Cmd.none )

        Just model ->
            case msg of
                NavigateShows ->
                    (Just model, (Nav.load  Routes.showsPath) )
                UpdateGameName newName ->
                    ( Just { model | gameName = newName }, Cmd.none )

                UpdateWalletAmount val ->
                    ( Just { model | walletAmount = String.toInt val }, Cmd.none )

                UpdateNetworkName val ->
                    ( Just { model | networkName = val }, Cmd.none )

                UpdateDescription val ->
                    ( Just { model | networkDescription = val }, Cmd.none )

                CancelEdit ->
                    ( Nothing, Cmd.none )

                SaveGame ->
                    ( Just model, updateGameCmd model )



-- Update
updateNewGame : List GameInfo -> GameInfo -> List GameInfo
updateNewGame lstGames game =
    lstGames


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( EditExistingGame, HasGame gcmdl ) ->
            ( HasGame { gcmdl | editGame = getGame gcmdl.selectedGame gcmdl.userInfo.games }, Cmd.none )

        ( AddNewGame, HasGame mdl ) ->
            ( model, makeUserInfoRequest mdl.userInfo.userName )

        ( GameEdit gmsg, HasGame mdl ) ->
            let
                ( newSelectedGameModel, cmd ) =
                    updateGame gmsg mdl.editGame
            in
            ( HasGame { mdl | editGame = newSelectedGameModel }, cmd )

        ( GameChange newGame, HasGame gcmdl ) ->
            ( HasGame { gcmdl | selectedGame = newGame }, Cmd.none )

        ( GotGameUpdateResponse response, HasGame gmmdl ) ->
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
                            ( HasGame updatedUser, Cmd.none )

                        Nothing ->
                            ( LoadingResults "Can not get data", Cmd.none )

                RemoteData.Failure err ->
                    ( LoadingResults "error", Cmd.none )

                --(errorToString err), Cmd.none )
                RemoteData.NotAsked ->
                    ( LoadingResults "Not Asked", Cmd.none )

        ( GotUserInfoResponse response, LoadingResults message ) ->
            case response of
                RemoteData.Loading ->
                    ( LoadingResults message, Cmd.none )

                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            ( HasGame { userInfo = data, editGame = Nothing, selectedGame = getFirstGameName data.games }, Cmd.none )

                        Nothing ->
                            ( LoadingResults "Can not get data", Cmd.none )

                RemoteData.Failure err ->
                    ( LoadingResults (errorToString err), Cmd.none )

                RemoteData.NotAsked ->
                    ( LoadingResults "Not Asked", Cmd.none )

        ( GotUserInfoResponse response, HasGame mdl ) ->
            ( LoadingResults "Loaded Game with Unandled message. This state should not happen", Cmd.none )

        ( _, LoadingResults loadingResults ) ->
            ( LoadingResults ("Loaded Game with Unandled message. This state should not happen. Loading Results: " ++ loadingResults), Cmd.none )



-- (_, _) ->
--      ( LoadingResults ("Loaded Game with Unandled message. This state should not happen. Loading Results: "), Cmd.none )
-- Helpers


getGame : String -> List GameInfo -> Maybe GameInfo
getGame gameName games =
    List.filter (\x -> x.gameName == gameName) games
        |> List.head


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


init : String -> ( Model, Cmd Msg )
init username =
    ( LoadingResults "Making Remote Call", makeUserInfoRequest username )


makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest userName =
    Query.userByUserName { userName = userName } userSelection
        |> Graphql.Http.queryRequest faunaEndpoint
        |> Graphql.Http.withHeader "Authorization" faunaAuth
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)


gameIntputData : GameInfo -> GameInput
gameIntputData gameData =
    let
        funOp =
            \_ -> { walletAmount = Absent, end = Absent, shows = Absent, start = Absent, user = Absent }
    in
        buildGameInput
            { gameName = gameData.gameName, networkDescription = gameData.networkDescription, networkName = gameData.networkName }
            funOp



updateGameCmd : GameInfo -> Cmd Msg
updateGameCmd gmData =
    Mutation.updateGame { data = gameIntputData gmData, id = Id gmData.id } gameSelection
        |> Graphql.Http.mutationRequest faunaEndpoint
        |> Graphql.Http.withHeader "Authorization" faunaAuth
        |> Graphql.Http.send (RemoteData.fromResult >> GotGameUpdateResponse)



-- mutation {
--   updateGame (id: 256087318276866580, data: {
--     gameName: "new gamename"
--     networkName: "new Network"
--     walletAmount: 2
--     networkDescription: "new dec"
--   }) {
--    gameName
--     networkName
--   }
-- }
