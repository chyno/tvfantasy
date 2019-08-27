module Show exposing (..)

import Browser
import Html exposing ( ..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as E
import Model exposing (..)


showsView : Model -> Html Msg
showsView model =
  let
    showDetails =
      \x -> tr[][
        td[][text x.name]
        ,td[][text x.country]
        ,td[][text x.overview]
        , td[][text x.firstAirDate]
        , td[][text x.voteAverage]
      ]
  in
    div [ class "message" ]
    [ h1 [] [ text "These are your shows:" ]
      ,table[] (List.map showDetails model.loginResult.showInfos)
      , div [ class "button", onClick Logout ] [ text "Log Out" ]
    ]
