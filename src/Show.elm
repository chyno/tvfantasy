module Show exposing (..)

import Browser
import Html
    exposing
        ( Attribute
        , Html
        , br
        , button
        , div
        , h1
        , h3
        , hr
        , img
        , input
        , li
        , p
        , span
        , strong
        , text
        , ul
        )
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as E
import Model exposing (..)


showsView : Model -> Html Msg
showsView model =
    let
        showDetails =
            \x -> ul [] [ text x.name ]
    in
    div [ class "message" ]
        [ h1 [] [ text "These are your shows:" ]
        , ul [] (List.map (\x -> li [] [ text x.name ]) model.loginResult.showInfos)
        , div [ class "button", onClick Logout ] [ text "Log Out" ]
        ]
