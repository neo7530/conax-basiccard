Rem  T=0 ATR for Professional BasicCards

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

#IfDef EnhancedBasicCard
#Error T=0 is not supported by Enhanced BasicCards
#EndIf

#Message Warning: Usage of #include T0ATR.bas is deprecated please uses #pragma ATR(T=0) instead.

#IfNotDef AtrHistory
Const AtrHistory="T=0 ATR"
#EndIf

Const AtrHistoryLen=Len(AtrHistory)
#if AtrHistoryLen>15
#Error AtrHistory to long
#endif

Rem  T=0 uses WWT (Work Waiting Time) instead of BWT
Rem  WWT = 960 * WI FI/f 
Rem  -> WWT about WI * 0.1 seconds, e.g. WI=&H80=128 -> WWT about 12.8s
Rem  To change work waiting time define a constant WI before 
Rem  #Including this file, with:
Rem  Const WI=<n>
Rem  or on the ZCMBASIC command line with parameter:
Rem
Rem     -DWI=<n>
Rem
Rem  <n> can take the values from 16 to 255
Rem
Rem  Example
Rem     <n>      WWT
Rem      10      1.0s    (Required by EMV)
Rem      16      1.6s
Rem      128     12.8s


#IfNotDef WI
Const WI = &H80
#endif

#if WI>255
#Error WI to big
#endif

#if WI<16
#Error WI to small
#endif

#IfDef InverseProt
Const TS=&H3F          ' Inverse convention for ZC5.4 Rev B or above only
#Message Warning you have selected inverse convention
#else
Const TS=&H3B          ' Direct convention
#endif

Declare Binary ATR =_
  TS,_                 ' Direct or inverse convention
  &HF0+AtrHistoryLen,_ ' T0   : AtrHistoryLen historical chars, TABCD1 follows
  &H10+DI,_            ' TA1  : FI = 1, DI as defined
  &H00,_               ' TB1  : No programming voltage req.
  &HFF,_               ' TC1  : Waiting time between two chars=12 etu
  &H40,_               ' TD1  : TC2 follows      - T=0 indication
  WI,_                 ' TC2  : Work Waiting Time = (default) 12.8 seconds
  AtrHistory,_
  &H01                 ' Flag byte: bit 0 => T=0 supported; don't send LRC
