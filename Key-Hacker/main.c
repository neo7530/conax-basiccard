/**************************************************

file: demo_rx.c
purpose: simple demo that receives characters from
the serial port and print them on the screen,
exit the program by pressing Ctrl-C

compile with the command: gcc demo_rx.c rs232.c -Wall -Wextra -o2 -o test_rx

**************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>

#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

#include "rs232.h"
#include "sha1.h"
#include "aes.h"

unsigned char check;
int   cport_nr, bdrate,serialno,groupid;
uint8_t parsebuf[1024];
unsigned char updatebuffer[1024] = {0};
uint8_t systemkey[16]={0};// = {0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x20,0x21,0x22,0x23,0x24,0x25};

void pen(int duration){
#ifdef _WIN32
    Sleep(duration);
#else
    usleep(duration * 1000);  /* sleep for 100 milliSeconds */
#endif

}

void parse(uint8_t l){
    char buf[20];

    printf("\n############## PARSER ########################");
    for(int i = 0;i<l;i++){
        if(parsebuf[i] == 0x01 && parsebuf[i+1] == 0x0f){
            printf("NAME: ");
            memcpy(&buf[0],&parsebuf[i+2],15);
            printf("%s",buf);
            i += 16;
        }
        if(parsebuf[i] == 0x28 && parsebuf[i+1] == 0x02){
            printf("\nCAID: %02X%02X",parsebuf[i+2],parsebuf[i+3]);
            i += 2;
        }
        if(parsebuf[i] == 0x32 && parsebuf[i+1] == 0x2F){
            printf("\nService-ID: %02X%02X\n",parsebuf[i+2],parsebuf[i+3]);
            i += 2;
        }
        if(parsebuf[i] == 0x30 && parsebuf[i+1] == 0x02){
            printf("DATE: %02X%02X ",parsebuf[i+2],parsebuf[i+3]);
            i += 2;
        }
        if(parsebuf[i] == 0x20 && parsebuf[i+1] == 0x04){
            printf("ACCESS: %02X%02X%02X%02X ",parsebuf[i+2],parsebuf[i+3],parsebuf[i+4],parsebuf[i+5]);
            i += 4;
        }
        if(parsebuf[i] == 0x23 && parsebuf[i+1] == 0x07){
            printf("\nPPUA/SA: %02X%02X%02X%02X ",parsebuf[i+5],parsebuf[i+6],parsebuf[i+7],parsebuf[i+8]);
            i += 7;
        }
        if(parsebuf[i] == 0x30 && parsebuf[i+1] == 0x01){
            printf("\nMaturity: %02X ",parsebuf[i+2]);
            i += 1;
        }
        if(parsebuf[i] == 0x23 && parsebuf[i+1] == 0x01){
            printf("\nSessions: %02X ",parsebuf[i+2]);
            i += 1;
        }
        if(parsebuf[i] == 0x2F && parsebuf[i+1] == 0x02){
            printf("\nLanguage Code: %d ",parsebuf[i+3]);
            i += 2;
        }
    }
    memset(parsebuf,0,1024);
    printf("\n##############################################\n\n");

}



void command(char *cmd,char *data, int pause){
    uint16_t l=cmd[4],x,r;
    unsigned char buf[4096] = {0};
    char rsponse[5] = {0xdd,0xca,0x00,0x00,0x00};

    RS232_SendBuf(cport_nr,cmd,5);
    printf("=> ");
    pen(20);
    RS232_SendBuf(cport_nr,data,l);
    pen(pause);
    for(int i = 0;i<6+l+2;i++){
        RS232_PollComport(cport_nr, buf, 4095);
        printf("%02x ",buf[i]);
        r |= buf[i-1];
        r <<= 8;
        r |= buf[i];
    }
do{
    if(r > 0x9800){
        printf("\n");
        rsponse[4] = l = r & 255;
        RS232_SendBuf(cport_nr,rsponse,5);
        printf("<= ");
        pen(pause);
        for(int i = 0;i<6+l+2;i++){
            RS232_PollComport(cport_nr, buf, 4095);
            printf("%02x ",buf[i]);
            parsebuf[i] = buf[i];
            r |= buf[i-1];
            r <<= 8;
            r |= buf[i];
        }
        parse(6+l+2);
        }
    printf("\n");
}while(r != 0x9000 && r != 0x9011 && r != 0x9017);
}

void init(void){
    int n,i;
    unsigned char buf[4096];
    RS232_disableRTS(cport_nr); // reset
    pen(100);
    printf("Reset OK - ATR:  ");
while(n < 2){
    n = RS232_PollComport(cport_nr, buf, 4095);
    if(n > 0)
    {
      buf[n] = 0;   /* always put a "null" at the end of a string! */

      for(i=0; i < n; i++)
      {
        printf("%02X ",buf[i]);
      }
    }
}
    readsyskey();
    printf("\n\nInit OK \n\n\n");

}

