
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <unistd.h>

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
  while(!seg->valid || counter<1000) {
    usleep(1000);
    counter++;
  }
  if(counter>=1000) {perror("no valid data timeout (1 sec)"); return 1;}
  return 0;
}

int printShm(){
  if(seg==NULL) {
    perror("printShm: seg==NULL");
    return EXIT_FAILURE;
  }

  if(waitForValid){
    return EXIT_FAILURE;
  }
  
  struct timespec myTime;
  clock_gettime(CLOCK_REALTIME, &myTime);


  int diffS=0;
  unsigned diffU=0;
  unsigned diffN=0;
  
  diffS=seg->rxSec-seg->stampSec;
  
  if(seg->stampUsec == seg->stampNsec/1000 && seg->rxUsec == seg->rxNsec/1000) {
    if (seg->stampNsec > seg->rxNsec) {
      diffN=(NANOS_PER_SEC-seg->stampNsec)+seg->rxNsec;
      diffS=diffS-1;
    } else {
      diffN=seg->rxNsec-seg->stampNsec;
    }
    diffU=diffN/1000;
  } else {
    if (seg->stampUsec > seg->rxUsec) {
      diffU=(MICROS_PER_SEC-seg->stampUsec)+seg->rxUsec;
      diffS=diffS-1;
    } else {
      diffU=seg->rxNsec-seg->stampNsec;
    }
    diffN=diffU*1000;
  }


  printf("time now       : %09d s, %09d us, %09d ns\n",myTime.tv_sec,myTime.tv_nsec/1000,myTime.tv_nsec);
  if(seg->stampUsec == seg->stampNsec/1000) {
    printf("time shm ref   : %09d s, %09d us, %09d ns\n",seg->stampSec,seg->stampUsec,seg->stampNsec);
  } else {
    printf("time shm ref   : %09d s, %09d us, %09d ns\n",seg->stampSec,seg->stampUsec,seg->stampUsec*1000);    
  }
  if(seg->rxUsec == seg->rxNsec/1000) {
    printf("time shm rx    : %09d s, %09d us, %09d ns\n",seg->rxSec,seg->rxUsec,seg->rxNsec);    
  }  else {
    printf("time shm rx    : %09d s, %09d us, %09d ns\n",seg->rxSec,seg->rxUsec,seg->rxUsec*1000);
  }
   printf("diff rx vs ref : %09d s, %09d us, %09d ns\n",diffS,diffU,diffN);
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

    printf("shmid %d,polltime %f\n",shmid,polltime);
     
    if(setup(shmid)) {
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
