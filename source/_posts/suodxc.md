---
title: 联创OS任务——多线程和锁
date: 2019-12-19 14:52:25
tags:
- 多线程
- 锁
categories:
- OS
---
扔完代码就跑

<!--more-->

socket通信
```c
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
char ss[150000], names[55];
int main() {
    int sockfd;
    sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    struct sockaddr_in serverAddr;
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(2333);
    serverAddr.sin_addr.s_addr=inet_addr("222.20.101.2");
    bzero(&(serverAddr.sin_zero), 8);
    while(connect(sockfd,(struct sockaddr*)&serverAddr,sizeof(struct sockaddr)) == -1);
    printf("Connected successfully\n");
    // send(sockfd, "hello", strlen("hello"), 0);

    for(int i=0; i<130; i++) {
        sprintf(names, "reports/report%d.txt", i);
        int rid=open(names, O_RDONLY);
        struct stat st;
        stat(names, &st);
        read(rid, ss, st.st_size);
        send(sockfd, ss, st.st_size, 0);
    }
    close(sockfd);
    return 0;
}
```
文件锁
```c
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/file.h>
char s[55];
int main() {
	int rid=open("/dev/quantum_reader_0", O_RDONLY, S_IRUSR | S_IRGRP | S_IROTH);
	flock(rid, LOCK_EX);
	for(int i=1; i<=1000; i++) {
		read(rid, s, 10);
		printf("%s", s);
	}
	flock(rid, LOCK_UN);
	return 0;
}

```
多线程与锁
```c
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <pthread.h>
pthread_mutex_t mutex[135];
pthread_t thrd[135];
int qwq[135];
void makeReports(int *idx) {
    char names1[55], names2[55], ss[15];
    pthread_mutex_lock(&mutex[*idx]);
    sprintf(names1, "books/book%d.txt", *idx);
    sprintf(names2, "reports/report%d.txt", *idx);
    int rid=open(names1, O_RDONLY);
    int wid=open(names2, O_RDWR | O_CREAT, 0664);
    struct stat statbuf;
    stat(names1,&statbuf);
    int bookLen=statbuf.st_size;
    while(read(rid, ss, 10)!=0) {
        write(wid, ss+rand()%10, 1);
    }
    close(rid);
    pthread_mutex_unlock(&mutex[*idx]);
    int cnt=bookLen/10;
    while(cnt) {
        int nu=rand()%130;
        pthread_mutex_lock(&mutex[nu]);
        sprintf(names1, "books/book%d.txt", nu);
        rid = open(names1, O_RDONLY);
        while(read(rid, ss, 4)!=0 && cnt>0) {
            write(wid, ss+rand()%4, 1);
            cnt--;
        }
        close(rid);
        pthread_mutex_unlock(&mutex[nu]);
    }
    close(wid);
    printf("Done %d\n", *idx);
}
int main() {
    srand(time(NULL));
    int huaq[135];
    for(int i=0; i<130; i++) {
        pthread_mutex_init(&mutex[i], NULL);
        huaq[i] = i;
    }
    for(int i=0; i<130; i++) {
        int j=i;
        pthread_create(&thrd[i], NULL, (void *)makeReports, &huaq[i]);
    }
    for(int i=0; i<130; i++)
        pthread_join(thrd[i], NULL);
    return 0;
}
```