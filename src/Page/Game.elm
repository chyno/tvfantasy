module Page.Game exposing (Model, view, Msg(..), update, subscriptions, init)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Routes exposing (showsPath)
import Shared exposing (..)



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
        selectedNetwork : Maybe String
        , possibleNetworks: List String
    }

-- type alias Model =
--     { 
--          stage : GameStages
--     }

initPage: ChooseGameModel
initPage = {
        possibleNetworks = ["ABC", "NBC", "CBS", "ESPN"], selectedNetwork = Nothing
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
                    let
                        possibleNewModel = case mdl.selectedNetwork of
                                    Just val ->
                                      CurrentGame { network = val ,  currentShows = ["some show", "Another show"] }  
                                    _ ->
                                        model
                    in
                        (possibleNewModel, Cmd.none)
                NetworkChange netwrk -> 
                    (ChooseGame {mdl | selectedNetwork = Just netwrk }, Cmd.none) 
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
       div   [ class "field" ]
                [ label [ class "label" ] [ text "Available Networks" ]
                , div   [ class "control" ]
                        [ div [ class "select" ]
                            [ select [onInput NetworkChange]  (List.map (\x ->  option [] [ text x ]) model.possibleNetworks)
                            ]
                        ]
                ] 
          , div   [ class "field" ]
                [ div   [ class "control" ]
                        [ button [class "button is-link", onClick SelectNetwork][text "Select Network"]
                        ]
                ] 
    ]
    
viewCurrentGame : CurrentGameModel -> Html Msg
viewCurrentGame model =
 div[][
        h3[][text model.network]
        , div   [ class "field" ]
                [ label [ class "label" ] [ text "Your Shows" ]
                  ,  ul[](List.map (\x ->  li [] [ text x ]) model.currentShows) 
                ] 
          , div   [ class "field" ]
                [ div   [ class "control" ]
                        [ button [class "button is-link", onClick NavigateShows][text "See Available Shows"]
                        ]
                ] 
    ]