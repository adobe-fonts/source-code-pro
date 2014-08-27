# Source Code Pro

Source Code Pro is a set of OpenType fonts that have been designed to work well
in user interface (UI) environments. In addition to a functional OpenType font, this open
source project provides all of the source files that were used to build this OpenType font
by using the AFDKO makeotf tool.

## Download the fonts (OTF, TTF, WOFF, EOT)

* [Latest release](../../releases/latest)
* [All releases](../../releases)

## Font installation instructions

* [Mac OS X](http://support.apple.com/kb/HT2509)
* [Windows](http://windows.microsoft.com/en-us/windows-vista/install-or-uninstall-fonts)
* [Linux/Unix-based systems](https://github.com/adobe-fonts/source-code-pro/issues/17#issuecomment-8967116)

## Building the fonts from source

### Requirements

To build the binary font files from source, you need to have installed the
[Adobe Font Development Kit for OpenType](http://www.adobe.com/devnet/opentype/afdko.html) (AFDKO). The AFDKO
tools are widely used for font development today, and are part of most font
editor applications.

### Building one font

The key to building OTF or TTF fonts is `makeotf`, which is part of the AFDKO toolset.  
Information and usage instructions can be found by executing `makeotf -h`.

In this repository, all necessary files are in place for building the OTF and TTF fonts.  
For example, build a binary OTF font for the Regular style like this:

```sh
$ cd Roman/Regular/
$ makeotf -r
```

### Building all fonts

For convenience, a shell script named `build.sh` is provided in the root directory.  
It builds all OTFs and TTFs, and can be executed by typing:

```sh
$ ./build.sh
```

## Getting Involved

Send suggestions for changes to the Source Code OpenType font project maintainer, [Paul D. Hunt](mailto:opensourcefonts@adobe.com?subject=[GitHub] Source Code Pro), for consideration.

## Further information

For information about the design and background of Source Code, please refer to the [official font readme file](http://htmlpreview.github.io/?https://github.com/adobe-fonts/source-code-pro/blob/master/SourceCodeProReadMe.html).
