module LibSpec ( spec ) where

import           Test.Hspec
import           Data.ByteString.Char8      ( pack )
import           Data.Knob
import           Control.Monad.State.Strict ( runStateT, void )
import           Lib                        ( boot, initVm )
import           System.IO

spec :: Spec
spec = describe "Virtual machine integration test" $
    context "given a decryptor program" $ do
        let program = [ 0x04, 0x40, 0x10, 0x01, 0x0a, 0x1a, 0x10, 0x02
                      , 0x10, 0x03, 0x0d, 0x02, 0x0d, 0x03, 0x05, 0x03
                      , 0x05, 0x03, 0x05, 0x03, 0x05, 0x03, 0x0f, 0x32
                      , 0x0e, 0x12, 0x11, 0x02, 0x07, 0xe6, 0x0b, 0x00
                      ]
        it "decrypts an encrypted file" $ do
            let encrypted = "QHAIMCUEGYNBRMCADCQMCWCCSCGA@BQABEECU@CRCCUGBJJFD@CJBBA@BKOCQAGKLCDABJJFFNBJKBTBBILBOOFWEBQDCPACQBCIABWBCT@CQAGUABAIBILBWGGKGBSJCDIBKBBZNB,OEXHGCLBMKBVFGNICFNBKJBJNCRBGELBOKCEEFPICQBBAAF,LEZEC,OEMNCXACMOBCOBNKBCCFKOCDKBKKFWFCUFCWOCQHCYLCQGBYLCAAFJMCSJCKOCJBBXHGMNBXGCM@BSCBJOCKOCDABHJCRBGYMBU@CEFBUMCIGBQNCOCBIFBQFCAHCOCFAAFLMBZFCMICX@CNABXMBLKBAIBBBFVICCMBADBBBFVEBCKBSLCDACKGBFBBDDFIKBU@CYIGABBMLBNLCBGBCEBKNCJFBHHFDCCOFBIMCPHCOOFIJCLICKHBAIBKKFJICAEC,MDMICNKBXECNKBBLBCGC,OEMAFNNFA@B,OEMMFNJCZBCXMC,EEMMFNJCXMCLBBKOBJJFD@CHGBGGFFECO@BILCUKCYMCWGGIICUGBYLCQEBIMCULBAAFLOCKBBSOCJFBJCCFFF.GDXFCMMFZOF.N@,EEMHBXICCACNMCCMFLADKADJBFSIAO@BIABUKCWGGECAO@BIGBUEGYGAE@BYLBIDBUDCYGCQOCYEGAAFLOBSJCMOCS@CQ@CWGGEDGKBGEAGKBGDMF"
            let decrypted = "It would appear that we have reached the limits of what it is possible to achieve with computer technology, although one should be careful with such statements, as they tend to sound pretty silly in 5 years.\r\n(John Von Neumann, circa 1949)"

            knobIn <- newKnob (pack encrypted)
            hIn <- newFileHandle knobIn "stdin" ReadMode

            knobOut <- newKnob (pack [])
            hOut <- newFileHandle knobOut "stdout" WriteMode

            void $ runStateT (boot hIn hOut) (initVm program)

            hClose hIn
            hClose hOut

            bytes <- Data.Knob.getContents knobOut
            bytes `shouldBe` pack decrypted