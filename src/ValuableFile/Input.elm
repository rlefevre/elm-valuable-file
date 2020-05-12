module ValuableFile.Input exposing
    ( file, onFile
    , files, onFiles
    )

{-| File selectors.


# Single File

@docs file, onFile


# Multiple Files

@docs files, onFiles

-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder)
import ValuableFile exposing (ValuableFile)


{-| A single file input.

    import Html exposing (Html)
    import ValuableFile exposing (ValuableFile)
    import ValuableFile.Input as Input

    type Msg
        = FileSelected File

    view : Html msg
    view =
        Input.file
            [ Input.onFile FileSelected
            , Input.accept "application/json"
            ]
            []

This is an `Html.input` with `Html.Attributes.type_ "file"` preset
for convenience.

To style the input, hide it and use a label:

    import Html.Attributes

    view : Html msg
    view =
        div []
            [ Input.file
                [ Input.onFile FileSelected
                , Attributes.id "file-upload"
                , Attributes.style "display" "none"
                ]
                []
            , Html.label
                [ Attributes.for "file-upload"
                , Attributes.style "padding" "16px"
                , Attributes.style "border" "1px solid grey"
                , Attributes.style "cursor" "pointer"
                ]
                [ Html.text "Upload"
                ]
            ]

-}
file : List (Attribute msg) -> List (Html msg) -> Html msg
file attrs =
    Html.input (Attributes.type_ "file" :: attrs)


{-| Detect [change](https://developer.mozilla.org/en-US/docs/Web/Events/change)
events on file input. It will grab the value from
`event.target.files` as a single file.
-}
onFile : (ValuableFile -> msg) -> Html.Attribute msg
onFile toMsg =
    Events.on "change" (Decode.map toMsg fileDecoder)


fileDecoder : Decoder ValuableFile
fileDecoder =
    Decode.at [ "target", "files" ] (Decode.list ValuableFile.decoder)
        |> Decode.andThen
            (\fileList ->
                case fileList of
                    firstFile :: _ ->
                        Decode.succeed firstFile

                    [] ->
                        Decode.fail "expecting a file"
            )


{-| A multiple files input.

    import Html exposing (Html)
    import ValuableFile exposing (ValuableFile)
    import ValuableFile.Input as Input

    type Msg
        = FilesSelected (List ValuableFile)

    view : Html msg
    view =
        Input.files [ Input.onFiles FilesSelected ] []

This is an `Html.input` with `Html.Attributes.type_ "file"` and
`Html.Attributes.multiple true` preset for convenience.

-}
files : List (Attribute msg) -> List (Html msg) -> Html msg
files attrs =
    Html.input
        (Attributes.type_ "file" :: Attributes.multiple True :: attrs)


{-| Detect [change](https://developer.mozilla.org/en-US/docs/Web/Events/change)
events on multiple files input. It will grab the value from
`event.target.files`.
-}
onFiles : (List ValuableFile -> msg) -> Html.Attribute msg
onFiles toMsg =
    Events.on "change" (Decode.map toMsg filesDecoder)


filesDecoder : Decoder (List ValuableFile)
filesDecoder =
    Decode.at [ "target", "files" ] (Decode.list ValuableFile.decoder)


{-| List of types the file input accepts, typically a file type.

    Input.accept "application/json"

    Input.accept ".md"

This is the same attribute as `Html.Attributes.accept` re-exposed
for convenience.

-}
accept : String -> Html.Attribute msg
accept =
    Attributes.accept
