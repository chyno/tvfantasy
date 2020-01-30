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
    

type Msg
    = AddNewNetwork
    | EditExistingNetwork

-- View
view : Model -> Html Msg
view model =
    let
        vw =
            case model of
                LoadingExistingNetworks mdl ->
                    loadingView
                DisplayGame mdl ->
                    case mdl.selectedNetwork of
                        Nothing ->
                            div [][ text "Create a Network to start a game"]  
                        Just sel ->
                            gameView sel
    in
    div [] [
        vw,
        Html.button [ onClick AddNewNetwork ] [ text "Add New Network " ]
    ]
    
loadingView : Html Msg
loadingView =
    div [] [ text "... Loading" ]


gameView : NetworkInfo -> Html Msg
gameView netInfo =
    div []
        [ label [] [ text "Name: " ]
        , div [] [ text netInfo.name ]
        , label [] [ text "Rating: " ]
        , div [] [ text "netInfo.rating" ]
        , label [] [ text "Description: " ]
        , div [] [ text netInfo.description ]
        ]
-- 
-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( AddNewNetwork, DisplayGame mdl ) ->
            Debug.log "Adding newwork"
            ( DisplayGame { mdl | selectedNetwork = Just newNetwork }, Cmd.none )
        ( EditExistingNetwork, DisplayGame mdl ) ->
            ( DisplayGame mdl, Cmd.none )
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
