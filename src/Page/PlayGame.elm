module Page.PlayGame exposing (Model, Msg(.. ), init, subscriptions, update, view)

import Html exposing (label,h1, div, Html, text)
import  Shared exposing  ( NetworkInfo, ShowInfo)
-- import Html.Attributes exposing (text)
-- import Html.Events exposing (onClick)

--  Model

type alias GameModel =
    { 
     userName : String
     , selectedNetwork : Maybe NetworkInfo
     , availableNetworks : (List String)
    }
type  Model =   LoadingExistingNetworks GameModel
                | DisplayGame GameModel
                | EditNetwork GameModel


type Msg = AddNewNetworkMsg String

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

loadingView :  Html Msg
loadingView =
    div [][text "... Loading"]

displayGameView : GameModel ->  Html Msg
displayGameView model =
    let
        vw = case model.selectedNetwork of
            Just mdl ->
                gameDetailsView mdl
            Nothing ->
                div[][text "No Data"]
    in
    
    div [][
        h1[][text "Playing Game"]
        , vw
         
    ]
    

editNetworkView : GameModel ->  Html Msg
editNetworkView model =
    div [][text "edit netwok"]

gameDetailsView : NetworkInfo -> Html Msg
gameDetailsView netInfo =
    div[][
        label[][text "Name: "]
        , div[][ text netInfo.name]
        , label[][text "Rating: "]
        , div[][text  "netInfo.rating"]
        , label[][text "Description: "]
        , div[][text netInfo.description]
    ]
-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
 case msg of
     AddNewNetworkMsg user ->
         (model, Cmd.none)

initModel : String  -> Model
initModel userName = 
    DisplayGame {
                    userName = userName
                    , selectedNetwork = Nothing
                    , availableNetworks = []
                }
-- Helpers
init : String  -> ( Model, Cmd Msg )
init userName = 
    (initModel userName, Cmd.none )
        