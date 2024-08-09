# Assembly Text Editor

## Overview

The **Assembly Text Editor** project is a low-level text editing application implemented in Assembly language. It provides essential text manipulation features with a focus on understanding system-level programming and hardware interaction. This is my final project of assembly course.

## Features

- **File Operations:**
  - **Open/Close Files:** Open existing files and close them after editing.
  - **Save as/save:** Save the current file with a new name or change itself.

- **Text Manipulation:**
  - **Search and Replace:** Find and replace text within the file using regular expressions.
  - **Append:** Add new text to the end of the file.
  - **Insert and Delete:** Insert text at specific positions and delete existing text.
  - **Cursor Management:** Move the cursor and handle text insertion and deletion based on cursor position.

- **Regular Expressions:**
  - Support for basic regular expressions for searching and replacing text.

- **Mode Management:**
  - **Cooked Mode:** Normal text mode with standard input processing.
  - **Raw Mode:** Direct input mode without standard processing.


## Development Notes

- **System Requirements:**
  - Assembly language compiler (NASM)
  - Linux Operating System

- **Important Files:**
  - `Makefile`: Build instructions for compiling and linking the application.