void readsyskey(){

    //union _key _syskey;

	FILE *fp = fopen("syskey.txt","rt");
	uint8_t fileopen = 0;
	char tkey[100] = {0};
	int idx = 0;

	if (fp == NULL) {
       	fprintf(stderr, "Can't read syskey.txt.\n\n");
    } else {
		fprintf(stderr, "syskey.txt opened\n\n");
		fileopen = 1;
	}

	if(fileopen){

			fgets(tkey,60,fp);
            printf("SYSTEM-Key: \n");
			for(idx = 0;idx < 16;idx++){
				sscanf(&tkey[idx*3],"%hhx",&systemkey[idx]);
				printf("%02X ",systemkey[idx]);
				//syskey[idx] = _systemkey._bkey[idx];
			}
			if(feof(fp))fclose(fp);
            printf("\n\n");
		}

	fclose(fp);
}


int main(int argc , char *argv[])
{

    if(argc <= 1){
        printf("Parameter missing. Exiting...\n");
        return(0);
    }

    //cport_nr=strtoul(argv[1],NULL,0);/* /dev/ttyS0 (COM1 on windows) */
    bdrate=9600;       /* 9600 baud */

    char mode[]={'8','E','2',0};
    uint8_t tempkey[16],cmac[16];

    SHA1_CTX sha;
    unsigned char *buf;
    int n;
    uint8_t index;
    char cmd[5] = "\xdd\xF1\x00\x00\x03";

    for(int i = 1;i<argc;i++){
        if(!strcmp(argv[i],"--port")){
            cport_nr=strtoul(argv[i+1],NULL,0);
        }
        if(!strcmp(argv[i],"--ppua")){
            serialno=strtoul(argv[i+1],NULL,0);
        }
        if(!strcmp(argv[i],"--ppsa")){
            groupid=strtoul(argv[i+1],NULL,0);
        }
        if(!strcmp(argv[i],"--pass")){
            index = i+1;
        }

    }



uint8_t emmbuffer[0x50] ={
    0x12, 0x4E, 0x82, 0x70, 0x4B, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x70, 0x42, 0x64, 0x10,
    0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC,
    0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC,
    0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC,
    0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC
};

    union _emm{
        uint8_t in[0x30];
        uint32_t _xt[6][2];
    } emm;

  if(RS232_OpenComport(cport_nr, bdrate, mode, 0))
  {
    printf("Can not open comport\n");
    return(0);
  }
    init();


    command("\xdd\x82\x00\x00\x14","\x11\x12\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x09\x04\x0B\x00\xFF\xFF\xFF\xFF\xFF\xFF",500);
    command("\xdd\x26\x00\x00\x03","\x69\x01\x00",500);
    command("\xdd\x26\x00\x00\x03","\x10\x01\x40",500);
    command("\xdd\x26\x00\x00\x03","\x1c\x01\x00",500);


    printf("NEW DATA FOR THIS CARD:\n##############################################\n");
    printf("NEW PPUA: %d\t%08X\n",serialno,serialno);
    printf("NEW PPSA: %d\t%08X\n",groupid,groupid);
    printf("NEW TRANSPORT SECRET:\t%s\n",argv[index]);


    printf("\n\n!!! IF YOU PROCEED, YOU WILL ERASE YOUR CARD !!!\n");
    printf("\n\n!!! PRESS ENTER FOR PROCEED OR CTRL+C FOR ABORT !!!\n");
    getchar();

    buf = argv[index];
    n = strlen(buf);
    SHA1Init(&sha);
    SHA1Update(&sha, (uint8_t *)buf, n);
    SHA1Final((uint8_t *)tempkey, &sha);

    AES_CMAC(tempkey,buf,strlen(buf),cmac);

    // SEND PERSOKEY TO CARD
    strcat(&updatebuffer[0],argv[index]);
    strcat(&updatebuffer,(char*)&cmac);

    cmd[4] = strlen(argv[index])+16;


    command(cmd,updatebuffer,500);

    memset(emm.in,0xcc,0x30);
    int idx = 0;
    emm.in[idx] = 0xa0; idx++;
    emm.in[idx] = 0x00; idx++;
    emm.in[idx] = serialno >> 24 & 255; idx++;
    emm.in[idx] = serialno >> 16 & 255; idx++;
    emm.in[idx] = serialno >> 8 & 255; idx++;
    emm.in[idx] = serialno & 255; idx++;
    emm.in[idx] = 0xa0; idx++;
    emm.in[idx] = 0x02; idx++;
    emm.in[idx] = groupid >> 24 & 255; idx++;
    emm.in[idx] = groupid >> 16 & 255; idx++;
    emm.in[idx] = groupid >> 8 & 255; idx++;
    emm.in[idx] = groupid & 255; idx++;
    emm.in[idx] = 0xa0; idx++;
    emm.in[idx] = 0x22; idx++;
    memcpy(&emm.in[idx],&systemkey,16);

    AES_CMAC(tempkey,emm.in,0x30,cmac);
    aes_cbc(tempkey,emm.in,0x30);

    memcpy(&emmbuffer[0x10],&emm.in,0x30);
    memcpy(&emmbuffer[0x40],&cmac,16);

    command("\xDD\x84\x00\x00\x50",emmbuffer,1000);
    //command("\xdd\x26\x00\x00\x03","\x1c\x01\x00",500);

    return(0);
}
