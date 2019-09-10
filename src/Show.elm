module Show exposing (..)

import Browser
import Html exposing ( ..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as E
import Http exposing (..)
import Loading exposing (LoadingState)
import Http
import Json.Decode as D

type Msg
    = InitShows 
    | ShowsResult (Result Http.Error (List ShowInfo))

-- Model
type alias Model =
    { 
     showInfos : List ShowInfo
    }

type alias ShowInfo =
    { 
      name: String,
    --   country: String,
      overview: String,
      firstAirDate: String,
      voteAverage: Float
      
    }

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none 

showsView : Model -> Html Msg
showsView model =
  let
    showDetails =
      \x -> tr[][
        td[][text x.name]
        -- ,td[][text x.country]
        ,td[][text x.overview]
        , td[][text x.firstAirDate]
        , td[][text (String.fromFloat x.voteAverage)]
      ]
  in
    div [ class "message" ]
    [ h1 [] [ text "These are your shows:" ]
      ,table[] (tr[] [
            th[][text "Name"]
            -- ,th[][text "Country"]
            , th[][text "Description"]
            , th[][text "First Aired"]
            , th[][text "Vote Average"]
          ]:: (List.map showDetails model.showInfos))
      , div [ class "button" ] [ text "Log Out" ]
    ]
-- , onClick  Logout
-- , onClick StartLogout

-- Decoders
showDecoder : D.Decoder ShowInfo
showDecoder =
    D.map4
        ShowInfo
        (D.field "name" D.string)
        -- (D.field "country" D.string))
        (D.field "overview" D.string)
        (D.field "first_air_date" D.string)
        (D.field "vote_average" D.float)


listOfShowsDecoder : D.Decoder (List ShowInfo)
listOfShowsDecoder =
   D.field "results" (D.list showDecoder)