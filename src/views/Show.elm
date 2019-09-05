module Show exposing (..)

import Browser
import Html exposing ( ..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as E
import Model exposing (..)
 

showsView : ShowsModel -> Html Msg
showsView model =
  let
    showDetails =
      \x -> tr[][
        td[][text x.name]
        ,td[][text x.country]
        ,td[][text x.overview]
        , td[][text x.firstAirDate]
        , td[][text (String.fromFloat x.voteAverage)]
      ]
  in
    div [ class "message" ]
    [ h1 [] [ text "These are your shows:" ]
      ,table[] (tr[] [
            th[][text "Name"]
            ,th[][text "Country"]
            , th[][text "Description"]
            , th[][text "First Aired"]
            , th[][text "Vote Average"]
          ]:: (List.map showDetails model.showInfos))
      , div [ class "button", onClick  Logout ] [ text "Log Out" ]
    ]

-- , onClick StartLogout