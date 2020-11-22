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

'  Execution starts here

' Wait for a card
Call WaitForCard()
' Reset the card and check status code SW1SW2
ResetCard : Call CheckSW1SW2()
Public Data$ as string
public send$ as string


call sendinfo(chr$(&h69,1,0)) : call respond()

call sendinfo(chr$(&h10,1,&h40)) : call respond()

call getdata(LC=0,data$,LE=laenge) : Call CheckSW1SW2()

' Call the command to write data and check the status
Call programminfo(chr$(&h1C,1,0,1)) : Call respond()
call getdata(LC=0,data$,LE=laenge) : Call respond() '31
call getdata(LC=0,data$,LE=laenge) : Call respond()

call get82(lc = &h11,chr$(&h11, &h0F, &h01, &h0B, &h00, &h0F, &hE0, &hFB, &h00, &h00, &h09, &h04, &h0B, &h00, &hE0, &h30, &h2B)) : call respond()

call getdata(LC=0,data$,LE=laenge) : Call CheckSW1SW2()


dim mac$ as string*16
dim leadin$ as string
'key(&h99) = chr$(10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)' PERSOKEY
'key(&h99) = chr$(&hA9,&h4A,&h8F,&hE5,&hCC,&hB1,&h9B,&hA6,&h1C,&h4C,&h08,&h73,&hD3,&h91,&hE9,&h87)
key(&h01) = chr$(&h10,&h11,&h12,&h13,&h14,&h15,&h16,&h17,&h18,&h19,&h20,&h21,&h22,&h23,&h24,&h25) ' SYSTEMKEY
key(&h20) = chr$(&hbb,&haa,&h99,&h88,&h77,&h66,&h55,&h44,&hff,&hee,&hdd,&hcc,&h33,&h22,&h11,&h00) 'key20
key(&h21) = chr$(&h77,&h66,&h55,&h44,&hbb,&haa,&h99,&h88,&h33,&h22,&h11,&h00,&hff,&hee,&hdd,&hcc) 'key21
dim ppua as string*4 = chr$(&h04,&hc4,&hb4,0)
dim ppsa as string*4 = chr$(&h00,&h11,&h22,&h33)
dim pgmname as string*15 = chr$(&h4E,&h65,&h6F,&h56,&h69,&h73,&h69,&h6F,&h6E,&h20,&h20,&h20,&h20,&h20,&h20)
dim acc as string*4 = chr$(&h1f,&hff,&hff,&hff)
dim serviceid as string*2 = chr$(&h10,&h10)
dim bos as string*2 = chr$(&h61,&h01)
dim eos as string*2 = chr$(&h7f,&h0C)

'################ old ECMS ################
'data$ = (chr$(&h14,&h38,&h00,&h80,&h70,&h34,&h70,&h32,&h64,&h20,&h5D,&h06,&hB3,&hFD,&h34,&hDA,&hA9,&h34,&h88,&h10,&hFC,&h37,&h56,&h54,&h9A,&hD8,&hD9,&h69,&h51,&hA4,&h80,&h2F,&h27,&h6F,&h39,&h6E,&h8E,&hA2,&h7A,&h1E,&hF0,&hA1,&hD7,&hC2,&h6D,&hC5,&h00,&hAF,&h99,&h42,&hE4,&h0B,&h50,&h32,&h39,&h00,&h16,&h64))
'call ecm(LC=&h3a,data$) : call respond
'call getdata(LC=0,data$,LE=laenge) : call respond

'data$ = (chr$(&h14,&h48,&h00,&h80,&h70,&h44,&h70,&h42,&h64,&h20,&h5D,&h06,&hB3,&hFD,&h34,&hDA,&hA9,&h34,&h88,&h10,&hFC,&h37,&h56,&h54,&h9A,&hD8,&hD9,&h69,&h51,&hA4,&h80,&h2F,&h27,&h6F,&h39,&h6E,&h8E,&hA2,&h7A,&h1E,&hF0,&hA1,&h60,&hAA,&hD5,&hFF,&h62,&h69,&h5C,&hFE,&hE9,&h33,&hF6,&hAA,&h39,&hE0,&hC3,&h7C,&h7E,&h9C,&h84,&h38,&h00,&hC0,&h07,&hA4,&hC8,&hEC,&h2F,&h0A,&h2F,&h94,&h9E,&h3f))
'call ecm(LC=&h4a,data$) : call respond
'call getdata(LC=0,data$,LE=laenge) : call respond


'################ CALCULATED ECM WITH NEW KEY ################
leadin$ = chr$(&h14,&h48,&h00,&h80,&h70,&h44,&h70,&h42,&h64,&h20)
'data$ = chr$(&h20,&h04,&h61,&h0c,&h00,&h00,&h40,&h0f,&h11,&h12,&h13,&h14,&h15,&h16,&h17,&h18,&h01,&h02,&h03,&h04,&h05,&h06,&h07,&h08,&hcc,&hcc,&hcc,&h21,&h02,&h10,&h10,&hcc,&hcc,&hcc,&hcc,&hcc,&h22,&h04,&h00,&h00,&h00,&h02,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc)
data$ = chr$(&h20,&h04,&h61,&h0c,&h00,&h00,&h40,&h0f,&h11,&h12,&h13,&h14,&h15,&h16,&h17,&h18,&h01,&h02,&h03,&h04,&h05,&h06,&h07,&h08,&h21,&h02,&h10,&h10,&h22,&h04,&h00,&h00,&h00,&h02,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc)
mac$ = omac(128,key(&h20),data$)

