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
type GameStages
    =  CurrentGame InGameModel
    | SelectGame SelectGameModel
   

type alias InGameModel =
    {
        selectedNetwork:  String
        ,  currentShows: List String

    }

type alias SelectGameModel =
    {
        possibleNetworks: List String
    }

type alias Model =
    { 
        address : String
        , userName : String
        , stage : GameStages
    }

initPage: SelectGameModel
initPage = {
        possibleNetworks = ["ABC", "NBC", "CBS", "ESPN"]
    }

init : ( Model, Cmd Msg )
init  =
    ( { stage = (SelectGame initPage), userName = "chyno", address = "aa1234" }, Cmd.none )

-- Msg
type Msg =  NavigateShows
            -- | SelectNetwork String

--Subcriptions
-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

--Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.stage of
        CurrentGame mdl ->
            (model, Cmd.none)
        SelectGame mdl ->
            case msg of 
                NavigateShows ->      
                    (model, (Nav.load  Routes.showsPath) )
                -- _ ->
                --     (model, Cmd.none)
               


view : Model -> Html Msg
view model =
    let
        vw =
             case model.stage of
                SelectGame mdl ->
                    viewSelectGame mdl
                CurrentGame mdl ->
                    viewCurrentGame mdl
    in
        div [] 
        [
            h3 [] [text model.userName]
            , h3 [] [text model.address]
            , vw
        ]

   

-- View
viewSelectGame : SelectGameModel -> Html Msg
viewSelectGame model =
    div[][
        h3[][text "Manage Your Network"]
        -- , div   [ class "field" ]
        --         [ label [ class "label" ] [ text "Available Networks" ]
        --         , div   [ class "control" ]
        --                 [ div [ class "select" ]
        --                     [ select []  (List.map (\x ->  option [] [ text x ]) model.possibleNetworks)
        --                     ]
        --                 ]
        --         ] 
        --   , div   [ class "field" ]
        --         [ div   [ class "control" ]
        --                 [ button [class "button is-link", onClick SelectNetwork][text "Select Network"]
        --                 ]
        --         ] 
    ]
    
viewCurrentGame : InGameModel -> Html Msg
viewCurrentGame model =
 div[][
        h3[][text "Manage Your Network"]
        -- , div   [ class "field" ]
        --         [ label [ class "label" ] [ text "Available Networks" ]
        --         , div   [ class "control" ]
        --                 [ div [ class "select" ]
        --                     [ select []  (List.map (\x ->  option [] [ text x ]) model.currentShows)
        --                     ]
        --                 ]
        --         ] 
        --   , div   [ class "field" ]
        --         [ div   [ class "control" ]
        --                 [ button [class "button is-link", onClick SelectNetwork][text "Select Network"]
        --                 ]
        --         ] 
    ]