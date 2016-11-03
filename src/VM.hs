{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}

module VM where

import           Data.Word          ( Word8 )
import           Data.Int           ( Int8 )
import           Data.Array.Unboxed ( Ix, UArray, listArray )
import           Data.Label         ( mkLabel )

type Pointer = Word8

type Address = Int8

type Memory = Int8

data Register = R0 | R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9 | R10 | R11 | R12 | R13 | R14 | R15
    deriving (Enum, Show, Ord, Eq, Ix)

data VM = VM { _registers      :: UArray Register Memory
             , _programCounter :: Pointer
             , _memory         :: UArray Pointer Memory
             , _eof            :: Bool
             , _zero           :: Bool
             }
    deriving Show

mkLabel ''VM

initVm :: [Memory] -> VM
initVm withMem = VM { _registers = listArray (R0, R15) (repeat 0)
                    , _programCounter = 0
                    , _memory = listArray (0, 0xFF) withMem
                    , _eof = False
                    , _zero = False
                    }