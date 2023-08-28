Option Explicit

#include Card.def

#IfDef MultiAppBasicCard
  ' This section is required for MultiApplication BasicCards only
  ' it is ignored for Enhanced and Professional BasicCards
  #Include COMPONNT.DEF
  Dir "\"
    Application "DefaultApp" ' Make this the Default Application
      Lock=Execute:Always
  End Dir
#EndIf

#Pragma Allow9XXX
declare binary atr = &h3b, &h24, &h00, &h30, &h42, &h30, &h30, &h1
'declare binary atr = &h3b, &h34, &h94, &h00, &h30, &h42, &h30, &h30, &h1
'declare binary atr = &h3B, &h9F, &h21, &h0E, &h49, &h52, &h44, &h45, &h54, &h4F, &h20, &h41, &h43, &h53, &h20, &h56, &h36, &h2E, &h30, &h9E
'declare binary atr = &h3F, &h77, &h18, &h25, &h00, &h29, &h14, &h00, &h62, &h68, &h90, &h00,1

option base 0
#include ./inc/aes.def
#include ./inc/omac.def
#include ./inc/sha-1.def


Type Service
  serviceid as string*2
  acc as string*4
  bos as string*2
  eos as string*2
  accold as string*4
  bosold as string*2
  eosold as string*2  
  pgmname as string*15
End Type

Eeprom Dynamic ServiceList(10) As Service



public outbuffer as string
public outbuffer2 as string

declare key &h20(16)' Key20 AES
declare key &h21(16)' Key21 AES
declare key &h10(16)' PPUA-KEY
declare key &h11(16)' PPSA-KEY
declare key &h01(16)' SYSTEMKEY
declare key &h99(16)' PERSOKEY

eeprom ppua as string*4
eeprom ppsa as string*4
eeprom maturity as string*1 = &h01
eeprom pincode as string*4 = &h31,&h32,&h33,&h34
eeprom caid as string*2 = &h0b,&h02

#include cardfunctions.def


'#################### COMMANDS ####################

command &hDD &hC6 programminfo(data as string)
outbuffer = ""
  if data = chr$(&h1C,&h01,&h00) then
    call proginfo()
    sw1 = &h98
    sw2 = len(outbuffer)
    if len(outbuffer) = 0 then
      sw1sw2= &h9000
    end if
  else 
    outbuffer = ""
    sw1sw2 = &h9000
  end if

end command

command &hDD &hC2 serial(data as string)
outbuffer = ""
  if data = chr$(&h66,&h00) then
    outbuffer = chr$(&h74,&h04) + ppua
    sw1sw2 = &h9806
  else
    sw1sw2 = &h9000
  end if
end command



command &hDD &h26 sendinfo(data as string)
  if data = chr$(&h10,&h01,&h40) then
    outbuffer = chr$(&h20,&h01,&h40,&h28,&h02) + caid + chr$(&h2f,&h02,&h00,&h31,&h30,&h1)+ maturity + chr$(&h23,&h1,&h5) 'CAS7
    sw1sw2 = &h9811 'CAS7
  else if data = chr$(&h1C,&h01,&h00) then
    call proginfo
    sw1 = &h98
    sw2 = len(outbuffer)
    if len(outbuffer) = 0 then
      sw1sw2= &h9000
    end if
  else 
    outbuffer = ""
    sw1sw2 = &h9000
  end if
end command

command &hDD &h82 get82(data as string*50)
  if lc = &h11 or lc = &h14 then
    outbuffer = chr$(&h22, &h18, &h09, &h04) +_
    data(4)+ data(5) + data(6) + data(7) + chr$(&h23, &h07, &h00, &h00, &h00) +_
    ppua + chr$(&h23, &h07, &h00, &h00, &h00) + ppsa
    sw1sw2 = &h981A
  else
    sw1sw2 = &h9000
  end if
end command 

command &hDD &hCA getdata(data$ as string)
  if len(outbuffer2) > 0 then 
    data$ = outbuffer
    outbuffer = outbuffer2
    outbuffer2 = ""
    sw1 = &h98
    sw2 = len(outbuffer)
  else
    data$ = outbuffer
    outbuffer = ""
  end if 
  if outbuffer = chr$(&h31,&h02,&h00,&h00) then
    sw1sw2 = &h9012
  end if
  if le <> len(data$) then
    data$ = ""
    sw1sw2 = &h9011
  end if
end command

command &hdd &hc8 pin(data$ as string*16)
  private xx as string*4 at data$+6
  private temp as string*4 at data$+2
  private newpin as string*4 at data$+6
  if data$(1) = chr$(&h1F) then
    if temp = pincode then
      if xx <> maturity then
        maturity = xx
      end if
      sw1sw2 = &h9000
    else
      sw1sw2 = &h9017
    end if
  else if data$(1) = chr$(&h1E) then
    if temp = pincode then
      pincode = newpin
    else
      sw1sw2 = &h9017
    end if
  else
    sw1sw2 = &h9011
  end if
end command 


command &hDD &h84 emm(waste as string*8,pp as string*4,waste2 as string*4,data as string,disable le)
 call doemm(pp,data)
end command

command &hDD &hA2 ecm(data as string)
 call doecm(data)
end command

command &hdd &hf1 sha(data$,disable le)
  call initcard(data$)
end command