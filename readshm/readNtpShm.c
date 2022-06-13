/*************************************************************************\
* Copyright (c) 2022 European Spallation Source ERIC
* ecmc is distributed subject to a Software License Agreement found
* in file LICENSE that is included with this distribution. 
*
*  readNtpShm.c
*
*  Created on: June 13, 2022
*      Author: anderssandstrom
*
\*************************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <unistd.h>
#include <string.h>

#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/time.h>


typedef struct {
    int mode;
    int count;

    // The EVR timestamp
    time_t stampSec;
    int stampUsec;

    // The system time when it was acquired
    time_t rxSec;
    int rxUsec;

    int leap;
    int precision;
    int nsamples;
    int valid;
    // Add nano secs
    unsigned        stampNsec;     /* Unsigned ns timestamps */
    unsigned        rxNsec;   /* Unsigned ns timestamps */
    int pad[8];
} shmSegment;

#define NTPD_SEG0 0x4E545030

#define NANOS_PER_SEC 1000000000UL
#define MICROS_PER_SEC 1000000UL

shmSegment* seg;

char time_now_str[35];

int timespec2str(char *buf, uint len, struct timespec *ts) {
    buf[0]=0;
    int ret;
    struct tm t;

    tzset();
    if (localtime_r(&(ts->tv_sec), &t) == NULL)
        return 1;

    ret = strftime(buf, len, "%F %T", &t);
    if (ret == 0)
        return 2;
    len -= ret - 1;

    ret = snprintf(&buf[strlen(buf)], len, ".%09ld", ts->tv_nsec);
    if (ret >= len)
        return 3;

    return 0;
}

static int setup(int segid)
{
    // We don't set IPC_CREAT, but instead wait for NTPD to start and initialize
    // as it wants
    int mode = segid <=1 ? 0600 : 0666;

    int shmid = shmget((key_t)(NTPD_SEG0+segid), sizeof(shmSegment), mode);

    if(shmid==-1) {
        if(errno==ENOENT) {
            perror("ntpshmsetup: shmget");
        }
        return  EXIT_FAILURE;
    }

    seg = (shmSegment*)shmat(shmid, 0, 0);
    if(seg==(shmSegment*)-1) {
        perror("ntpshmsetup: shmat");
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}

int waitForValid(){
  int counter = 0;
  while(!seg->valid && counter<1000) {
    usleep(1000);
    counter++;
  }
  if(counter>=1000) {
    printf("no valid data timeout (1 sec)\n");
    return 1;
  }
  return 0;
}

static inline void timespec_diff(struct timespec *a, struct timespec *b,
    struct timespec *result) {
    result->tv_sec  = a->tv_sec  - b->tv_sec;
    result->tv_nsec = a->tv_nsec - b->tv_nsec;
    if (result->tv_nsec < 0) {
        --result->tv_sec;
        result->tv_nsec += 1000000000L;
    }
}


int printShm(){
  if(seg==NULL) {
    printf("printShm: seg==NULL\n");
    return EXIT_FAILURE;
  }

  if(waitForValid()){
    printf("Wait timeout\n");
    return EXIT_FAILURE;
  }
  
  struct timespec myTime;
  clock_gettime(CLOCK_REALTIME, &myTime);

  struct timespec diff,evr,rx;


  evr.tv_sec=seg->stampSec;
  rx.tv_sec=seg->rxSec;
 
  if(seg->stampUsec == seg->stampNsec/1000) {
    evr.tv_nsec=seg->stampNsec;
  } else {
    evr.tv_nsec=seg->stampUsec*1000;
  }

  if(seg->rxUsec == seg->rxNsec/1000) {
    rx.tv_nsec=seg->rxNsec;
  } else { 
    rx.tv_nsec=seg->rxUsec*1000;
  }

  timespec_diff(&rx,&evr,&diff);


  timespec2str(&time_now_str[0],35, &myTime);

  printf("time now       : %09d s, %09d us, %09d ns\n",myTime.tv_sec,myTime.tv_nsec/1000,myTime.tv_nsec);
  printf("time shm ref   : %09d s, %09d us, %09d ns\n",evr.tv_sec,evr.tv_nsec/1000,evr.tv_nsec);
  printf("time shm rx    : %09d s, %09d us, %09d ns\n",rx.tv_sec,rx.tv_nsec/1000,rx.tv_nsec);    
  printf("diff rx vs ref : %09d ns\n",diff.tv_sec*NANOS_PER_SEC+diff.tv_nsec);
  printf("DIFF %s %d\n",time_now_str,diff.tv_sec*NANOS_PER_SEC+diff.tv_nsec);
 
  
  fflush(stdout);
  return EXIT_SUCCESS;
}

/* main.c */
int main(int argc, char *argv[]){
    float polltime = 0;
    int shmid = 0;
    if(argc >= 2){
      shmid=atoi(argv[1]);
    }
    if(argc == 3){
      polltime=atof(argv[2]);
    }
    if(argc<2 || argc>3) {
        printf("Wrong arg count. Please use :\n");
        printf(" readNtpShm <shmid> <polltime_s>\n");
        printf("       shmid      : sharded memory id (mandatory)\n");
        printf("       polltime_s : poll time in seconds (optional)\n");
    }

    printf("shmid %d\npolltime %f\n",shmid,polltime);
     
    if(setup(shmid)) {
        printf("readNtpShm: Setup failure.");
        return EXIT_FAILURE;
    }

    if(polltime>0) {

      while(1) {

        if(printShm()){
          return EXIT_FAILURE;
        }

        usleep(polltime*1000000);
      }
    } else {
      printShm();
    }
}
