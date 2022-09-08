/*************************************************************************\
* Copyright (c) 2022 European Spallation Source ERIC
* ecmc is distributed subject to a Software License Agreement found
* in file LICENSE that is included with this distribution. 
*
*  readHwTstamp.c
*
*  Created on: June 28, 2022
*      Author: anderssandstrom
*
\*************************************************************************/
#include <unistd.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/ip.h>
#include <net/if.h>
#include <linux/ethtool.h>
#include <linux/sockios.h>
#include <linux/net_tstamp.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>

struct interface {
    int     index;
    int     flags;      /* IFF_UP etc. */
    long    speed;      /* Mbps; -1 is unknown */
    int     duplex;     /* DUPLEX_FULL, DUPLEX_HALF, or unknown */
    char    name[IF_NAMESIZE + 1];
};

static int get_nic_hw_stamp(const int fd) {
  struct timespec ts;
  int ret = 0;


  /* set socket options for time stamping */
  //if (so_timestamp &&
  //    setsockopt(sock, SOL_SOCKET, SO_TIMESTAMP,
  //           &enabled, sizeof(enabled)) < 0)
  //    bail("setsockopt SO_TIMESTAMP");

   // Try timestamping
  int flags   = SOF_TIMESTAMPING_TX_HARDWARE
              | SOF_TIMESTAMPING_RX_HARDWARE 
              | SOF_TIMESTAMPING_TX_SOFTWARE
              | SOF_TIMESTAMPING_RX_SOFTWARE 
              | SOF_TIMESTAMPING_RAW_HARDWARE;
  
  //ret = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING,
  //                  &flags, sizeof(flags));
//
  //printf("setsockopt                   : (ret = %d)\n",ret);

/* set socket options for time stamping */
  int enabled = 1;
   
  ret = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMP,
              &enabled, sizeof(enabled));
  printf("setsockopt                   : (ret = %d)\n",ret);
   
  ret = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPNS,
              &enabled, sizeof(enabled));       
   printf("setsockopt                   : (ret = %d)\n",ret);
  ret = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING,
              &flags,
              sizeof(flags));
  printf("setsockopt                   : (ret = %d)\n",ret);
       
  
  ret = ioctl(fd, SIOCGSTAMPNS, &ts);
  printf("SIOCGSTAMPNS                 : %lld s %.9ld ns (ret = %d)\n", (long long)ts.tv_sec,ts.tv_nsec,ret);
  memset(&ts,0,sizeof(ts));
  ret = ioctl(fd, SOF_TIMESTAMPING_RX_HARDWARE, &ts);
  printf("SOF_TIMESTAMPING_RX_HARDWARE : %lld s %.9ld ns (ret = %d)\n", (long long)ts.tv_sec,ts.tv_nsec,ret);
  memset(&ts,0,sizeof(ts));
  ret = ioctl(fd, SOF_TIMESTAMPING_TX_HARDWARE, &ts);
  printf("SOF_TIMESTAMPING_TX_HARDWARE : %lld s %.9ld ns (ret = %d)\n", (long long)ts.tv_sec,ts.tv_nsec,ret);
  memset(&ts,0,sizeof(ts));
  //if (ioctl(fd, SOF_TIMESTAMPING_RX_HARDWARE, ) == -1) {
  //  //error
  //}

  //ok
  return ret;
}

static int get_interface_common(const int fd, struct ifreq *const ifr, struct interface *const info)
{
    struct ethtool_cmd  cmd;
    int                 result;

    /* Interface flags. */
    if (ioctl(fd, SIOCGIFFLAGS, ifr) == -1)
        info->flags = 0;
    else
        info->flags = ifr->ifr_flags;

    ifr->ifr_data = (void *)&cmd;
    cmd.cmd = ETHTOOL_GSET; /* "Get settings" */
    if (ioctl(fd, SIOCETHTOOL, ifr) == -1) {
        /* Unknown */
        info->speed = -1L;
        info->duplex = DUPLEX_UNKNOWN;
    } else {
        info->speed = ethtool_cmd_speed(&cmd);
        info->duplex = cmd.duplex;
    }

    // Test
    result = get_nic_hw_stamp(fd);
    //if(result != 0) {
    //  return errno;
    //}

    do {
        result = close(fd);
    } while (result == -1 && errno == EINTR);
    if (result == -1)
        return errno;

    return 0;
}

int get_interface_by_index(const int index, struct interface *const info)
{
    int             socketfd, result;
    struct ifreq    ifr;

    if (index < 1 || !info)
        return errno = EINVAL;

    socketfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);

    if (socketfd == -1)
        return errno;

    ifr.ifr_ifindex = index;
    if (ioctl(socketfd, SIOCGIFNAME, &ifr) == -1) {
        do {
            result = close(socketfd);
        } while (result == -1 && errno == EINTR);
        return errno = ENOENT;
    }

    info->index = index;
    strncpy(info->name, ifr.ifr_name, IF_NAMESIZE);
    info->name[IF_NAMESIZE] = '\0';

    return get_interface_common(socketfd, &ifr, info);
}

int get_interface_by_name(const char *const name, struct interface *const info)
{
    int             socketfd, result;
    struct ifreq    ifr;

    if (!name || !*name || !info)
        return errno = EINVAL;

    socketfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    if (socketfd == -1)
        return errno;

    strncpy(ifr.ifr_name, name, IF_NAMESIZE);
    if (ioctl(socketfd, SIOCGIFINDEX, &ifr) == -1) {
        do {
            result = close(socketfd);
        } while (result == -1 && errno == EINTR);
        return errno = ENOENT;
    }

    info->index = ifr.ifr_ifindex;
    strncpy(info->name, name, IF_NAMESIZE);
    info->name[IF_NAMESIZE] = '\0';

    return get_interface_common(socketfd, &ifr, info);
}

int main(int argc, char *argv[])
{
    struct interface    iface;
    int                 arg;
    int                 status = 0;

    if (argc > 1 && (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help"))) {
        fprintf(stderr, "\n");
        fprintf(stderr, "Usage: %s { -h | --help }\n", argv[0]);
        fprintf(stderr, "       %s\n", argv[0]);
        fprintf(stderr, "       %s INTERFACE ...\n", argv[0]);
        fprintf(stderr, "\n");
        return 1;
    }

    if (argc > 1) {
        for (arg = 1; arg < argc; arg++) {
            if (get_interface_by_name(argv[arg], &iface) != 0) {
                fprintf(stderr, "%s: No such interface.\n", argv[arg]);
                status = 1;
                continue;
            }

            printf("%s: Interface %d", iface.name, iface.index);
            if (iface.flags & IFF_UP)
                printf(", up");
            if (iface.duplex == DUPLEX_FULL)
                printf(", full duplex");
            else
            if (iface.duplex == DUPLEX_HALF)
                printf(", half duplex");
            if (iface.speed > 0)
                printf(", %ld Mbps", iface.speed);
            printf("\n");
        }

    } else {
        for (arg = 1; ; arg++) {
            if (get_interface_by_index(arg, &iface) != 0)
                break;

            printf("%s: Interface %d", iface.name, iface.index);
            if (iface.flags & IFF_UP)
                printf(", up");
            if (iface.duplex == DUPLEX_FULL)
                printf(", full duplex");
            else
            if (iface.duplex == DUPLEX_HALF)
                printf(", half duplex");
            if (iface.speed > 0)
                printf(", %ld Mbps", iface.speed);
            printf("\n");
        }
    }

    return status;
}
