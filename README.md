Source Code Pro
====

Overview
----
Source Code Pro is a set of OpenType fonts that have been designed to work well
in user interface (UI) environments. In addition to a functional OpenType font, this open
source project provides all of the source files that were used to build this OpenType font
by using the AFDKO makeotf tool.

Getting Involved
----
Send suggestions for changes to the Source Code OpenType font project maintainer,
phunt@adobe.com, for consideration.

Building
====

Pre-built font binaries
----
The font binaries are not part of the source files. They are available on [SourceForge](https://sourceforge.net/projects/sourcecodepro.adobe/files/).


Requirements
----

For building binary font files from source, installation of the [Adobe Font Development Kit for OpenType](http://www.adobe.com/devnet/opentype/afdko.html) (AFDKO) is necessary. The AFDKO tools are widely used for font development today, and are part of most font editor applications.

Building one font
----

Key to building OTF or TTF fonts is `makeotf`, which is part of the AFDKO toolset.  
Information and usage instructions can be found by executing `makeotf -h`.

In this repository, all necessary files are in place for building the OTF and TTF fonts.  
For example, build a binary OTF font for the Regular style like this:

	$ cd Roman/Regular/
    $ makeotf -r


Building all fonts
----

For convenience, a shell script named `build.sh` is provided in the root directory.  
It builds all OTFs and TTFs, and can be executed by typing:

	$ ./build.sh


Installing
====

[Font Installation Instructions for Windows and Mac](http://www.adobe.com/type/browser/fontinstall/instructions_english.html)

[Font Installation Instructions for Unix-based systems](https://github.com/adobe/source-code-pro/issues/17#issuecomment-8967116)

