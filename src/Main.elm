port module Main exposing (init, main, subscriptions)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Page.Login as Login
import Page.Show as Show
import Page.Game as Game
import Routes exposing (Route)
import Shared exposing (..)
import Url exposing (Url)
import Bootstrap.Button as Button

type alias Model =
    { flags : Flags
    , navKey : Key
    , route : Route
    , page : Page
    , userName : String
    }


type Page
    = PageNone
    | PageLogin Login.Model
    | PageShow Show.Model
    | PageGame Game.Model


type Msg
    = OnUrlChange Url
    | LinkClicked UrlRequest
    | LoginMsg Login.Msg
    | ShowMsg Show.Msg
    | GameMsg Game.Msg
    | Logout
 



init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        ( lgModel, lgCmd ) =  Login.init navKey

        model =
            { flags = flags
            , navKey = navKey
            , route = Routes.parseUrl url
            , page =   PageLogin lgModel
            , userName = ""
           
            }
    in
       loadCurrentPage  ( model, Cmd.none )


loadCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
loadCurrentPage ( model, cmd ) =
    case model.route of
        Routes.ShowsRoute ->
            let
                ( pageModel, pageCmd ) = Show.init model.flags
            in
             ( { model | page = PageShow pageModel }, Cmd.batch [ cmd, (Cmd.map ShowMsg pageCmd) ] )
                    -- ( PageShow pageModel, Cmd.map ShowMsg pageCmd )

        Routes.LoginRoute ->
            let
                ( pageModel, pageCmd ) = Login.init model.navKey
            in
                ( { model | page = PageLogin pageModel }, Cmd.batch [ cmd,  (Cmd.map LoginMsg pageCmd) ] )
                    -- ( PageLogin pageModel, Cmd.map LoginMsg pageCmd )

        Routes.GameRoute  maybeVal->
            let
                mdl = case maybeVal of
                        Just val ->
                            {model | userName = val}
                        Nothing  ->
                            model 

                (pageModel, pageCmd ) = Game.init
            in
                ( { mdl | page = PageGame pageModel }, Cmd.batch [ cmd,  (Cmd.map GameMsg pageCmd) ] )
                        -- ( PageGame pageModel, Cmd.map GameMsg pageCmd )
    
        Routes.ShowRoute showId ->
            ( { model | page = PageNone }, Cmd.none )
                    -- ( PageNone, Cmd.none )

        Routes.NotFoundRoute ->
            ( { model | page = PageNone }, Cmd.none )
                    -- ( PageNone, Cmd.none )
    -- in
    -- ( { model | page = page }, Cmd.batch [ cmd, newCmd ] )


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
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model , Nav.pushUrl model.navKey (Url.toString url))
                Browser.External url ->
                    ( model, Nav.load url )
        ( OnUrlChange url, _ ) ->
            let
                newRoute = Routes.parseUrl url
                        
            in
                ( { model | route = newRoute}, Cmd.none )
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
                    , Cmd.map ShowMsg newCmd)
        (GameMsg subMsg, PageGame pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    Game.update  subMsg pageModel
            in
                ( { model | page = PageGame newPageModel }
                    , Cmd.map GameMsg newCmd
                    )
        (Logout, _) ->
            (model , Cmd.batch [(logoutUser  "Logout"),  Nav.load  Routes.loginPath ])
               
        (_,_ )  ->
            Debug.todo "loginmsg pageshow"

main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = OnUrlChange
        }

-- VIEWS
view : Model -> Browser.Document Msg
view model =
    let 
        page =
            case model.page of
                PageLogin _ ->
                    div[ class "login-wrapper" ][
                       div [class "box content"] [currentPage model]
                    
                    ]
                _ ->
                    div[ class "noside-wrapper" ][
                        div[class "box header"] [ (headerView model)]
                        , div [class "box content"] [currentPage model]
                        
                    ]
    in
        {   title = "App"
            , body = [page,  div [class "site-footer"] [footerView]]
        }


currentPage : Model -> Html Msg
currentPage model =
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
    

notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found..."
        ]



headerView: Model ->  Html Msg
headerView model = 
    div [class "header-wrapper"][
       i [ style "flex-basis" "10px",  class "brand-lockup__logo brand-lockup__logo--animate"] []
        , span[style "text-align" "left",  class " brand-lockup__title brand-lockup__title--animate"][text "TV Fantasy"] 
        ,div [style "text-align" "right"] [
            span [][text ("Welcome " ++ model.userName)]
            ,  Button.linkButton [  Button.onClick Logout ] [ text "Log Out" ]  
         ]
    ]


footerView : Html msg
footerView =
    footer [ class "footer" ]
    [ 
        div [ class "content has-text-centered" ]
        [ p []
            [ strong []
                [ text "TV Fantasy  " ]
            , text " by "
            , a [ href "https://www.chynologic.com" ]
                [ text "John Chynoweth" ]
            , text ". The source code is licensed      "
            , a [ href "http://opensource.org/licenses/mit-license.php" ]
                [ text "MIT" ]
            , text ". The website content is licensed "
            , a [ href "http://creativecommons.org/licenses/by-nc-sa/4.0/" ]
                [ text "CC BY NC SA 4.0" ]
            , text ".    "
            ]
        ]
    ]

port logoutUser :   String -> Cmd msg
