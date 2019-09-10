module Model exposing (..)
import Json.Encode as E
import Json.Decode as D

type alias ShowInfo =
    { 
      name: String,
    --   country: String,
      overview: String,
      firstAirDate: String,
      voteAverage: Float
      
    }

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