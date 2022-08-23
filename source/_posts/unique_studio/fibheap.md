---
title: 斐波那契堆（简单版）
date: 2019-11-02 21:28:14
tags:
- 斐波那契堆
categories:
- 数据结构
---
这个只有搞priority_queue的插入和删除，别的没有

<!--more-->

```cpp
#ifndef __Priority_Queue__
#define __Priority_Queue__

#include <cmath>

typedef size_t size_type;

template<class value_type>
class PriorityQueue {
private:
    class Node {
    public:
        Node *parent, *left, *right, *child;
        int degree;
        value_type key;
        Node(value_type Key) {
            key = Key;
            left = this;
            right = this;
            child = nullptr;
            parent = nullptr;
            degree = 0;
        }
    };
    Node *minNode;
    size_type qSize;
    void insert(const value_type & value);
    void insertToRight(Node *a, Node *h);
    Node *extractMin();
    void extractNode(Node *h);
    void deleteMin();
    void consolidate();
public:
    PriorityQueue() {
        minNode = nullptr;
        qSize = 0;
    }
    const value_type & top() const;
    bool empty() const;
    size_type size() const;
    void push(const value_type& value);
    void pop();
};

template<class value_type>
void PriorityQueue<value_type>::extractNode(Node *h) {
    h->left->right = h->right;
    h->right->left = h->left;
}

template<class value_type>
void PriorityQueue<value_type>::insertToRight(Node *a, Node *h) {
    if(a!=nullptr) {
        h->left = a;
        h->right = a->right;
        h->right->left = h;
        a->right = h;
        h->parent = a->parent;
    }
}

template<class value_type>
void PriorityQueue<value_type>::insert(const value_type & value) {
    Node *newNode=new Node(value);
    if(minNode==nullptr)
        minNode = newNode;
    else {
        insertToRight(minNode, newNode);
        if(value<minNode->key)
            minNode = newNode;
    }
    qSize++;
}
 
template<class value_type>
typename PriorityQueue<value_type>::Node * PriorityQueue<value_type>::extractMin() {
    Node *h=minNode;
    if(h==h->right)
        minNode = nullptr;
    else {
        extractNode(h);
        minNode = h->right;
    }
    h->left = h->right = h;
    return h;
}

template<class value_type>
void PriorityQueue<value_type>::consolidate() {
    if(minNode==nullptr)
        return ;
    int maxDeg=1.0*std::log(qSize)/std::log(2)+1;
    Node **cons=new Node *[maxDeg+1];
    for(int i=0; i<=maxDeg; i++)
        cons[i] = nullptr;
    while(minNode!=nullptr) {
        Node *x=extractMin();
        int deg=x->degree;
        while(cons[deg]!=nullptr) {
            if(x->key>cons[deg]->key)
                std::swap(x, cons[deg]);
            extractNode(cons[deg]);
			if (x->child == NULL)
				x->child = cons[deg];
			else
				insertToRight(x->child, cons[deg]);
			cons[deg]->parent = x;
			x->degree++;
            cons[deg] = nullptr;
            deg++;
        }
        cons[deg] = x;
    }
    minNode = nullptr;
    for(int i=0; i<=maxDeg; i++) {
        if(cons[i]!=nullptr) {
            if(minNode==nullptr)
                minNode = cons[i];
            else {
                insertToRight(minNode, cons[i]);
                if(cons[i]->key<minNode->key)
                    minNode = cons[i];
            }
        }
    }    
    delete cons;
}

template<class value_type>
void PriorityQueue<value_type>::deleteMin() {
    if(minNode==nullptr)    return ;
    Node *child=nullptr;
    Node *delNode=minNode;
    while(delNode->child!=nullptr) {
        child = delNode->child;
        extractNode(child);
        if(child->right==child)
            delNode->child = nullptr;
        else
            delNode->child = child->right;
        insertToRight(minNode, child);
        child->parent = nullptr;
    }
    extractNode(delNode);
    if(delNode->right==delNode)    minNode = nullptr;
    else {
        minNode = delNode->right;
        consolidate();
    }
    qSize--;
    delete delNode;
} 

template<class value_type>
const value_type & PriorityQueue<value_type>::top() const {
    return minNode->key;
}

template<class value_type>
bool PriorityQueue<value_type>::empty() const {
    return qSize==0;
}

template<class value_type>
size_type PriorityQueue<value_type>::size() const {
    return qSize;
}

template<class value_type>
void PriorityQueue<value_type>::push(const value_type& value) {
    insert(value);
}

template<class value_type>
void PriorityQueue<value_type>::pop() {
    deleteMin();
}

#endif
```