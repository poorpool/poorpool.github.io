---
title: malloclab
date: 2020-02-12 18:31:09
tags:
---
首先从 csapp 599 页开始照着抄，用的是隐式空闲链表。

发现没有 realloc，那只能自己捏造一个了……

<!--more-->

```C
/*
 * mm_realloc - Implemented simply in terms of mm_malloc and mm_free
 */
void *mm_realloc(void *bp, size_t size) {    
    int asize;
    if(size==0)
        return NULL;
    if(size<=DSIZE)
        asize = 2 * DSIZE;
    else
        asize = DSIZE * ((size + DSIZE + DSIZE - 1) / DSIZE);
    size_t oldsize=GET_SIZE(HDRP(bp));
    if(oldsize>asize) {
        PUT(HDRP(bp), PACK(asize, 1));
        PUT(FTRP(bp), PACK(asize, 1));
        PUT(HDRP(NEXT_BLKP(bp)), PACK(oldsize-asize, 0));
        PUT(FTRP(NEXT_BLKP(bp)), PACK(oldsize-asize, 0));
        coalesce(NEXT_BLKP(bp));
        return bp;
    }
    else if(oldsize<asize) {
        if(!GET_ALLOC(HDRP(NEXT_BLKP(bp))) && GET_SIZE(HDRP(NEXT_BLKP(bp)))+oldsize>=asize) {
            int newsize=GET_SIZE(HDRP(NEXT_BLKP(bp)))+oldsize;
            PUT(HDRP(bp), PACK(newsize, 0));
            PUT(FTRP(bp), PACK(newsize, 0));
            place(bp, asize);
            coalesce(NEXT_BLKP(bp));
            return bp;
        }
        else {
            void *newptr;
            size_t copySize;
            newptr = mm_malloc(asize);
            if (newptr == NULL)
            return NULL;
            copySize = GET_SIZE(HDRP(bp));
            if (asize < copySize)
            copySize = asize;
            memcpy(newptr, bp, copySize);
            mm_free(bp);
            return newptr;
        }
    }
    else
        return bp;
}
```

这样你的 perf 能获得 66 分的好成绩，感天动地。

