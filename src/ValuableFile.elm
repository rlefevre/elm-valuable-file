module ValuableFile exposing
    ( ValuableFile, decoder, encode, toFile
    , toString, toBytes, toUrl
    , name, mime, size, lastModified
    )

{-|


# ValuableFiles

@docs ValuableFile, decoder, encode, toFile


# Extract Content

@docs toString, toBytes, toUrl


# Read Metadata

@docs name, mime, size, lastModified

-}

import Bytes exposing (Bytes)
import File exposing (File)
import Json.Decode as Decode exposing (Decoder, Value)
import Task exposing (Task)
import Time


{-| Represents a file. From there you can read the content, check the
metadata, send it over a port, etc.
-}
type ValuableFile
    = ValuableFile Value File


{-| Decode `File` values. For example, if you want to create a drag-and-drop
file uploader, you can listen for `drop` events with a decoder like this:

    import Json.Decode exposing (Decoder, field, list)
    import ValuableFile exposing (ValuableFile)

    files : Decode.Decoder (List ValuableFile)
    files =
        field "dataTransfer" (field "files" (list ValuableFile.decoder))

Once you have the files, you can use functions like
[`ValuableFile.toString`](#toString) to process the content.
Or you can send the file along to someone else with the
[`elm/http`](/packages/elm/http/latest) package.

-}
decoder : Decoder ValuableFile
decoder =
    Decode.value
        |> Decode.andThen
            (\value -> Decode.map (ValuableFile value) File.decoder)


{-| Encode `File` values. This is useful to send them through a port:

    import ValuableFile

    port sendFile : Value -> msg

then in an update function:

    case msg of
        ValuableFileSelected (Ok file) ->
            ( model, sendFile (ValuableFile.encode file) )

-}
encode : ValuableFile -> Value
encode (ValuableFile value _) =
    value


{-| Convert to a standard [elm/file](/packages/elm/file/latest) File, for example to send
it over [elm/http](/packages/elm/http/latest).

    import Http

    Http.multipartBody
        [ stringPart "product" "Ikea Bekant"
        , stringPart "description" "Great desk for home office."
        , filePart "image[]" (ValuableFile.toFile file1)
        , filePart "image[]" (ValuableFile.toFile file2)
        , filePart "image[]" (ValuableFile.toFile file3)
        ]

-}
toFile : ValuableFile -> File
toFile (ValuableFile _ file) =
    file



-- CONTENT


{-| Extract the content of a `File` as a `String`. So if you have a `notes.md`
file you could read the content like this:

    import Task
    import ValuableFile exposing (ValuableFile)

    type Msg
        = MarkdownLoaded String

    read : ValuableFile -> Cmd Msg
    read file =
        Task.perform MarkdownLoaded (ValuableFile.toString file)

Reading the content is asynchronous because browsers want to avoid allocating
the file content into memory if possible. (E.g. if you are just sending files
along to a server with [`elm/http`](/packages/elm/http/latest) there is no
point having their content in memory!)

-}
toString : ValuableFile -> Task x String
toString (ValuableFile _ file) =
    File.toString file


{-| Extract the content of a `File` as `Bytes`. So if you have an `archive.zip`
file you could read the content like this:

    import Bytes exposing (Bytes)
    import Task
    import ValuableFile exposing (ValuableFile)

    type Msg
        = ZipLoaded Bytes

    read : ValuableFile -> Cmd Msg
    read file =
        Task.perform ZipLoaded (ValuableFile.toBytes file)

From here you can use the [`elm/bytes`](/packages/elm/bytes/latest) package to
work with the bytes and turn them into whatever you want.

-}
toBytes : ValuableFile -> Task x Bytes
toBytes (ValuableFile _ file) =
    File.toBytes file


{-| The `File.toUrl` function will convert files into URLs like this:

  - `data:*/*;base64,V2hvIGF0ZSBhbGwgdGhlIHBpZT8=`
  - `data:*/*;base64,SXQgd2FzIG1lLCBXaWxleQ==`
  - `data:*/*;base64,SGUgYXRlIGFsbCB0aGUgcGllcywgYm95IQ==`

This is using a [Base64](https://en.wikipedia.org/wiki/Base64) encoding to
turn arbitrary binary data into ASCII characters that safely fit in strings.

This is primarily useful when you want to show images that were just uploaded
because **an `<img>` tag expects its `src` attribute to be a URL.** So if you
have a website for selling furniture, using `File.toUrl` could make it easier
to create a screen to preview and reorder images. This way people can make
sure their old table looks great!

-}
toUrl : ValuableFile -> Task x String
toUrl (ValuableFile _ file) =
    File.toUrl file



-- METADATA


{-| Get the name of a file.

    ValuableFile.name file1 == "README.md"

    ValuableFile.name file2 == "math.gif"

    ValuableFile.name file3 == "archive.zip"

-}
name : ValuableFile -> String
name (ValuableFile _ file) =
    File.name file


{-| Get the MIME type of a file.

    ValuableFile.mime file1 == "text/markdown"

    ValuableFile.mime file2 == "image/gif"

    ValuableFile.mime file3 == "application/zip"

-}
mime : ValuableFile -> String
mime (ValuableFile _ file) =
    File.mime file


{-| Get the size of the file in bytes.

    ValuableFile.size file1 == 395

    ValuableFile.size file2 == 65813

    ValuableFile.size file3 == 81481

-}
size : ValuableFile -> Int
size (ValuableFile _ file) =
    File.size file


{-| Get the time the file was last modified.

    ValuableFile.lastModified file1 -- 1536872423

    ValuableFile.lastModified file2 -- 860581394

    ValuableFile.lastModified file3 -- 1340375405

Learn more about how time is represented by reading through the
[`elm/time`](/packages/elm/time/latest) package!

-}
lastModified : ValuableFile -> Time.Posix
lastModified (ValuableFile _ file) =
    File.lastModified file
