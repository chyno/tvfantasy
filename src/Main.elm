module Main exposing (init, main, subscriptions)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Html exposing (..)
import Html.Attributes exposing (..)
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
    let
        hdrVw =  case model.page of
                        PageLogin _ ->
                            loginHeaderView
                        _ ->
                            headerView

    in
    
    { title = "App"
    , body = [ 
        div[][
            hdrVw
            , currentPage model 
            , div[][text "John Chynoweth"]
        ]
        
    ]
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
    div [class "container"]
        [ page]



notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found..."
        ]

loginHeaderView: Html msg
loginHeaderView =
    nav [ class "navbar is-white" ]
    [ div [ class "container" ]
        [ div [ class "navbar-brand" ]
            [ a [ class "navbar-item brand-text", href "../" ]
                [ text "Tv Fantasy Network        " ]
            , div [ class "navbar-burger burger", attribute "data-target" "navMenu" ]
                [ span []
                    []
                , span []
                    []
                , span []
                    []
                ]
            ]
        , div [   id "navMenu" ]
            [ ]
        ]
    ]

headerView: Html msg
headerView = 
    nav [ class "navbar is-white" ]
    [ div [ class "container" ]
        [ div [ class "navbar-brand" ]
            [ a [ class "navbar-item brand-text", href "../" ]
                [ text "Tv Fantasy Network        " ]
            , div [ class "navbar-burger burger", attribute "data-target" "navMenu" ]
                [ span []
                    []
                , span []
                    []
                , span []
                    []
                ]
            ]
        , div [ class "navbar-menu", id "navMenu" ]
            [ div [ class "navbar-start" ]
                [ a [ class "navbar-item", href "game" ]
                    [ text "Home          " ]
                , a [ class "navbar-item", href "shows" ]
                    [ text "Shows          " ]
                , a [ class "navbar-item", href "#" ]
                    [ text "Status          " ]
                , a [ class "navbar-item", href "#" ]
                    [ text "Past Games          " ]
                ]
            ]
        ]
    ]