call aes_cbc_e(data$,&h20)

send$ = leadin$ + data$ + mac$
call ecm(LC=len(send$),send$) : call respond
call getdata(LC=0,data$,LE=laenge) : call respond


'################ hash update PERSOKEY 99 and delete all services + PPUA ################
dim hashtest as string
hashtest = shahash("test")

mac$ = omac(128,hashtest,"test")

'call sha("test"+mac$):resetcard:call cardinfo()

'################ PERSONALIZE PPUA + SYSTEM-KEY ################
leadin$ = chr$(&h12,&h4E,&h82,&h70,&h4B,&h00,&h00,&h00)
data$ = chr$(&ha0,&h00,&h04,&hc4,&hb4,&h00,&ha0,&h22,&h10,&h11,&h12,&h13,&h14,&h15,&h16,&h17,&h18,&h19,&h20,&h21,&h22,&h23,&h24,&h25,&ha0,&h02,&h00,&h11,&h22,&h33,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC,&hCC)
key(&h99) = shahash("test")

mac$ = omac(128,key(&h99),data$)
call aes_cbc_e(data$,&h99)
data$ = data$ + mac$

'call emm(leadin$,chr$(&hff,&hff,&hff,&hff),chr$(&h70,&h42,&h64,&h10),data$):resetcard:call cardinfo()

'################ CREATE PROVIDER EMM ################
leadin$ = chr$(&h12,&h4E,&h82,&h70,&h4B,&h00,&h00,&h00)
data$ = chr$(&ha0,&h00,&h04,&hc4,&hb4,&h00,&ha0,&h10,&h4E,&h65,&h6F,&h56,&h69,&h73,&h69,&h6F,&h6E,&h20,&h20,&h20,&h20,&h20,&h20,&h44,&ha0,&h01,&h10,&h10,&ha0,&h03,&h61,&h0B,&h7f,&h0C,&ha0,&h04,&h00,&h00,&h00,&h02,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc)

key(&h10) = omac(128,key(&h01),ppua)
dim test as string*16, i as byte
test = omac(128,key(1),ppua)


mac$ = omac(128,key(&h10),data$)
call aes_cbc_e(data$,&h10)
data$ = data$ + mac$

call emm(leadin$,ppua,chr$(&h70,&h42,&h64,&h10),data$)

'################ UPDATE KEY 20 + 21 ################
leadin$ = chr$(&h12,&h4E,&h82,&h70,&h4B,&h00,&h00,&h00)
data$ = chr$(&ha0,&h02,&h00,&h11,&h22,&h33,&h44,&hA0,&h20,&hbb,&haa,&h99,&h88,&h77,&h66,&h55,&h44,&hff,&hee,&hdd,&hcc,&h33,&h22,&h11,&h00,&ha0,&h21,&h77,&h66,&h55,&h44,&hbb,&haa,&h99,&h88,&h33,&h22,&h11,&h00,&hff,&hee,&hdd,&hcc,&hcc,&hcc,&hcc,&hcc,&hcc) 

key(&h11) = omac(128,key(&h01),ppsa)
'key(&h11) = chr$(&h0A,&hD9,&hCE,&h18,&h06,&h58,&hA9,&h5F,&h6A,&h44,&hD1,&h34,&hF0,&h0F,&hF1,&hAD)
test = omac(128,key(1),ppsa)

mac$ = omac(128,key(&h11),data$)
call aes_cbc_e(data$,&h11)
data$ = data$ + mac$

call emm(leadin$,ppsa,chr$(&h70,&h42,&h64,&h10),data$)

'################ CREATE 2nd PROVIDER EMM ################
leadin$ = chr$(&h12,&h4E,&h82,&h70,&h4B,&h00,&h00,&h00)
data$ = chr$(&ha0,&h00,&h12,&h34,&h56,&h78,&ha0,&h10,&h4E,&h65,&h6F,&h56,&h69,&h73,&h69,&h6F,&h6E,&h31,&h20,&h20,&h20,&h20,&h20,&ha0,&h01,&h10,&h1E,&ha0,&h03,&h61,&h11,&h7f,&h11,&ha0,&h04,&h00,&h00,&h00,&hff,&ha0,&h02,&h00,&h11,&h22,&h33,&hcc,&hcc,&hcc)

key(&h10) = omac(128,key(&h01),ppua)

test = omac(128,key(1),ppua)

mac$ = omac(128,key(&h10),data$)
call aes_cbc_e(data$,&h10)
data$ = data$ + mac$

call emm(leadin$,ppua,chr$(&h70,&h42,&h64,&h10),data$)

'############### test emm

data$ = chr$(&h14,&h48,&h00,&h80,&h70,&h44,&h70,&h42,&h64,&h20,&h22,&h54,&h17,&h78,&h4A,&hBC,&hDE,&h5E,&h03,&h62,&h31,&hA6,&hFF,&h6E,&h25,&h31,&h05,&h16,&hED,&h7A,&hEB,&h31,&hBC,&hCC,&h87,&h75,&hEF,&hC1,&hE2,&hD2,&hA3,&hE8,&hB9,&hA7,&hDD,&hA7,&h27,&hCC,&hE0,&hAB,&hAF,&h79,&h49,&h61,&hAC,&h8F,&h8E,&hCB,&hCB,&h92,&h80,&h93,&hEF,&h26,&hA4,&h37,&h9C,&h6E,&h70,&hC4,&h59,&h1D,&h76,&h99)
call ecm(LC=len(data$),data$) : call respond
call getdata(LC=0,data$,LE=laenge) : call respond

