# 8 bit virtual machine

Very simple implementation, currently has no stack.

Branching is supported only on input EOF.

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
