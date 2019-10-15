module Page.Game exposing (Model, view, Msg(..), update, subscriptions, init)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Routes exposing (showsPath)
import Shared exposing (..)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Button as Button
import Bootstrap.ListGroup as ListGroup


--Model
type Model
    =  CurrentGame CurrentGameModel
    | ChooseGame ChooseGameModel
   

type alias CurrentGameModel =
    {
        network:  String
        ,  currentShows: List String
       
    }

type alias ChooseGameModel =
    {
        selectedNetwork :  String
        , possibleNetworks: List String
    }

-- type alias Model =
--     { 
--          stage : GameStages
--     }

initPage: ChooseGameModel
initPage = {
        possibleNetworks = ["ABC", "NBC", "CBS", "ESPN"], selectedNetwork = ""
    }



init : ( Model, Cmd Msg )
init  =
    ( (ChooseGame initPage), Cmd.none )

-- Msg
type Msg =     NavigateShows 
                | SelectNetwork
                | NetworkChange String
                
--Subcriptions
-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

--Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case  model of 
        CurrentGame cmdl ->
            case msg of 
                NavigateShows ->
                    (model, (Nav.load  Routes.showsPath) )
                _ ->
                    Debug.todo "should not execute"
                    (model, Cmd.none)
        ChooseGame mdl ->
           case msg of 
                SelectNetwork  -> 
                    (CurrentGame { network = mdl.selectedNetwork ,  currentShows = ["some show", "Another show"] }, Cmd.none)
                NetworkChange netwrk -> 
                    (ChooseGame {mdl | selectedNetwork =  netwrk }, Cmd.none) 
                _ ->
                    Debug.todo "should not execute"
                    (model, Cmd.none)

view : Model -> Html Msg
view model =
    let
        vw =
             case model of
                ChooseGame mdl ->
                    viewSelectGame mdl
                CurrentGame mdl ->
                    viewCurrentGame mdl
    in
        div [] 
        [ vw ]
        

   

-- View
viewSelectGame : ChooseGameModel -> Html Msg
viewSelectGame model =
    div[][
         Form.form []
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