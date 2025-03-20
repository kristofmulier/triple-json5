# triple-json5

Do you love JSON5, but you hate to put all string values on a single line?

Well, you can spread string values over multiple lines in JSON5, but it's far from elegant (you need to escape each line with a `\`).

Wouldn't it be much easier if you could use python-style triple-quoted strings? Welcome to the **triple-json5** file - aka **tjson5**.

This repo is a VSCode extension to provide syntax highlighting and LSP (Language Server Protocol) processing for `.tjson5` files in VSCode. An example of a `.tjson5` file:

```json5
{
  // This is a single line comment
  /*
    This is a multiline comment
  */
  "key1": """this is a single line string""",
  "key2": """
    this is a multiline string
  """,
  "key3": "foo",    // String value
  "key4": 1010,     // Decimal number
  "key5": 0b0101,   // Binary number
  "key6": 0xBEEF,   // Hex number
  "key7": "foobar", // Trailing comma allowed
}
```

I based this project on the following MIT-licensed repos:

- The syntax highlighting is based on https://github.com/mrmlnc/vscode-json5
- The LSP (Language Server Protocol) is based on https://github.com/microsoft/vscode-json-languageservice

# Usage

* Clone this repo: `git clone https://github.com/kristofmulier/triple-json5`.

* Open VSCode.

* Open the **Extensions** tab on the left.

* Click the three dots `...` in the top-right corner of the **Extensions** tab, then select `"Install from VSIX..."` in the dropdown.

* Select the `triple-json5-1.0.0.vsix` file from this repo.

* Open a `.tjson5` file and check if the language in VSCode switches to `Triple JSON5`:
  
  <img src="https://github.com/user-attachments/assets/a123df23-6887-4a1c-a57a-b3d307af9264" width="600">


# License

This software is released under the terms of the MIT license.
