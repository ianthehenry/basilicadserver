module Main (main) where

import           BasePrelude hiding (app, intercalate)
import           Control.Monad.Trans (liftIO)
import qualified Data.Configurator as Conf
import           Data.Text.Lazy (Text)
import qualified Data.Text.Lazy as Text
import qualified Data.Text.Lazy.IO as Text
import           Network.Wai (Application)
import qualified Network.Wai as Wai
import qualified Network.Wai.Handler.Warp as Warp
import           System.Directory (getDirectoryContents)
import           System.FilePath ((<.>), (</>))
import           System.Random (getStdRandom, randomR)
import           Web.Scotty

app :: IO Application
app = scottyApp $
  get "/" $ do
    (url, filePath) <- liftIO randomFile
    setHeader "X-Url" url
    setHeader "Content-Type" "image/png"
    file filePath

type Ad = (Text, FilePath)

randomFile :: IO Ad
randomFile = do
  directories <- (\\ [".", ".."]) <$> getDirectoryContents "./ads"
  dir <- (directories !!) <$> getStdRandom (randomR (0, length directories - 1))
  url <- Text.strip <$> (Text.readFile ("./ads" </> dir </> "url"))
  return (url, "./ads" </> dir </> "image.png")

main :: IO ()
main = do
  conf <- Conf.load [Conf.Required "conf"]
  port <- Conf.require conf "port"
  putStrLn $ "Running on port " ++ show port
  Warp.run port =<< app
