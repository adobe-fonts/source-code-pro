# Source Code Pro

[Source Code Pro](http://adobe-fonts.github.io/source-code-pro/)
is a set of OpenType fonts that have been designed to work well
in user interface (UI) environments.

## Getting involved

[Open an issue](https://github.com/adobe-fonts/source-code-pro/issues) or send a suggestion to Source Code's designer [Paul D. Hunt](mailto:opensourcefonts@adobe.com?subject=[GitHub]%20Source%20Code%20Pro), for consideration.

## Releases

* [Latest release](../../releases/latest)
* [All releases](../../releases)

## Building the fonts from source

### Requirements

To build the binary font files from source, you need Python 3 along with the
[Adobe Font Development Kit for OpenType](https://github.com/adobe-type-tools/afdko/) (AFDKO) and
[FontTools](https://github.com/fonttools/fonttools) packages, which you can install with

```sh
pip3 install afdko fonttools fs
```

### Building one font

The key to building the OTF fonts is `makeotf`, which is part of the AFDKO toolset.
Information and usage instructions can be found by executing `makeotf -h`. The TTFs
are generated with the `otf2ttf` and `ttfcomponentizer` tools.

Commands to build the Regular style OTF font:

```sh
cd Roman/Instances/Regular/
makeotf -r -gs -omitMacNames
```

Commands to generate the Regular style TTF font:

```sh
otf2ttf SourceCodePro-Regular.otf
ttfcomponentizer SourceCodePro-Regular.ttf
```

### Building all non-variable fonts

For convenience, a shell script named **build.sh** is provided in the root directory.
It builds all OTFs and TTFs into a directory called **target/**. It can be executed by typing:

```sh
./build.sh
```

or this on Windows:

```sh
build.cmd
```

### Building the variable fonts

To build the variable TTFs you must install **fontmake** using this command:

```sh
pip3 install fontmake
```

A shell script named **buildVFs.sh** is provided in the root directory.
It generates four variable fonts (two CFF2-OTFs and two TTFs), and can be executed by typing:

```sh
./buildVFs.sh
```
