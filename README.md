# 8 bit virtual machine

Very simple implementation, currently has no stack.

Branching is supported only on input EOF.

# Specification

* 16 registers 8 bit (signed) wide each
* 256 signed byte program memory
* EOF flag register
* 8 bit (unsigned) PC (program counter)

8 bit addressing mode, each execution increments PC by 2. 

Jumps add relative address value to PC.

## Instruction set

Instructions in memory are interleaved in the following manner

| 1 byte | Meaning |
|:------:|:-------:|
| 1 byte | OP Code |
| 1 byte |   Data  |
| 1 byte | OP Code |
| 1 byte |   Data  |
|   ...  |   ...   |

#### Instruction types

##### Data manipulation (1)
| Memory  | 8 bits  | 4 bits | 4 bits |
|:-------:|---------|--------|--------|
| Meaning | OP Code |  Reg2  |  Reg1  |

for `LSL`, `INC`, etc. Register 2 is ignored

##### Control (2)

| Memory  | 8 bits  |      8 bits(signed)          |
|:-------:|---------|------------------------------|
| Meaning | OP Code | JMP address / MOVC constant  |

### Instruction Set

|   Instruction   | OP Code |                                 Comment                                 | Type |
|:---------------:|:-------:|:-----------------------------------------------------------------------:|:----:|
|     INC Reg     |   0x01  | Increments any register referred by Reg                                 |   1  |
|     DEC Reg     |   0x02  | Decrements any register referred by Reg                                 |   1  |
|  MOV Reg1, Reg2 |   0x03  | Copies contents of Reg2 to Reg1                                         |   1  |
| MOVC byte const |   0x04  | Copies byte constant to R0 (first register)                             |   2  |
|     LSL Reg     |   0x05  | Bitwise shift Reg by one to the left                                    |   1  |
|     LSR Reg     |   0x06  | Bitwise shift Reg by one to the right                                   |   1  |
|     JMP addr    |   0x07  | Jump to relative address by adding it to PC                             |   2  |
|     ~~JZ addr~~     |   0x08  | Same as JMP, if zero flag is set                                        |   2  |
|     ~~JNZ addr~~    |   0x09  | Same as JMP, if zero flag is not set                                    |   2  |
|     JFE addr    |   0x0A  | Same as JMP, if EOF flag is set                                         |   2  |
|       RET       |   0x0B  | Exits execution                                                         |      |
|  ADD Reg1, Reg2 |   0x0C  | Adds contents of Reg2 to Reg1, storing in Reg1                          |   1  |
|  SUB Reg1, Reg2 |   0x0D  | Subtracts contents of Reg2 to Reg1, storing in Reg1                     |   1  |
|  XOR Reg1, Reg2 |   0x0E  | Bitwise XOR, stores result in Reg1                                      |   1  |
|  OR Reg1, Reg2  |   0x0F  | Bitwise OR, stores result in Reg1                                       |   1  |
|      IN Reg     |   0x10  | Reads 1 byte from stdin, sets EOF flag if end of file has been reached. |   1  |
|     OUT Reg     |   0x11  | Outputs contents of register Reg to stdout                              |   1  |

# Usage

```
stack build
stack test
stack exec virtualmachine-exe program.bin < input.txt
```

##### Example program

```
stack exec virtualmachine-exe decryptor.bin < encrypted.txt
```
