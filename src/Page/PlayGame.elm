module Page.PlayGame exposing (Model, Msg(..), init, subscriptions, update, view)

import Html exposing (Html, div, h1, label, text)
import Html.Events exposing (onClick)
import Shared exposing (NetworkInfo, ShowInfo)



--  Model


type alias GameModel =
    { userName : String
    , selectedNetwork : Maybe NetworkInfo
    , availableNetworks : List String
    }

newNetwork : NetworkInfo
newNetwork = 
    {
        name = ""
        , rating = 0
        , description = "" 
        , shows = []

    }

type Model
    = LoadingExistingNetworks String
    | DisplayGame GameModel
    | EditNetwork GameModel


type Msg
    = AddNewNetwork
    | EditExistingNetwork

-- View
view : Model -> Html Msg
view model =
    case model of
        LoadingExistingNetworks mdl ->
            loadingView

        DisplayGame mdl ->
            displayGameView mdl
        EditNetwork mdl ->
            editNetworkView mdl

loadingView : Html Msg
loadingView =
    div [] [ text "... Loading" ]

displayGameView : GameModel -> Html Msg
displayGameView model =
    let
        vw =
            case model.selectedNetwork of
                Just mdl ->
                    gameDetailsView mdl

                Nothing ->
                    div [] [ text "No Data" ]
    in
    div []
        [ h1 [] [ text "Playing Game" ]
        , vw
        , Html.button [ onClick AddNewNetwork ] [ text "Add New Network " ]
        ]


editNetworkView : GameModel -> Html Msg
editNetworkView model =
    div [] [ text "edit netwok" ]


gameDetailsView : NetworkInfo -> Html Msg
gameDetailsView netInfo =
    div []
        [ label [] [ text "Name: " ]
        , div [] [ text netInfo.name ]
        , label [] [ text "Rating: " ]
        , div [] [ text "netInfo.rating" ]
        , label [] [ text "Description: " ]
        , div [] [ text netInfo.description ]
        ]

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( AddNewNetwork, DisplayGame mdl ) ->
            ( EditNetwork { mdl | selectedNetwork = Just newNetwork }, Cmd.none )

        ( EditExistingNetwork, EditNetwork mdl ) ->
            ( EditNetwork mdl, Cmd.none )
        _ ->
            ( model, Cmd.none )
 
initModel : String -> Model
initModel userName =
    DisplayGame
        { userName = userName
        , selectedNetwork = Nothing
        , availableNetworks = []
        }

-- Helpers

init : String -> ( Model, Cmd Msg )
init userName =
    ( initModel userName, Cmd.none )