书抄完了，开始抄[网上的代码](https://www.cnblogs.com/liqiuhao/p/8252373.html)吧。

这个看一看，那个看一看，懒得写平衡树，那就随便糊一个显式空闲列表+分离适配吧（603页，605页）。

在我的代码中，块的格式是：
```
31       0
/--------\ 低
|header  |
|--------|
|payload |
|...     |
|--------|
|fill(*) |
|...     |
|--------|
|footer  |
\--------/ 高
分配块
31       0
/--------\ 低
|header  |
|--------|
|next    |
|prev    |
|--------|
|fill(*) |
|...     |
|--------|
|footer  |
\--------/ 高
空闲
```
fill(*)是填充的，有可能没有。

然后抄一遍代码，自己糊一个有讨论的 realloc 就可以拿到 89 分的好成绩了。我怀疑这是因为俺的 Intel© Core™ i5-8250U CPU @ 1.60GHz × 4不太行，所以也不改了（

```C
/*
 * mm-naive.c - The fastest, least memory-efficient malloc package.
 * 
 * In this naive approach, a block is allocated by simply incrementing
 * the brk pointer.  A block is pure payload. There are no headers or
 * footers.  Blocks are never coalesced or reused. Realloc is
 * implemented directly using mm_malloc and mm_free.
 *
 * NOTE TO STUDENTS: Replace this header comment with your own header
 * comment that gives a high level description of your solution.
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>

#include "mm.h"
#include "memlib.h"

/*********************************************************
 * NOTE TO STUDENTS: Before you do anything else, please
 * provide your team information in the following struct.
 ********************************************************/


team_t team = {
    /* Team name */
    "poorpool",
    /* First member's full name */
    "Harry Bovik",
    /* First member's email address */
    "bovik@cs.cmu.edu",
    /* Second member's full name (leave blank if none) */
    "",
    /* Second member's email address (leave blank if none) */
    ""
};

/* single word (4) or double word (8) alignment */
#define ALIGNMENT 8

/* rounds up to the nearest multiple of ALIGNMENT */
#define ALIGN(size) (((size) + (ALIGNMENT-1)) & ~0x7)

#define SIZE_T_SIZE (ALIGN(sizeof(size_t)))

#define WSIZE 4
#define DSIZE 8
#define CHUNKSIZE (1<<12)

#define MAX(x, y) ((x)>(y)?(x):(y))

#define PACK(size, alloc) ((size) | (alloc))

#define GET(p) (*(unsigned int *)(p))
#define PUT(p, val) (*(unsigned int *)(p) = (val))

/*对于一个void *bp来说，GET_PTR(BP)同时相当于取得他的后继，GET_PTR((unsigned int *)BP+1)相当于取得他的前驱。这里的后继前驱
都是针对显式空闲列表来说的，也就是前后的那个空闲块。务必理解这个概念*/
#define GET_PTR(p) ((unsigned int *)(long)(GET(p)))
#define PUT_PTR(p, ptr) (*(unsigned int *)(p) = ((long)(ptr)))

#define GET_SIZE(p) (GET(p) & ~0x7)
#define GET_ALLOC(p) (GET(p) & 0x1)

#define HDRP(bp) ((char *)(bp) - WSIZE)
#define FTRP(bp) ((char *)(bp) + GET_SIZE(HDRP(bp)) - DSIZE)

#define NEXT_BLKP(bp) ((char *)(bp) + GET_SIZE((char *)(bp) - WSIZE))
#define PREV_BLKP(bp) ((char *)(bp) - GET_SIZE((char *)(bp) - DSIZE))

static void *heap_listp;

#define SIZE1 (1<<4)
#define SIZE2 (1<<5)
#define SIZE3 (1<<6)
#define SIZE4 (1<<7)
#define SIZE5 (1<<8)
#define SIZE6 (1<<9)
#define SIZE7 (1<<10)  		
#define SIZE8 (1<<11)
#define SIZE9 (1<<12)
#define SIZE10 (1<<13)
#define SIZE11 (1<<14)
#define SIZE12 (1<<15)
#define SIZE13 (1<<16)
#define SIZE14 (1<<17)
#define SIZE15 (1<<18)
#define SIZE16 (1<<19)
#define SIZE17 (1<<20) 		
 
#define LISTS_NUM 18

static void *extend_heap(size_t words);
static void *coalesce(void *bp);
static void *find_fit(size_t asize);
static void place(void *bp, size_t asize);
static void insert_list(void *bp);
static size_t get_list_offset(size_t size);
static void delete_list(void *bp);

static void *coalesce(void *bp) {
    size_t prev_alloc = GET_ALLOC(FTRP(PREV_BLKP(bp)));
    size_t next_alloc = GET_ALLOC(HDRP(NEXT_BLKP(bp)));
    size_t size = GET_SIZE(HDRP(bp));
    if(prev_alloc && next_alloc)
        ;
    else if(prev_alloc && !next_alloc) {
        delete_list(NEXT_BLKP(bp));
        size += GET_SIZE(HDRP(NEXT_BLKP(bp)));
        PUT(HDRP(bp), PACK(size, 0));
        PUT(FTRP(bp), PACK(size, 0));
    }
    else if(!prev_alloc && next_alloc) {
        delete_list(PREV_BLKP(bp));
        size += GET_SIZE(HDRP(PREV_BLKP(bp)));
        PUT(FTRP(bp), PACK(size, 0));
        PUT(HDRP(PREV_BLKP(bp)), PACK(size, 0));
        bp = PREV_BLKP(bp);
    }
    else {
        delete_list(PREV_BLKP(bp));
        delete_list(NEXT_BLKP(bp));
        size += GET_SIZE(HDRP(PREV_BLKP(bp))) + GET_SIZE(FTRP(NEXT_BLKP(bp)));
        PUT(HDRP(PREV_BLKP(bp)), PACK(size, 0));
        PUT(FTRP(NEXT_BLKP(bp)), PACK(size, 0));
        bp = PREV_BLKP(bp);
    }
    insert_list(bp);
    return bp;
}

static void insert_list(void *bp) {
    size_t size = GET_SIZE(HDRP(bp));
    size_t index = get_list_offset(size);
    if(GET_PTR(heap_listp+WSIZE*index)==NULL) {
        PUT_PTR(heap_listp + WSIZE * index, bp);
		PUT_PTR(bp, NULL);//next<->NULL
		PUT_PTR((unsigned int *)bp + 1, NULL);//prev<->NULL
    }
    else {
        PUT_PTR(bp, GET_PTR(heap_listp + WSIZE * index));//next<-原来的头节点
		PUT_PTR(GET_PTR(heap_listp + WSIZE * index) + 1, bp);  	//头节点prev<-bp
        PUT_PTR((unsigned int *)bp + 1, NULL);//bp的prev <- NULL
		PUT_PTR(heap_listp + WSIZE * index, bp);//头节点 bp
    }
}

static void delete_list(void *bp) {
    //这就是双向链表哇
    size_t size = GET_SIZE(HDRP(bp));
    size_t index = get_list_offset(size);
    if(GET_PTR(bp)==NULL && GET_PTR((unsigned int *)bp+1)==NULL)
        PUT_PTR(heap_listp + WSIZE * index, NULL);
    else if (GET_PTR(bp)==NULL && GET_PTR((unsigned int *)bp+1) != NULL) {
        PUT_PTR((GET_PTR((unsigned int*)GET_PTR((unsigned int *)bp+1))), NULL );//bp->prev->next=NULL
        PUT_PTR(GET_PTR((unsigned int *)bp + 1), NULL);  //bp前驱指针prev=NULL
    }
    else if (GET_PTR(bp) != NULL && GET_PTR((unsigned int *)bp + 1) == NULL){
        PUT_PTR(heap_listp + WSIZE * index, GET_PTR(bp));
        PUT_PTR(GET_PTR(bp) + 1, NULL); //prev=NULL
    }
    else if (GET_PTR(bp) != NULL && GET_PTR((unsigned int *)bp + 1) != NULL) {
        PUT_PTR(GET_PTR((unsigned int *)bp + 1), GET_PTR(bp));
        PUT_PTR(GET_PTR(bp) + 1, GET_PTR((unsigned int*)bp + 1));//bp->next->prev = bp->prev
    }
}

size_t get_list_offset(size_t size) {
	if(size<=SIZE1)
		return 0;
	else if(size<=SIZE2)
		return 1;
	else if(size<=SIZE3)
		return 2;
	else if(size<=SIZE4)
		return 3;
	else if(size<=SIZE5)
		return 4;
	else if(size<=SIZE6)
		return 5;
	else if(size<=SIZE7)
		return 6;
	else if(size<=SIZE8)
		return 7;
	else if(size<=SIZE9)
		return 8;
	else if(size<=SIZE10)
		return 9;
	else if(size<=SIZE11)
		return 10;
	else if(size<=SIZE12)
		return 11;
	else if(size<=SIZE13)
		return 12;
	else if(size<=SIZE14)
		return 13;
	else if(size<=SIZE15)
		return 14;
	else if(size<=SIZE16)
		return 15;
	else if(size<=SIZE17)
		return 16;
    else
		return 17;
}

static void *extend_heap(size_t words) {
    char *bp;
    size_t size;
    size = (words % 2) ? (words + 1) * WSIZE : words * WSIZE;
    if((long)(bp = mem_sbrk(size))==-1)
        return NULL;
    PUT(HDRP(bp), PACK(size, 0));
    PUT(FTRP(bp), PACK(size, 0));
    PUT(HDRP(NEXT_BLKP(bp)), PACK(0, 1));
    return coalesce(bp);
}
/* 
 * mm_init - initialize the malloc package.
 */

int mm_init(void)
{
    if((heap_listp = mem_sbrk((4+LISTS_NUM)*WSIZE)) == (void *)-1)
        return -1;
    PUT(heap_listp + LISTS_NUM * WSIZE, 0);
    PUT(heap_listp + (1 + LISTS_NUM) * WSIZE, PACK(DSIZE, 1));
    PUT(heap_listp + (2 + LISTS_NUM) * WSIZE, PACK(DSIZE, 1));
    PUT(heap_listp + (3 + LISTS_NUM) * WSIZE, PACK(0, 1));
    int i;
    for(i=0; i<LISTS_NUM; i++)
        PUT_PTR(heap_listp + WSIZE * i, NULL);
    if(extend_heap(CHUNKSIZE/WSIZE)==NULL)
        return -1;
    return 0;
}

static void *find_fit(size_t asize) {
    size_t index=get_list_offset(asize);
    unsigned int *ptr;
    while(index<18) {
        ptr = GET_PTR(heap_listp + WSIZE * index);
        while(ptr!=NULL) {
            if(GET_SIZE(HDRP(ptr))>=asize)
                return (void *)ptr;
            ptr = GET_PTR(ptr);
        }
        index++;
    }
    return NULL;
}
static void place(void *bp, size_t asize) {
    size_t csize = GET_SIZE(HDRP(bp));
    delete_list(bp);
    if(csize-asize>=2*DSIZE) {
        PUT(HDRP(bp), PACK(asize, 1));
        PUT(FTRP(bp), PACK(asize, 1));
        bp = NEXT_BLKP(bp);
        PUT(HDRP(bp), PACK(csize-asize, 0));
        PUT(FTRP(bp), PACK(csize-asize, 0));
        insert_list(bp);
    }
    else {
        PUT(HDRP(bp), PACK(csize, 1));
        PUT(FTRP(bp), PACK(csize, 1));
    }
}
static void pppplace(void *bp, size_t asize) {
    size_t csize = GET_SIZE(HDRP(bp));
    if(csize-asize>=2*DSIZE) {
        PUT(HDRP(bp), PACK(asize, 1));
        PUT(FTRP(bp), PACK(asize, 1));
        bp = NEXT_BLKP(bp);
        PUT(HDRP(bp), PACK(csize-asize, 0));
        PUT(FTRP(bp), PACK(csize-asize, 0));
        insert_list(bp);
    }
    else {
        PUT(HDRP(bp), PACK(csize, 1));
        PUT(FTRP(bp), PACK(csize, 1));
    }
}
/* 
 * mm_malloc - Allocate a block by incrementing the brk pointer.
 *     Always allocate a block whose size is a multiple of the alignment.
 */

void *mm_malloc(size_t size)
{
    size_t asize;
    size_t extendsize;
    char *bp;
    if(size==0)
        return NULL;
    if(size<=DSIZE)
        asize = 2 * DSIZE;
    else
        asize = DSIZE * ((size + DSIZE + DSIZE - 1) / DSIZE);
    if((bp=find_fit(asize))!=NULL) {
        place(bp, asize);
        return bp;
    }
    extendsize = MAX(asize, CHUNKSIZE);
    if((bp=extend_heap(extendsize/WSIZE))==NULL)
        return NULL;
    place(bp, asize);
    // printf("%%p:%p\n", bp);
    return bp;
}

/*
 * mm_free - Freeing a block does nothing.
 */
void mm_free(void *bp)
{
    size_t size = GET_SIZE(HDRP(bp));
    PUT(HDRP(bp), PACK(size, 0));
    PUT(FTRP(bp), PACK(size, 0));
    coalesce(bp);
}

/*
 * mm_realloc - Implemented simply in terms of mm_malloc and mm_free
 */
void *mm_realloc(void *bp, size_t size)
{
    size_t asize;
    if(size==0)
        return NULL;
    if(size<=DSIZE)
        asize = 2 * DSIZE;
    else
        asize = DSIZE * ((size + DSIZE + DSIZE - 1) / DSIZE);
    if(bp == NULL)
        return mm_malloc(asize);
    size_t oldsize=GET_SIZE(HDRP(bp));
    if(oldsize>asize)
        return bp;
    else if(oldsize<asize) {
        if(!GET_ALLOC(HDRP(NEXT_BLKP(bp))) && GET_SIZE(HDRP(NEXT_BLKP(bp)))+oldsize>=asize) {
            int newsize=GET_SIZE(HDRP(NEXT_BLKP(bp)))+oldsize;
            delete_list(NEXT_BLKP(bp));
            PUT(HDRP(bp), PACK(newsize, 1));
            PUT(FTRP(bp), PACK(newsize, 1));
            return bp;
        }
        else {
            void *newptr;
            newptr = mm_malloc(asize);
            if (newptr == NULL)
            return NULL;
            memcpy(newptr, bp, asize);
            mm_free(bp);
            return newptr;
        }
    }
    else
        return bp;
}
```