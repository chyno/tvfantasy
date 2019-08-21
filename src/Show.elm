module  Show exposing(..)

import Model exposing (..)
import Browser
import Html.Events exposing (onInput, onClick)
import Html exposing (p,
 Html, Attribute,
 div, input, text, 
 h1, hr,br, img, h3, 
 strong, span, button, ul, li)
import Html.Attributes exposing (..)
import Json.Encode as E

showsView : Model -> Html Msg
showsView model = 
  let
        showDetails = \x -> ul [][text x.name] 
  in
    div [ class "message" ]
            [ div [ class "pill green" ]
                [ text "authenticated" ]
            , h1 [] [ text "These are your shows:" ]
            , ul [] (List.map (\x -> li [][text x.name]) model.loginResult.showInfos)

            ]  
            
