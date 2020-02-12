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
import RemoteData exposing (RemoteData)
import Routes exposing (showsPath)
import Shared exposing (GameInfo, UserInfo, faunaAuth, faunaEndpoint)
import TvApi exposing (GameQueryResponse, Response, gameSelection, userSelection)



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
    | GotGameAddResponse (RemoteData (Graphql.Http.Error  GameInfo)  GameInfo)
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
        [ label [ style "margin-right" "2em" ] [ text "Wallet Address: " ]
        , span [] [ text model.userInfo.walletAddress ]
        , Form.form []
            [ Form.group []
                [ Form.label [ for "mygmes" ] [ text "Avaliable Games" ]
                , Select.select [ Select.id "mygmes", Select.onChange GameChange ]
                    (List.map (\x -> Select.item [] [ text x.gameName ]) model.userInfo.games)
                ]
            , Button.button [ Button.primary, Button.onClick EditExistingGame ] [ text "Select" ]
            , Button.button [ Button.primary, Button.onClick AddNewGame ] [ text "Add New" ]
            ]
        ]


playGame : GameInfo -> Html GameEditMsg
playGame model =
    div []
        [ Form.form [ Html.Events.onSubmit SaveGame ]
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
            , Button.button [ Button.secondary, Button.onClick NavigateShows ] [ text "Manage Shows" ]
            , Button.linkButton [ Button.secondary, Button.onClick CancelEdit ] [ text "Done" ]
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


updateGame : String ->  GameEditMsg -> Maybe GameInfo -> ( Maybe GameInfo, Cmd Msg )
updateGame userId msg maybeModel =
    case maybeModel of
        Nothing ->
            ( maybeModel, Cmd.none )

        Just model ->
            case msg of
                NavigateShows ->
                    case model.id of
                        Nothing ->
                            ( maybeModel, Cmd.none )
                        Just idVal ->
                            ( Just model, Nav.load (Routes.showsPath idVal) )

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
                    ( Just model, updateGameCmd userId model )



-- Update


updateNewGame : List GameInfo -> GameInfo -> List GameInfo
updateNewGame lstGames game =
    lstGames


setDefaultEditGame : GameModel -> GameModel
setDefaultEditGame model =
    { model | editGame = Just initNewGame }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( EditExistingGame, HasGame gcmdl ) ->
            ( HasGame { gcmdl | editGame = getGame gcmdl.selectedGame gcmdl.userInfo.games }, Cmd.none )

        ( AddNewGame, HasGame mdl ) ->
            ( HasGame (setDefaultEditGame mdl), Cmd.none )

        ( AddNewGame, LoadingResults loadMessage ) ->
            ( LoadingResults loadMessage, Cmd.none )

        ( GameEdit gmsg, HasGame mdl ) ->
            let
                ( newSelectedGameModel, cmd ) =
                    updateGame mdl.userInfo.id gmsg mdl.editGame
            in
            ( HasGame { mdl | editGame = newSelectedGameModel }, cmd )

        ( GameChange newGame, HasGame gcmdl ) ->
            ( HasGame { gcmdl | selectedGame = newGame }, Cmd.none )
        (GotGameAddResponse response,  HasGame gmmdl ) ->
             case response of
                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Success data ->
                    let
                        updatedGames =
                                    updateNewGame gmmdl.userInfo.games data
                        userInf = gmmdl.userInfo

                        updatedUser =  { gmmdl | userInfo = { userInf | games = updatedGames } }
                    in
                        ( HasGame updatedUser, Cmd.none )

                       
                RemoteData.Failure err ->
                    ( LoadingResults "error", Cmd.none )

                --(errorToString err), Cmd.none )
                RemoteData.NotAsked ->
                    ( LoadingResults "Not Asked", Cmd.none )

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
                            ( LoadingResults "User has no games", Cmd.none )

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

unWrap : Api.InputObject.GameUserRelationRaw -> Api.InputObject.GameUserRelation
unWrap x = Api.InputObject.GameUserRelation x


getUserRelationData : String -> Api.InputObject.GameUserRelationRaw
getUserRelationData userId =
    {
     create =  Absent
      , connect = Present (Id userId)
      , disconnect = Absent
    }

gameOptBuilder: String -> GameInputOptionalFields -> GameInputOptionalFields
gameOptBuilder userId gStart = 
    { gStart | user = Present  (unWrap (getUserRelationData userId))

    }

init : String -> ( Model, Cmd Msg )
init username =
    ( LoadingResults "Making Remote Call", makeUserInfoRequest username )


makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest userName =
    Query.userByUserName { userName = userName } userSelection
        |> Graphql.Http.queryRequest faunaEndpoint
        |> Graphql.Http.withHeader "Authorization" faunaAuth
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)


gameIntputData : String  ->  GameInfo -> GameInput
gameIntputData userId gameData =
  buildGameInput
        { gameName = gameData.gameName, networkDescription = gameData.networkDescription, networkName = gameData.networkName }
        (gameOptBuilder userId)


updateGameCmd : String -> GameInfo -> Cmd Msg
updateGameCmd userId  gmData =
    case gmData.id of
        Just idVal ->
            Mutation.updateGame { data = gameIntputData userId gmData, id = Id idVal } gameSelection
            |> Graphql.Http.mutationRequest faunaEndpoint
            |> Graphql.Http.withHeader "Authorization" faunaAuth
            |> Graphql.Http.send (RemoteData.fromResult >> GotGameUpdateResponse)
        Nothing ->
            Mutation.createGame { data = gameIntputData userId gmData } gameSelection
            |> Graphql.Http.mutationRequest faunaEndpoint
            |> Graphql.Http.withHeader "Authorization" faunaAuth
            |> Graphql.Http.send (RemoteData.fromResult >> GotGameAddResponse)
    
    
