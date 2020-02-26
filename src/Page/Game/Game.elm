module Page.Game.Game exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Page.Game.PlayGame as PlayGame
import Page.Game.ShowsManage as ShowsManage


type CurrentView
    = GameView
    | ShowView


type alias Model =
    { currentView : CurrentView
    , userName : String
    , gameModel : PlayGame.Model
    , showsModel : Maybe ShowsManage.Model
    }


type Msg
    = PlayGame PlayGame.Msg
    | ShowsManage ShowsManage.Msg


init : String -> ( Model, Cmd Msg )
init username =
    ( { userName = username
      , gameModel = PlayGame.LoadingUserResults "Loading ..."
      , showsModel = Nothing
      }
    , Cmd.map PlayGame (PlayGame.makeUserInfoRequest username)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlayGame pgmsg ->
            let
                ( pgm2, pgmsg2 ) =
                    PlayGame.update pgmsg model.gameModel
            in
            ( { model | gameModel = pgm2 }, PlayGame pgmsg2 )

        --  (PlayGameModel pgm2, PlayGame pgmsg2)
        ShowsManage smsg ->
            let
                ( sm2, smsg2 ) =
                    ShowsManage.update smsg model.showsModel
            in
            ( { model | showsModel = Just sm2 }, ShowsManage smsg2 )



-- ( ShowsManage smsg, ShowsManageModel sm ) ->
--     let
--          ( sm2 , smsg2) = ShowsManage.update smsg sm
--     in
--         ( ShowsManageModel sm2,  ShowsManage smsg2 )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case model.currentView of
        GameView ->
            PlayGame.view model.gameModel

        ShowView ->
            ShowsManage.view model.showModel
