Rem  100% EMV compliant T=1 ATR (Basic Response as defined in EMV 3.1.1)
Rem                  for Professional BasicCards
Rem  This ATR gives maximum compliant to EMV specification.
Rem  This can be archived only on cost of performance.
Rem  E.g. this ATR will limit the card to low speed.
Rem  For better performance it is recommended to use T1atr.bas
Rem  instead of this file, when possible. For EMV compliance
Rem  with T1atr.bas use:
Rem  Const BWI=4
Rem  #include "T1Atr.bas"

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
Const BWI = 4
#endif

#if BWI>9
#Error BWI to big
#endif

#if BWI<3
#Message BWI to small, you risk destroying your card when loading this image.
#endif

#if BWI>4
#Error BWI exceeds EMV specification
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
  &H3B,_               ' Direct convention
  &HE0+AtrHistoryLen,_ ' T0   : AtrHistoryLen historical chars, TABCD1 follows
  &H00,_               ' TB1  : No programming voltage req.
  TC1,_                ' TC1  : Waiting time between two chars=11 etu (FF) or 12 etu (00)
  &H81,_               ' TD1  : TD2 follows      - T=1 indication
  &H31,_               ' TD2  : TA3, TB3 follows - T=1 indication
  &H20,_               ' TA3  : T=1 ICC Information Field Size
  &H05+(BWI*&H10),_    ' TB3  : T=1 Block Waiting Time, Character Waiting Time
  AtrHistory
#else
Declare Binary ATR =_
  &H3B,_               ' Direct convention
  &HE0+AtrHistoryLen,_ ' T0   : AtrHistoryLen historical chars, TABCD1 follows
  &H00,_               ' TB1  : No programming voltage req.
  TC1,_                ' TC1  : Waiting time between two chars=11 etu (FF) or 12 etu (00)
  &H81,_               ' TD1  : TD2 follows      - T=1 indication
  &H31,_               ' TD2  : TA3, TB3 follows - T=1 indication
  &H80,_               ' TA3  : T=1 ICC Information Field Size
  &H05+(BWI*&H10),_    ' TB3  : T=1 Block Waiting Time, Character Waiting Time
  AtrHistory,_
  &H06       ' Flag byte: bit 1 => T=1 supported, bit 2 => send LRC  
#EndIf  


