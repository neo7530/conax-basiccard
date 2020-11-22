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
declare binary atr = &h3b, &h34, &h94, &h00, &h30, &h42, &h30, &h30, &h1
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
eeprom caid as string*2 = &h0b,&h00

'#################### FUNCTIONS #######################

function xor128(byref out as string*16,byref in as string*16)
  private x as long at out+0
  private x1 as long at out+4
  private x2 as long at out+8
  private x3 as long at out+12
  private y as long at in+0
  private y1 as long at in+4
  private y2 as long at in+8
  private y3 as long at in+12
  x = x xor y
  x1 = x1 xor y1
  x2 = x2 xor y2
  x3 = x3 xor y3 
end function

function aes_cbc_d(byref data$ as string,skip as byte,rounds as byte,emm as byte)
  private cw0 as string*16
  private cbc as string*16
  private cbcn as string*16
  private i as byte
  private j as byte
  private temp$ as string

  for i = 0 to rounds-1
      for j = 1 to 16
        cw0(j) = data$(skip+(i*16+j))
      next j
      cbc = cbcn
      cbcn = cw0
      if emm > 0 then
        cw0 = aes(-128,key(emm),cw0)
      else
        cw0 = aes(-128,key(asc(data$(10))),cw0)
      end if
      call xor128(cw0,cbc)
      temp$ = temp$ + cw0
    next i
    
  data$ = temp$
end function

'function aes_cbc_enc(byref data$ as string,skip as byte)
'  dim cw0 as string*16
'  dim iv as string*16
'  dim i as byte
'  dim j as byte
'  dim temp$ as string

'  for i = 0 to 2
'    for j = 1 to 16
'      cw0(j) = data$(skip+(i*16+j))
'    next j
'    call xor128(cw0,iv)
'    cw0 = aes(+128,key(asc(data$(10))),cw0)
'    iv = cw0
'    temp$ = temp$ + cw0
'  next i

'data$ = temp$
'end function

'#################### COMMANDS ####################

command &hDD &hC6 programminfo(data as string)
private i as byte
outbuffer = ""
  if data = chr$(&h1C,&h01,&h00) then
for i = 0 to 9
  if ServiceList(i).serviceid = chr$(0,0) then
  else
    if len(outbuffer) < &hf0 then
      outbuffer = outbuffer + chr$(&h32,&h2F) + ServiceList(i).serviceid + chr$(&h01,&h0f)+_
      ServiceList(i).pgmname + chr$(&h30,&h02) + ServiceList(i).bos + chr$(&h30,&h02) + ServiceList(i).eos + chr$(&h20,&h04) + ServiceList(i).acc +_
      chr$(&h30,&h02) + ServiceList(i).bosold + chr$(&h30,&h02) + ServiceList(i).eosold + chr$(&h20,&h04) + ServiceList(i).accold
    else
      outbuffer2 = outbuffer2 + chr$(&h32,&h2F) + ServiceList(i).serviceid + chr$(&h01,&h0f)+_
      ServiceList(i).pgmname + chr$(&h30,&h02) + ServiceList(i).bos + chr$(&h30,&h02) + ServiceList(i).eos + chr$(&h20,&h04) + ServiceList(i).acc +_
      chr$(&h30,&h02) + ServiceList(i).bosold + chr$(&h30,&h02) + ServiceList(i).eosold + chr$(&h20,&h04) + ServiceList(i).accold
    end if
  end if
next i
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

command &hDD &h26 sendinfo(data as string)
private i as byte
  if data = chr$(&h10,&h01,&h40) then
    outbuffer = chr$(&h20,&h01,&h40,&h28,&h02) + caid + chr$(&h2f,&h02,&h00,&h31,&h30,&h1)+ maturity + chr$(&h23,&h1,&h5)
    sw1sw2 = &h9811
  else if data = chr$(&h1C,&h01,&h00) then
for i = 0 to 4
  if ServiceList(i).serviceid = chr$(0,0) then
  else
    if len(outbuffer) < &hF0 then
      outbuffer = outbuffer + chr$(&h32,&h2F) + ServiceList(i).serviceid + chr$(&h01,&h0f)+_
      ServiceList(i).pgmname + chr$(&h30,&h02) + ServiceList(i).bos + chr$(&h30,&h02) + ServiceList(i).eos + chr$(&h20,&h04) + ServiceList(i).acc +_
      chr$(&h30,&h02) + ServiceList(i).bosold + chr$(&h30,&h02) + ServiceList(i).eosold + chr$(&h20,&h04) + ServiceList(i).accold
    else
      outbuffer2 = outbuffer2 + chr$(&h32,&h2F) + ServiceList(i).serviceid + chr$(&h01,&h0f)+_
      ServiceList(i).pgmname + chr$(&h30,&h02) + ServiceList(i).bos + chr$(&h30,&h02) + ServiceList(i).eos + chr$(&h20,&h04) + ServiceList(i).acc +_
      chr$(&h30,&h02) + ServiceList(i).bosold + chr$(&h30,&h02) + ServiceList(i).eosold + chr$(&h20,&h04) + ServiceList(i).accold
    end if
  end if
