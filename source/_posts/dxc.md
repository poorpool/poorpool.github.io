---
title: 联创OS任务——多进程与信号量
date: 2019-12-17 20:00:49
tags:
- 多进程
categories:
- OS
---
重点是共用内存还有信号量

<!--more-->

参考[1](https://www.cnblogs.com/52php/p/5861372.html)和[2](https://www.cnblogs.com/52php/p/5851570.html)。

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/shm.h>
#include <sys/sem.h>
struct read_data{
    int book_id;
    int book_size; //本次读取的书籍的总大小
    int data_offset; //本次读取获得的数据的开头位置在书中的位置
    int data_size; //本次读取获得的数据大小
    char data[0];  //不定长数组，数组长度为data_size字节
}*s;
union semun {
    int val;
    struct semid_ds *buf;
    unsigned short *arry;
};
int p, shmid[135], intid;//shmid标识每一个书的内存的id，intid标识read了多少个字节的数组的id
int semid[135], intsem;
int *intAddr;
void setSemVal(int seid) {
    union semun sem_union;
    sem_union.val = 1;
    semctl(seid, 0, SETVAL, sem_union);
}
void sem_p(int seid)
{
    // 对信号量做减1操作，即等待P（sv）
    struct sembuf sem_b;
    sem_b.sem_num = 0;
    sem_b.sem_op = -1;//P()
    sem_b.sem_flg = SEM_UNDO;
    semop(seid, &sem_b, 1);
}
 
void sem_v(int seid)
{
    // 这是一个释放操作，它使信号量变为可用，即发送信号V（sv）
    struct sembuf sem_b;
    sem_b.sem_num = 0;
    sem_b.sem_op = 1; // V()
    sem_b.sem_flg = SEM_UNDO;
    semop(seid, &sem_b, 1);
}
int main() {
    int fid = open("/dev/quantum_reader_1", O_RDONLY);
    s = (struct read_data *)malloc(sizeof(struct read_data)+4096);
    int pid;
    
    for(int i=0; i<130; i++) {
        shmid[i] = shmget((key_t)i+1, 150000, IPC_CREAT | 0666) ;//shm flag
        semid[i] = semget((key_t)i+1, 1, IPC_CREAT | 0666) ;//sem flag
        setSemVal(semid[i]);
    }
    intid = shmget((key_t)150, 150, IPC_CREAT | 0666);
    intsem = semget((key_t)150, 1, IPC_CREAT | 0666);
    setSemVal(intsem);
    intAddr = shmat(intid, NULL, 0);
    for(int i=0; i<130; i++)
        intAddr[i] = 0;
    shmdt(intAddr);
    for(int i=1; i<=8; i++) {
        pid = fork();
        if(!pid)	break;
    }
    if(pid) {
        wait();
        printf("Reading completed.\n");
        union semun semUnion;
        for(int i=0; i<130; i++) {
            shmctl(shmid[i], IPC_RMID, 0);
            semctl(semid[i], 0, IPC_RMID, semUnion);
        }
        shmctl(intid, IPC_RMID, 0);
        semctl(intsem, 0, IPC_RMID, semUnion);
    }
    else {
        while(1) {
            read(fid, s, sizeof(struct read_data)+4096);
            
            char *addr=shmat(shmid[s->book_id], NULL, 0);
            intAddr = shmat(intid, NULL, 0);
            
            sem_p(semid[s->book_id]);
            sem_p(intsem);
            // printf("%.2f\n", 1.0*intAddr[s->book_id]/s->book_size);
            // printf("%d\n", *addr);
            if(intAddr[s->book_id]==0) {
                for(int i=0; i<s->book_size; i++)
                    addr[i] = 0xff;
                // printf("Thakn\n");
            }
            if(1.0*intAddr[s->book_id]/s->book_size<0.85) {
                // printf("Fuckyou\n");
                for(int i=s->data_offset; i<s->data_offset+s->data_size; i++) {
                    // printf("%x\n", addr[i]);
                    if(addr[i]==0xffffffff) {
                        intAddr[s->book_id]++;
                        addr[i] = s->data[i-s->data_offset];
                    }
                }
                if(1.0*intAddr[s->book_id]/s->book_size>0.85) {
                    
                    char names[55];
                    sprintf(names, "books/book%d.txt", s->book_id);
                    FILE *qwq=fopen(names, "w");
                    for(int i=0; i<s->book_size; i++)
                        fputc(addr[i], qwq);
                    int cnt = 0;
                    for(int i=0; i<=129; i++) {
                        sprintf(names, "books/book%d.txt", i);
                        if(!access(names, 0)) {
                            cnt++;
                            printf("x");
                        }
                        else	printf(".");
                    }
                    printf("\tReading %d/130...\n", cnt);
                    if(cnt==130) {
                        sem_v(semid[s->book_id]);
                        sem_v(intsem);
                        shmdt(addr);
                        shmdt(intAddr);
                        break;
                    }
                }
                
            }
            sem_v(intsem);
            sem_v(semid[s->book_id]);
            shmdt(addr);
            shmdt(intAddr);
        }
    }
    return 0;
}
```