# Lexer For G++

This repository contains the implementation of a lexer for a programming language using Flex for the first part and Common Lisp for the second part. The lexer is designed to tokenize input code into various types of tokens, such as operators, keywords, identifiers, and values.

## Part 1: Flex Lexer
## Usage

To compile the Flex lexer, you can use the provided makefile. There are two options for compiling:

1. Terminal input
```bash

make
```
This command compiles the lexer, and you can then provide input directly through the terminal.

2. File input
```bash
make < input_file
```
This command compiles the lexer and takes the input from the specified file `(input_file)`.

## Error Handling

The lexer includes error messages for unexpected characters or syntax, providing informative messages before terminating the program.


## Part 2: Lisp Lexer
## Usage

To run the Lisp lexer implemented in Common Lisp, use the following command:

```bash
sbcl --script gpp_lexer.lisp
```

## Description

The Lisp lexer (gpp_lexer.lisp) uses Common Lisp and runs the lexer script with Steel Bank Common Lisp (SBCL). The script tokenizes the input code and prints the corresponding token types to the terminal.

## Conclusion

This project demonstrates the implementation of a lexer using Flex and Common Lisp for a simple programming language. The lexer successfully tokenizes input code, providing insights into the lexical analysis of the given programming language.

Feel free to reach out if you have any questions or encounter issues with the lexer implementation. Good coding! 🚀