next i
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
private i as byte, check as string, cmac as string*16
private ppuatest as string*4
private ppsatest as string*4
private acctest as string*4
private nameupdate as string*15
private idtest as string*2
private starttest as string*2
private stoptest as string*2
private newpin as string*4
private key20test as string*16
private key21test as string*16
private syskeytest as string*16
private rounds as byte,j as byte,pers as byte
private updatesyskey as byte = 0
private idx as byte = 0
private zeroidx as byte = 0
private zerofound as byte = 0
private servicefound as byte = 0
private updc = 0
private deleteprovider = 0
private updateppsa = 0

rounds = (len(data)-16) / 16

  for i = len(data)-15 to len(data)
    check = check + data(i)
  next i

if pp = chr$(255,255,255,255) then
    call aes_cbc_d(data,0,rounds,&h99)
    cmac = omac(128,key(&h99),data)
    pers = 1
  else if pp = ppua then
    pers = 0
    call aes_cbc_d(data,0,rounds,&h10)
    cmac = omac(128,key(&h10),data)
  else if pp = ppsa then
    pers = 0
    call aes_cbc_d(data,0,rounds,&h11)
    cmac = omac(128,key(&h11),data)
  else
    sw1sw2 = &h9011
    exit command
  end if

if check = cmac then
  for i = 1 to len(data)
    if data(i) = chr$(&ha0) and data(i+1) = chr$(&h00) then
      i = i + 2
      for j = 1 to 4
        ppuatest(j) = data(i)
        i = i + 1
      next j
      i = i - 1
      updc = updc + 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&h01) then
      i = i + 2
      idtest(1) = data(i):i = i + 1
      idtest(2) = data(i)
      updc = updc + 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&hff) then
      i = i + 2
      deleteprovider = 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&h02) then
      i = i + 2
      for j = 1 to 4
        ppsatest(j) = data(i)
        i = i + 1
      next j
      updateppsa = 1
      i = i - 1
      updc = updc + 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&h04) then
      i = i + 2
      for j = 1 to 4
        acctest(j) = data(i)
        i = i + 1
      next j
      i = i - 1
      updc = updc + 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&h03) then
      i = i + 2
      starttest(1) = data(i):i = i + 1
      starttest(2) = data(i):i = i + 1    
      stoptest(1) = data(i):i = i + 1
      stoptest(2) = data(i)
      updc = updc + 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&h22) then
      i = i + 2
      for j = 1 to 16
        syskeytest(j) = data(i)
        i = i + 1
      next j
      i = i - 1
      updatesyskey = 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&h20) then
      i = i + 2
      for j = 1 to 16
        key20test(j) = data(i)
        i = i + 1
      next j
      i = i - 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&h21) then
      i = i + 2
      for j = 1 to 16
        key21test(j) = data(i)
        i = i + 1
      next j
      i = i - 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&h10) then
      i = i + 2
      for j = 1 to 15
        nameupdate(j) = data(i)
        i = i + 1
      next j
      i = i - 1
      updc = updc + 1
    else if data(i) = chr$(&ha0) and data(i+1) = chr$(&h80) then
      i = i + 2
      for j = 1 to 4
        newpin(j) = data(i)
        i = i + 1
      next j
      i = i - 1
      pincode = newpin
    end if
  next i
  
  if pers = 1 then
    if ppuatest <> ppua then
      ppua = ppuatest
      key(&h10) = omac(128,key(1),ppua)
    end if
    if syskeytest <> key(1) and updatesyskey = 1 then
      key(1) = syskeytest
      key(&h10) = omac(128,key(1),ppua)
    end if
    if ppsatest <> ppsa then
      ppsa = ppsatest
      key(&h11) = omac(128,key(1),ppsa)
    end if
  end if

if pp = ppua and pp = ppuatest then
  for i = 0 to 9
    if servicelist(i).serviceid = idtest then
      idx = i
      servicefound = 1
      exit for
    else if servicelist(i).serviceid = chr$(0,0) and zerofound = 0 then
      zeroidx = i
      zerofound = 1
    end if
  next i
  
  if servicefound = 1 and updc >= 4 and deleteprovider = 0 then
    if servicelist(idx).pgmname <> nameupdate then
      servicelist(idx).pgmname = nameupdate
    end if
    if servicelist(idx).bos <> starttest or servicelist(idx).eos <> stoptest then
      servicelist(idx).bosold = servicelist(idx).bos
      servicelist(idx).bos = starttest
      servicelist(idx).eosold = servicelist(idx).eos
      servicelist(idx).eos = stoptest
      servicelist(idx).accold = servicelist(idx).acc
      servicelist(idx).acc = acctest
    end if
    if updateppsa = 1 and ppsatest <> ppsa then
      ppsa = ppsatest
      key(&h11) = omac(128,key(1),ppsa)
    end if
    if servicelist(idx).acc <> acctest then
      servicelist(idx).acc = acctest
    end if
  else if servicefound = 1 and deleteprovider = 1 then
    servicelist(idx).bos = ""
    servicelist(idx).bosold = ""
    servicelist(idx).serviceid = ""
    servicelist(idx).eos = ""
    servicelist(idx).eosold = ""
    servicelist(idx).acc = ""
    servicelist(idx).accold = ""
    servicelist(idx).pgmname = ""
  else if servicefound = 0 and zerofound = 1 and deleteprovider = 0 then
    if updateppsa = 1 and ppsatest <> ppsa then
      ppsa = ppsatest
      key(&h11) = omac(128,key(1),ppsa)
    end if
    servicelist(zeroidx).acc = acctest
    servicelist(zeroidx).bos = starttest
    servicelist(zeroidx).eos = stoptest
    servicelist(zeroidx).serviceid = idtest
    servicelist(zeroidx).pgmname = nameupdate
  end if
