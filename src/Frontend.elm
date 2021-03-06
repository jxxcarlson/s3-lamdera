module Frontend exposing (..)

import Base64
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Element.Border as Border
import Element exposing(..)
import File exposing(File)
import File.Select
import Lamdera
import Task
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( {  key = key
       , fileContents = Nothing
       , fileData = Nothing
       , message = "Welcome to Lamdera! You're looking at the auto-generated base implementation. Check out src/Frontend.elm to start coding!"
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Cmd.batch [ Nav.pushUrl model.key (Url.toString url) ]
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        -- IMAGE UPLOAD

        ImageRequested ->
           ( model, File.Select.file ["image/png","image/jpg"] ImageSelected )

        ImageSelected file ->
            let
              task = Task.map Base64.fromBytes (File.toBytes file)
              fileData = getFileData file
            in
             ( { model | fileData = Just fileData }, Task.perform ImageLoaded task )

        ImageLoaded content -> ( {model | fileContents = content}, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


-- VIEW

view : Model -> Browser.Document FrontendMsg
view model =
      {  title ="S3 uploader"
        , body = [Element.layoutWith { options = [focusStyle noFocus]} [] (mainView model)]
       }


mainView : Model -> Element FrontendMsg
mainView model =
    column [ Font.size 18, width (px 500), centerX, centerY, spacing 30 ]
        [ el [Font.size 56] (text "S3 Uploader")
        , openFileButton
        , showFileData model
        , showImageSize model
        ]

showFileData : Model -> Element FrontendMsg
showFileData model =
  case model.fileData of
        Nothing -> Element.el [] (text "No file data yet")
        Just fileData ->
            Element.column [spacing 8] [
                text <| "Name: " ++ fileData.name
              , text <| "Mime type: " ++ fileData.mime
              , text <| "Size: " ++ String.fromInt fileData.size
             ]

showImageSize : Model -> Element FrontendMsg
showImageSize model =
  let
    message = case model.fileContents of
        Nothing -> "No Base64 string yet"
        Just str -> "Base64 string size: " ++ String.fromInt (String.length str)
  in
    Element.el [Font.size 18] (text message)

openFileButton : Element FrontendMsg
openFileButton =
    Input.button [Element.padding 8, Background.color (gray 0.5), Font.color (gray 1.0)] {
       onPress = Just ImageRequested
     , label = Element.el [] (Element.text "Open File")
    }


-- VIEW HELPERS


noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }

gray : Float -> Color
gray g = Element.rgb g g g


-- HELPERS

getFileData : File -> FileData
getFileData file =
        {
          name  = File.name file
        , mime = File.mime file
        , size = File.size file
        , lastModified = File.lastModified file
       }
