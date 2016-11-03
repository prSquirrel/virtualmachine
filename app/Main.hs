module Main where

import qualified Data.ByteString            as BS
import           System.IO                  ( stdin, stdout )
import           System.Environment         ( getArgs )
import           Control.Monad.State.Strict ( runStateT, void )

import           Lib                        ( boot, initVm )

main :: IO ()
main = do
    args <- getArgs
    bs <- BS.readFile (head args)
    let bytes = map fromIntegral (BS.unpack bs)
    void $ runStateT (boot stdin stdout) (initVm bytes)