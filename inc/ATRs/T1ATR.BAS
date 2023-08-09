Rem  T=1 ATR for Professional BasicCards

Rem  To specify the maximum baud rate that the card will run at, define
Rem  the DI parameter in the ATR. You can do this in the source before
Rem  #Including this file, with:
Rem
Rem     Const DI=<n>
Rem
Rem  or on the ZCMBASIC command line with parameter:
Rem
Rem     -DDI=<n>
Rem
Rem  <n> can take the following values:
Rem
Rem     <n>    Baud rate
Rem      1        9600
Rem      2       19200
Rem      3       38400
Rem
Rem  Note that the DI parameter only tells the card reader what the card is
Rem  capable of; it is up to the reader to decide what speed to run at, up
Rem  to this limit.

#Message Warning: Usage of #include T1ATR.bas is deprecated please uses #pragma ATR(T=1) instead.

#IfNotDef DI ' DI defaults to 3, i.e. 38400 baud
Const DI = 3
#EndIf

Rem  To use different ATR history bytes define a constant
Rem  AtrHistory before #including this file, with:
Rem  Const AtrHistory="Text"
Rem  or on the ZCMBASIC command line with parameter:
Rem
Rem     -DAtrHistory="Text"
Rem
Rem  "Text" is a text constant of with maximum length of 15 bytes
Rem
Rem  Example
Rem  Const AtrHistory="MyOwnCard"

#IfNotDef AtrHistory
Const AtrHistory="T=1 ATR"
#EndIf

Const AtrHistoryLen=Len(AtrHistory)
#if AtrHistoryLen>15
#Error AtrHistory to long
#endif

Rem  We cannot use #BWT with Declare Binary ATR.
Rem  To change BWT define a constant BWI before 
Rem  #Including this file, with:
Rem  Const BWI=<n>
Rem  or on the ZCMBASIC command line with parameter:
Rem
Rem     -DBWI=<n>
Rem
Rem  <n> can take the values from 0 to 9
Rem
Rem     <n>      BWT
Rem      0       0.1s   (dangerous do not use this)
Rem      1       0.2s   (dangerous do not use this)
Rem      2       0.4s   (dangerous do not use this)
Rem      3       0.8s
Rem      4       1.6s
Rem      5       3.2s   (not allowed by EMV spec)
Rem      6       6.4s   (not allowed by EMV spec)
Rem      7       12.8s  (not allowed by EMV spec)
Rem      8       25.6s  (not allowed by EMV spec)
Rem      9       51.2s  (not allowed by EMV spec)


#IfNotDef BWI
Const BWI = 7
#endif

#if BWI>9
#Error BWI to big
#endif

#if BWI<3
#Message BWI to small, you risk destroying your card when loading this image.
#endif

#IfDef InverseProt
Const TS=&H3F          ' Inverse convention for ZC5.4 Rev B or above only
#Message Warning you have selected inverse convention
#else
Const TS=&H3B          ' Direct convention
#endif

#IfDef EnhancedBasicCard
#If CardMajorVersion=3 AND CardMinorVersion>10
Const TC1=&H00
#else
Const TC1=&HFF
#EndIf
#Else
Const TC1=&HFF
#EndIf

#IfDef EnhancedBasicCard
Declare Binary ATR =_
  TS,_                 ' Direct or inverse convention
  &HF0+AtrHistoryLen,_ ' T0   : AtrHistoryLen historical chars, TABCD1 follows
  &H10+DI,_            ' TA1  : FI = 1, DI as defined
  &H00,_               ' TB1  : No programming voltage req.
  TC1,_                ' TC1  : Waiting time between two chars=11 etu
  &H81,_               ' TD1  : TD2 follows      - T=1 indication
  &H31,_               ' TD2  : TA3, TB3 follows - T=1 indication
  &H20,_               ' TA3  : T=1 ICC Information Field Size
  &H05+(BWI*&H10),_    ' TB3  : T=1 Block Waiting Time, Character Waiting Time
  AtrHistory
#Else
Declare Binary ATR =_
  TS,_                 ' Direct or inverse convention
  &HF0+AtrHistoryLen,_ ' T0   : AtrHistoryLen historical chars, TABCD1 follows
  &H10+DI,_            ' TA1  : FI = 1, DI as defined
  &H00,_               ' TB1  : No programming voltage req.
  TC1,_                ' TC1  : Waiting time between two chars=11 etu
  &H81,_               ' TD1  : TD2 follows      - T=1 indication
  &H31,_               ' TD2  : TA3, TB3 follows - T=1 indication
  &H80,_               ' TA3  : T=1 ICC Information Field Size
  &H05+(BWI*&H10),_    ' TB3  : T=1 Block Waiting Time, Character Waiting Time
  AtrHistory,_
  &H06       ' Flag byte: bit 1 => T=1 supported, bit 2 => send LRC
#EndIf
