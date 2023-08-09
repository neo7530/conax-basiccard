This directory contains ZeitControl Plug-In Library files (*.LIB) and
library definition files (*.DEF).

Program file
============

LIBVER.EXE   Displays the name and version number of a library file.

RSA Public-Key Cryptography Library
===================================

RSA.DEF      Definition file. #Include this file to load the library.
             This library is valid in Terminal programs, and in Professional
             BasicCard series 4 and 7.

EC-167 Elliptic Curve Library
=============================

EC-167.DEF   Definition file. #Include this file to load the library.
             This library is valid in Terminal programs, and in Series 5
             Professional BasicCards.

EC-161 Elliptic Curve Library
=============================

EC-161.DEF   Definition file. #Include this file to load the library.
EC-161.LIB   Library file. This library is valid in Terminal programs,
             and in Enhanced BasicCards.

Elliptic Curve Definition Files
===============================

EC-p Library
------------
File Curves\brainpoolP384r1.bin is a curve definition file for the EC-p curve
"brainpoolP384r1". In a Terminal program:

  Call ECpSetCurveFromFile ("Curves\brainpoolP384r1.bin")

In a BasicCard program:

  Dir "\"
    #Include "Curves\brainpoolP384r1.def"
  End Dir
  ...
  Call ECpSetCurveFromFile ("brainpoolP384r1")

These examples load the same curve as

  Call ECpSetCurve (11)

(but with fewer pre-computed points, making curve operations a little slower).

Binary Elliptic Curve Libraries
-------------------------------
We provide five different elliptic curves for libraries EC-211 and EC-167,
and three curves for library EC-161. Choose one at random for your application.

Elliptic Curve computations in the BasicCard are speeded up by pre-computing a
number of points on the curve. The more pre-computed points, the faster the
computation, but the more EEPROM is used.

For each curve, we provide definition files with 16, 32, and 64 pre-computed
points (and 128 pre-computed points for library EC-167). If speed is important,
use more pre-computed points; if EEPROM size is restricted, use less pre-
computed points. If unsure, we recommend using 32 pre-computed points in the
Enhanced BasicCard, and 64 pre-computed points in the Professional and
MultiApplication BasicCards.

The definition files are in the Curves sub-directory.

Definition Files for Library EC-211:

Curves\EC211-1.16   Elliptic Curves 1-5, with 16 pre-computed points (slowest)
     through
Curves\EC211-5.16

Curves\EC211-1.32   Elliptic Curves 1-5, with 32 pre-computed points
     through
Curves\EC211-5.32

Curves\EC211-1.64   Elliptic Curves 1-5, with 64 pre-computed points
     through
Curves\EC211-5.64

Curves\EC211-1.128  Elliptic Curves 1-5, with 128 pre-computed points (fastest)
     through
Curves\EC211-5.126

Curves\EC-211.BIN   Curves 1 through 5 in binary format

Curves\EC211CRV.STR Curves 1 through 5 as constant strings, for the Application
                    Loader Section in a MultiApplication BasicCard program

Definition Files for Library EC-167:

Curves\EC167-1.16   Elliptic Curves 1-5, with 16 pre-computed points (slowest)
     through
Curves\EC167-5.16

Curves\EC167-1.32   Elliptic Curves 1-5, with 32 pre-computed points
     through
Curves\EC167-5.32

Curves\EC167-1.64   Elliptic Curves 1-5, with 64 pre-computed points
     through
Curves\EC167-5.64

Curves\EC167-1.128  Elliptic Curves 1-5, with 128 pre-computed points (fastest)
     through
Curves\EC167-5.126

Curves\EC-167.BIN   Curves 1 through 5 in binary format

Curves\EC167CRV.STR Curves 1 through 5 as constant strings, for the Application
                    Loader Section in a MultiApplication BasicCard program

Definition Files for Library EC-161:

Curves\EC161-1.16   Elliptic Curves 1-3, with 16 pre-computed points (slowest)
     through
Curves\EC161-3.16

Curves\EC161-1.32   Elliptic Curves 1-3, with 32 pre-computed points
     through
Curves\EC161-3.32

Curves\EC161-1.64   Elliptic Curves 1-3, with 64 pre-computed points (fastest)
     through
Curves\EC161-3.64

Curves\EC-161.BIN   Curves 1 through 3 in binary format

For backwards compatibility, files EC161-n.32 are duplicated as EC161-n.CRV.


AES Advanced Encryption Standard Library
========================================

AES.DEF      Definition file. #Include this file to load the library.
AES.LIB      Library file

SHA-1 Secure Hash Algorithm Library
===================================

SHA-1.DEF    Definition file. #Include this file to load the library.
SHA-1.LIB    Library file

IDEA International Data Encryption Algorithm Library
====================================================

IDEA.DEF    Definition file. #Include this file to load the library.
IDEA.LIB    Library file

MATH.LIB Mathematical Functions
===============================

MATH.DEF     Definition file. #Include this file to load the library.

MISC.LIB Miscellaneous Procedures
=================================

MISC.DEF     Definition file. #Include this file to load the library.
MISC.LIB     Library file
