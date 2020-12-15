module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Url exposing (Url)
import File exposing(File)
import Time


type alias FrontendModel =
    { key : Key
    , message : String
    , fileContents : Maybe String
    , fileData : Maybe FileData
    }

type alias FileData = {
     name : String
   , mime : String
   , size : Int
   , lastModified: Time.Posix
  }

type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | ImageRequested
    | ImageSelected File
    | ImageLoaded (Maybe String)


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
