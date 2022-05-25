#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NANO 1000000000L

// buf needs to store 30 characters
int timespec2str(char *buf, uint len, struct timespec *ts) {
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


main()
{
  struct timespec mono,real;
  const uint TIME_FMT = strlen("2012-12-31 12:59:59.123456789") + 1;
  char timestr[TIME_FMT];

  clock_gettime( CLOCK_REALTIME, &real);
  clock_gettime( CLOCK_MONOTONIC, &mono);
  
  //CLOCK_REALTIME
  if (timespec2str(timestr, sizeof(timestr), &real) != 0) {
    printf("timespec2str failed!\n");
    return EXIT_FAILURE;
  } else {
    unsigned long resol = real.tv_sec * NANO + real.tv_nsec;
    printf("CLOCK_REALTIME:  %s (raw=%ld ns)\n", timestr,resol);
  }

  //CLOCK_MONOTONIC
  if (timespec2str(timestr, sizeof(timestr), &mono) != 0) {
    printf("timespec2str failed!\n");
    return EXIT_FAILURE;
  } else {
    unsigned long resol = mono.tv_sec * NANO + mono.tv_nsec;
    printf("CLOCK_MONOTONIC: %s (raw=%ld ns)\n", timestr,resol);
  }

  return EXIT_SUCCESS;
}
