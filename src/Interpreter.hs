module Interpreter where

import           Control.Monad.State.Strict ( StateT, lift, unless, when )
import           Data.Array.Unboxed         ( (!), (//), accum )
import           Data.Label.Monadic         ( gets, modify, puts )
import           Data.Bits                  ( (.|.), Bits, shift, xor )
import           System.IO                  ( Handle, hGetChar, hIsEOF, hPutChar )

import           VM
import           AST                        ( Instruction(..), toInstruction )

--TODO: Put handles into ReaderT
boot :: Handle -> Handle -> StateT VM IO ()
boot hIn hOut = do
    mem <- gets memory
    pc <- gets programCounter
    let addr = mem ! (pc + 1)
    case toInstruction (mem ! pc) addr of
        Ret -> return ()
        op -> do
            interpret op hIn hOut
            incCounter
            boot hIn hOut

interpret :: Instruction -> Handle -> Handle -> StateT VM IO ()
interpret op hIn hOut = do
    regs <- gets registers
    case op of
        Inc reg -> accumRegister (+) reg 1
        Dec reg -> accumRegister (-) reg 1
        Mov reg1 reg2 -> setRegister reg1 $ regs ! reg2
        Movc addr -> setRegister R0 addr
        Lsl reg -> accumRegister shift' reg 1
        Lsr reg -> accumRegister shift' reg (-1)
        Jmp addr -> addCounter (addr - 2)
        Jz addr -> do
            z <- gets zero
            when z $ addCounter (addr - 2)
        Jnz addr -> do
            z <- gets zero
            unless z $ addCounter (addr - 2)
        Jfe addr -> do
            e <- gets eof
            when e $ addCounter (addr - 2)
        Add reg1 reg2 -> accumRegister (+) reg1 $ regs ! reg2
        Sub reg1 reg2 -> accumRegister (-) reg1 $ regs ! reg2
        Xor reg1 reg2 -> accumRegister xor reg1 $ regs ! reg2
        Or reg1 reg2 -> accumRegister (.|.) reg1 $ regs ! reg2
        In reg -> readChar hIn reg
        Out reg -> display reg hOut

incCounter :: StateT VM IO ()
incCounter = addCounter 2

addCounter :: Address -> StateT VM IO ()
addCounter x = modify programCounter (+ fromIntegral x)

accumRegister :: (Memory -> Memory -> Memory) -> Register -> Memory -> StateT VM IO ()
accumRegister fn reg x =
    modify registers (\regs -> accum fn regs [ (reg, x) ])

setRegister :: Register -> Memory -> StateT VM IO ()
setRegister reg x = modify registers (// [ (reg, x) ])

shift' :: Bits a => a -> Memory -> a
shift' x d = shift x (fromIntegral d)

readChar :: Handle -> Register -> StateT VM IO ()
readChar hIn reg = do
    eofReached <- lift $ hIsEOF hIn
    if eofReached
        then puts eof eofReached
        else do
            char <- lift $ hGetChar hIn
            setRegister reg (fromIntegral (fromEnum char) :: Memory)

display :: Register -> Handle -> StateT VM IO ()
display reg hOut = do
    regs <- gets registers
    let value = fromIntegral (regs ! reg) :: Pointer
    lift $ hPutChar hOut $ toEnum (fromIntegral value)