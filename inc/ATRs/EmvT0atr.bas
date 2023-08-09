Rem  100% EMV compliant T=0 ATR (Basic Response as defined in EMV 3.1.1)
Rem                  for Professional BasicCards
Rem  This ATR gives maximum compliant to EMV specification.
Rem  This can be archived only on cost of performance.
Rem  E.g. this ATR will limit the card to low speed.
Rem  For better performance it is recommended to use T0atr.bas
Rem  instead of this file, when possible. For EMV compliance
Rem  with T0atr.bas use:
Rem  Const WI=10
Rem  #include "T0Atr.bas"

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

#IfNotDef AtrHistory
Const AtrHistory="T=0 ATR"
#EndIf

Const AtrHistoryLen=Len(AtrHistory)
#if AtrHistoryLen>15
#Error AtrHistory to long
#endif

Declare Binary ATR =_
  &H3B,_               ' Direct convention
  &H60+AtrHistoryLen,_ ' T0   : AtrHistoryLen historical chars, TABCD1 follows
  &H00,_               ' TB1  : No programming voltage req.
  &HFF,_               ' TC1  : Waiting time between two chars=12 etu
  AtrHistory,_
  &H01                 ' Flag byte: bit 0 => T=0 supported; don't send LRC
