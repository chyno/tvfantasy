module Main exposing (init, main, subscriptions)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Html exposing (Html, a, div, section, text)
import Html.Attributes exposing (class, href)
import Page.Login as Login
import Page.Show as Show
import Page.Game as Game
import Routes exposing (Route)
import Shared exposing (..)
import Url exposing (Url)


type alias Model =
    { flags : Flags
    , navKey : Key
    , route : Route
    , page : Page
    }


type Page
    = PageNone
    | PageLogin Login.Model
    | PageShow Show.Model
    | PageGame Game.Model


type Msg
    = OnUrlChange Url
    | OnUrlRequest UrlRequest
    | LoginMsg Login.Msg
    | ShowMsg Show.Msg
    | GameMsg Game.Msg
   

init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { flags = flags
            , navKey = navKey
            , route = Routes.parseUrl url
            , page =   PageLogin Login.initdata
            }
    in
       loadCurrentPage  ( model, Cmd.none )


loadCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
loadCurrentPage ( model, cmd ) =
    let
        ( page, newCmd ) =
            case model.route of
                Routes.ShowsRoute ->
                    let
                        ( pageModel, pageCmd ) =
                            Show.init model.flags
                    in
                    ( PageShow pageModel, Cmd.map ShowMsg pageCmd )

                Routes.LoginRoute ->
                    let
                        ( pageModel, pageCmd ) =
                            Login.init
                    in
                    ( PageLogin pageModel, Cmd.map LoginMsg pageCmd )

                Routes.GameRoute ->
                    let
                        ( pageModel, pageCmd ) =
                            Game.init
                    in
                        ( PageGame pageModel, Cmd.map GameMsg pageCmd )
    
                Routes.ShowRoute showId ->
                    ( PageNone, Cmd.none )

                Routes.NotFoundRoute ->
                    ( PageNone, Cmd.none )
    in
    ( { model | page = page }, Cmd.batch [ cmd, newCmd ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSubs = 
            case model.page of
                PageLogin pageModel ->
                    Sub.map LoginMsg (Login.subscriptions pageModel)

                PageShow pageModel ->
                    Sub.map ShowMsg (Show.subscriptions pageModel)
                PageGame pageModel ->
                    Sub.map GameMsg (Game.subscriptions pageModel)

                PageNone ->
                    Sub.none
    in
        Sub.batch[pageSubs]
        

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( OnUrlRequest urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( OnUrlChange url, _ ) ->
            let
                newRoute =
                    Routes.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> loadCurrentPage
        ( LoginMsg subMsg, PageLogin pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    Login.update  subMsg pageModel
            in
            ( { model | page = PageLogin newPageModel }
            , Cmd.map LoginMsg newCmd
            )
        (ShowMsg subMsg, PageShow pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    Show.update  subMsg pageModel
            in
            ( { model | page = PageShow newPageModel }
            , Cmd.map ShowMsg newCmd
            )
        (GameMsg subMsg, PageGame pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    Game.update  subMsg pageModel
            in
            ( { model | page = PageGame newPageModel }
            , Cmd.map GameMsg newCmd
            )
        (_,_ )  ->
           Debug.todo "loginmsg pageshow"

main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }

-- VIEWS
view : Model -> Browser.Document Msg
view model =
    { title = "App"
    , body = [ currentPage model ]
    }


currentPage : Model -> Html Msg
currentPage model =
    let
        page =
            case model.page of
                PageLogin pageModel ->
                    Login.view pageModel
                        |> Html.map LoginMsg

                PageShow pageModel ->
                    Show.view pageModel
                        |> Html.map ShowMsg
                PageGame pageModel ->
                    Game.view pageModel
                        |> Html.map GameMsg
                PageNone ->
                    notFoundView
    in
    div []
        [ page]



notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found..."
        ]

