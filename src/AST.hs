module AST where

import           VM        ( Address, Memory, Register )
import           Data.Bits ( (.&.), shiftR )

data Instruction = Inc Register
                 | Dec Register
                 | Mov Register Register
                 | Movc Memory
                 | Lsl Register
                 | Lsr Register
                 | Jmp Address
                 | Jz Address
                 | Jnz Address
                 | Jfe Address
                 | Ret
                 | Add Register Register
                 | Sub Register Register
                 | Xor Register Register
                 | Or Register Register
                 | In Register
                 | Out Register

toInstruction :: Memory -> Memory -> Instruction
toInstruction code addr =
    case code of
        0x01 -> Inc reg1
        0x02 -> Dec reg1
        0x03 -> Mov reg1 reg2
        0x04 -> Movc addr
        0x05 -> Lsl reg1
        0x06 -> Lsr reg1
        0x07 -> Jmp addr
        0x08 -> Jz addr
        0x09 -> Jnz addr
        0x0A -> Jfe addr
        0x0B -> Ret
        0x0C -> Add reg1 reg2
        0x0D -> Sub reg1 reg2
        0x0E -> Xor reg1 reg2
        0x0F -> Or reg1 reg2
        0x10 -> In reg1
        0x11 -> Out reg1
  where
    (reg2, reg1) = split addr

split :: Memory -> (Register, Register)
split x = (left, right)
  where
    left = toEnum . fromIntegral $ x `shiftR` 4
    right = toEnum . fromIntegral $ x .&. 0xF