else if pp = ppsa and pp = ppsatest then
  if key20test <> key(&h20) then
    key(&h20) = key20test
  end if
  if key21test <> key(&h21) then
    key(&h21) = key21test
  end if
end if

else
  sw1sw2 = &h9017
end if
end command

command &hDD &hA2 ecm(data as string)
outbuffer =""

private cw0 as string*8
private cw1 as string*8
private i as byte,j as byte
private rounds as byte
private check as string
private ki as byte
private cmac as string*16

private idt as string*2
private idok as byte = 0
private accok as byte = 0
private timeok as byte = 0

private acctest as string*4
private accservice as string*4
private acctestbin as long at acctest
private accservicebin as long at accservice

private timestart as string*2
private timeend as string*2
private timetest as string*2
private timetestbin as integer at timetest
private timestartbin as integer at timestart
private timeendbin as integer at timeend

rounds = (len(data)-26) / 16
ki = asc(data(10))

  for i = len(data)-15 to len(data)
    check = check + data(i)
  next i

  call aes_cbc_d(data,10,rounds,0)
  cmac = omac(128,key(ki),data)

if check = cmac then
  for i = 1 to len(data)
    if data(i) = chr$(&h20) and data(i+1) = chr$(&h04) then
      i = i + 2
        timetest(1) = data(i+1)
        timetest(2) = data(i)
      i = i + 3
    end if
    
    if data(i) = chr$(&h21) and data(i+1) = chr$(&h02) then
      idt(1) = data(i+2)
      idt(2) = data(i+3)
      i = i + 2
    end if
    
    if data(i) = chr$(&h22) and data(i+1) = chr$(&h04) then
      i = i + 2
      for j = 1 to 4
        acctest(j) = data(i)
        i = i + 1
      next j
      i = i - 1
    end if
    
    if data(i) = chr$(&h40) and data(i+1) = chr$(&h0F) then
      i = i + 2
      for j = 1 to 8
        cw1(j) = data(i)
        cw0(j) = data(8 + i)
        i = i + 1
      next j
      i = i - 1
    end if

  next i

  for i = 0 to 4
    if ServiceList(i).serviceid = idt then
      idok = 1
      accservice = ServiceList(i).acc 
        if (acctestbin and accservicebin) >= 1 then
          accok = 1
          timestart(2) = servicelist(i).bos(1)
          timestart(1) = servicelist(i).bos(2)
          timeend(2) = servicelist(i).eos(1)
          timeend(1) = servicelist(i).eos(2)
          if timetestbin >= timestartbin and timetestbin <= timeendbin then
            timeok = 1
          else
            timeok = 0
          end if
        else
          accok = 0
        end if
      exit for
    else
      idok = 0
    end if
  next i
end if

if idok = 1 and accok = 1 and timeok = 1 then    
    outbuffer = chr$(&h25,&h0D,&h00,&h00,&h01,&h00,&h00) +_
    cw1 + chr$(&h25,&h0D,&h00,&h00,&h00,&h00,&h00) +_
    cw0 + chr$(&h31,&h02,&h40,0)
    sw1 = &h98
    sw2 = len(outbuffer)
  else
    outbuffer = chr$(&h31,&h02,&h00,&h00)
    sw1sw2 = &h9804
  end if
end command

command &hdd &hf1 sha(data$,disable le)
private hashtest as string
private i as byte
private testkey as string*16
private check as string
private cmac as string

  for i = len(data$)-15 to len(data$)
    check = check + data$(i)
  next i

  for i = 1 to len(data$)-16
    hashtest = hashtest + data$(i)
  next i 

  testkey = shahash(hashtest)
  cmac = omac(128,testkey,hashtest)
  
  if cmac = check then
    key(&h99) = testkey
    ppua = ""
    ppsa = ""
    key(&h20) = ""
    key(&h21) = ""
    key(&h01) = ""
    key(&h10) = ""
    key(&h11) = ""
    for i = 0 to 9
      servicelist(i).pgmname = ""
      servicelist(i).serviceid = ""
      servicelist(i).acc = ""
      servicelist(i).accold = ""
      servicelist(i).bos = ""
      servicelist(i).bosold = ""
      servicelist(i).eos = ""
      servicelist(i).eosold = ""
    next i
  else 
    sw1sw2 = &h9011
  end if
end command