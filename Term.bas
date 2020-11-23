Rem BasicCard Sample Source Code Template
Rem ------------------------------------------------------------------
Rem Copyright (C) 2008 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------
Option Explicit
Public laenge as byte
#include Card.def
#Include ./inc/COMMANDS.DEF
#Include ./inc/COMMERR.DEF
#include ./inc/MISC.DEF
#Include ./inc/CARDUTIL.DEF
#include ./inc/aes.def
#include myfunctions.def
#include ./inc/omac.def
#include ./inc/sha-1.def


key(&h01) = chr$(&h10,&h11,&h12,&h13,&h14,&h15,&h16,&h17,&h18,&h19,&h20,&h21,&h22,&h23,&h24,&h25) ' SYSTEMKEY
key(&h20) = chr$(&hbb,&haa,&h99,&h88,&h77,&h66,&h55,&h44,&hff,&hee,&hdd,&hcc,&h33,&h22,&h11,&h00) 'key20
key(&h21) = chr$(&h77,&h66,&h55,&h44,&hbb,&haa,&h99,&h88,&h33,&h22,&h11,&h00,&hff,&hee,&hdd,&hcc) 'key21

dim ppua as string*4 = chr$(&h04,&hc4,&hb4,0)
dim ppsa as string*4 = chr$(&h00,&h11,&h22,&h33)
dim serial as long at ppua
dim group as long at ppsa

dim acc as string*4 = chr$(&h1f,&hff,&hff,&hff)
dim serviceid as string*2
dim bos as string*2 = chr$(&h61,&h01)
dim eos as string*2 = chr$(&h7f,&h0C)
dim servicename as string

dim cw1 as string*8
dim cw0 as string*8
dim conaxdate as string*4
dim shastring as string

'  Execution starts here

' Wait for a card
Call WaitForCard()
' Reset the card and check status code SW1SW2
ResetCard : Call CheckSW1SW2()


call cardinfo

'########################## INIT CARD ##########################
serial = 80000000
group = 999999
shastring = "das ist ein langer test"
call initcard(shastring,ppua,ppsa)

'########################## CREATE PROVIDER ##########################
serviceid = chr$(&h10,&h10)
servicename = "NeoVision"
call createprovider(ppua,serviceid,bos,eos,servicename,acc,ppsa)

'########################## CREATE 2nd PROVIDER ##########################
serviceid = chr$(&h10,&h1F)
servicename = "TESLA-1"
call createprovider(ppua,serviceid,bos,eos,servicename,acc,ppsa)

'########################## UPDATE KEYS VIA SHARED EMM ##########################
call keyupdate(ppsa)

'########################## GENARATE EMM ##########################
cw1 = chr$(&h11,&h12,&h13,&h14,&h15,&h16,&h17,&h18)
cw0 = chr$(&h01,&h02,&h03,&h04,&h05,&h06,&h07,&h08)
conaxdate = chr$(&h61,&h0c,0,0)
acc = chr$(0,0,0,2)
call emmg(&h20,conaxdate,cw1,cw0,serviceid,acc)