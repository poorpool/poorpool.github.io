---
title: shelllab
date: 2020-02-09 11:43:16
tags:
- 多进程
- 信号
categories:
- OS
---
首先定义`volatile sig_atomic_t fg_stop_or_exit;`

然后[照着抄（不是）](https://blog.csdn.net/xiaolian_hust/article/details/80087376)，这个讲得好，程序也跑得好。建议先自己阅读他的代码，然后自己写。

<!--more-->
 
这些是你要实现的函数

```C
/* 
 * eval - Evaluate the command line that the user has just typed in
 * 
 * If the user has requested a built-in command (quit, jobs, bg or fg)
 * then execute it immediately. Otherwise, fork a child process and
 * run the job in the context of the child. If the job is running in
 * the foreground, wait for it to terminate and then return.  Note:
 * each child process must have a unique process group ID so that our
 * background children don't receive SIGINT (SIGTSTP) from the kernel
 * when we type ctrl-c (ctrl-z) at the keyboard.  
*/
void eval(char *cmdline) 
{
    sigset_t mask, mask_prev, mask_one;
    char *argv[MAXARGS];
    char buf[MAXLINE];
    int bg;
    pid_t pid;
    strcpy(buf, cmdline);
    bg = parseline(buf, argv) ? BG : FG;
    if(argv[0]==NULL)
        return ;
    sigemptyset(&mask_one);
    sigaddset(&mask_one, SIGCHLD);
    sigfillset(&mask);
    if(!builtin_cmd(argv)) {
        sigprocmask(SIG_BLOCK, &mask_one, &mask_prev);
        if((pid=fork())==0) {
            sigprocmask(SIG_SETMASK, &mask_prev, NULL);
            setpgid(0, 0);
            if(execve(argv[0], argv, environ)<0) 
                printf("%s: Command not found.\n", argv[0]);
            exit(0);
        }
        sigprocmask(SIG_BLOCK, &mask, NULL);
        addjob(jobs, pid, bg, cmdline);
        sigprocmask(SIG_SETMASK, &mask_one, NULL);
        if(bg==FG) 
            waitfg(pid);
        else {
            sigprocmask(SIG_BLOCK , &mask, NULL);
            struct job_t *job = getjobpid(jobs, pid);
            printf("[%d] (%d) %s", job->jid, job->pid, job->cmdline);
        }
        sigprocmask(SIG_SETMASK, &mask_prev, NULL);
    }
    return;
}

/* 
 * builtin_cmd - If the user has typed a built-in command then execute
 *    it immediately.  
 */
int builtin_cmd(char **argv) 
{
    sigset_t mask, mask_prev;
    if(strcmp(argv[0], "quit")==0) {
        _exit(0);
    }
    else if(strcmp(argv[0], "fg")==0 || strcmp(argv[0], "bg")==0) {
        do_bgfg(argv);
        return 1;
    }
    else if(strcmp(argv[0], "&")==0)
        return 1;
    else if(strcmp(argv[0], "jobs")==0) {
        sigfillset(&mask);
        sigprocmask(SIG_BLOCK, &mask, &mask_prev);
        listjobs(jobs);
        sigprocmask(SIG_SETMASK, &mask_prev, NULL);
        return 1;
    }
    return 0;     /* not a builtin command */
}

/* 
 * do_bgfg - Execute the builtin bg and fg commands
 */
void do_bgfg(char **argv) 
{
    sigset_t mask, mask_prev;
    struct job_t *job;
    sigfillset(&mask);
    if(argv[1]==NULL) {
        printf("%s command requires PID or %%jobid argument\n", argv[0]);
        return ;
    }
    if(argv[1][0]=='%') {
        int jid=atoi(&argv[1][1]);
        if(!jid) {
            printf("%s: argument must be a PID or %%jobid\n", argv[0]);
            return ;
        }
        sigprocmask(SIG_BLOCK, &mask, &mask_prev);
        job = getjobjid(jobs, jid);
        sigprocmask(SIG_SETMASK, &mask_prev, NULL);
    }
    else {
        int pid=atoi(argv[1]);
        if(!pid) {
            printf("%s: argument must be a PID or %%jobid\n", argv[0]);
            return ;
        }
        sigprocmask(SIG_BLOCK, &mask, &mask_prev);
        job = getjobpid(jobs, pid);
        sigprocmask(SIG_SETMASK, &mask_prev, NULL);
    }
    sigprocmask(SIG_BLOCK, &mask, &mask_prev);
    if(job==NULL) {
        if(argv[1][0]=='%')
            printf("%s: No such job\n", argv[1]);
        else
            printf("(%s): No such process\n", argv[1]);
        sigprocmask(SIG_SETMASK, &mask_prev, NULL);
        return ;
    }
    if(strcmp(argv[0], "bg")==0) {
        if(job->state==ST) {
            job->state = BG;
            kill(-job->pid, SIGCONT);
            printf("[%d] (%d) %s", job->jid, job->pid, job->cmdline);
        }
    }
    else {
        if(job->state==BG) {
            job->state = FG;
            waitfg(job->pid);
        }
        else if(job->state==ST) {
            job->state = FG;
            kill(-job->pid, SIGCONT);
            waitfg(job->pid);
        }
    }
    sigprocmask(SIG_SETMASK, &mask_prev, NULL);
    return;
}

/* 
 * waitfg - Block until process pid is no longer the foreground process
 */
void waitfg(pid_t pid)
{
    sigset_t mask;
    sigemptyset(&mask);
    fg_stop_or_exit = 0;
    while(!fg_stop_or_exit)
        sigsuspend(&mask);
    return;
}

/*****************
 * Signal handlers
 *****************/

/* 
 * sigchld_handler - The kernel sends a SIGCHLD to the shell whenever
 *     a child job terminates (becomes a zombie), or stops because it
 *     received a SIGSTOP or SIGTSTP signal. The handler reaps all
 *     available zombie children, but doesn't wait for any other
 *     currently running children to terminate.  
 */
void sigchld_handler(int sig) 
{
    sigset_t mask, mask_prev;
    int olderrno=errno, status;
    pid_t pid;
    struct job_t *job;
    sigfillset(&mask);
    while((pid=waitpid(-1, &status, WNOHANG | WUNTRACED))>0) {
        sigprocmask(SIG_BLOCK, &mask, &mask_prev);
        job = getjobpid(jobs, pid);
        if(pid==fgpid(jobs))
            fg_stop_or_exit = 1;
        if(WIFSTOPPED(status)) {
            job->state = ST;
            printf("Job [%d] (%d) stopped by signal %d\n", job->jid, pid, WSTOPSIG(status));
        }
        else {
            if(WIFSIGNALED(status)) 
                printf("Job [%d] (%d) terminated by signal %d\n", job->jid, pid, WTERMSIG(status));
            deletejob(jobs, pid);
        }
        sigprocmask(SIG_SETMASK, &mask_prev, NULL);
    }
    errno = olderrno;
    return;
}

/* 
 * sigint_handler - The kernel sends a SIGINT to the shell whenver the
 *    user types ctrl-c at the keyboard.  Catch it and send it along
 *    to the foreground job.  
 */
void sigint_handler(int sig) 
{
    sigset_t mask, mask_prev;
    int olderrno=errno;
    pid_t pid;
    sigfillset(&mask);
    sigprocmask(SIG_BLOCK, &mask, &mask_prev);
    pid = fgpid(jobs);
    sigprocmask(SIG_SETMASK, &mask_prev, NULL);
    if(pid)
        kill(-pid, SIGINT);
    errno = olderrno;
    return;
}

/*
 * sigtstp_handler - The kernel sends a SIGTSTP to the shell whenever
 *     the user types ctrl-z at the keyboard. Catch it and suspend the
 *     foreground job by sending it a SIGTSTP.  
 */
void sigtstp_handler(int sig) 
{
    sigset_t mask, mask_prev;
    int olderrno=errno;
    pid_t pid;
    sigfillset(&mask);
    sigprocmask(SIG_BLOCK, &mask, &mask_prev);
    pid = fgpid(jobs);
    sigprocmask(SIG_SETMASK, &mask_prev, NULL);
    if(pid)
        kill(-pid, SIGTSTP);
    errno = olderrno;
    return;
}

/*********************
 * End signal handlers
 *********************/
 ```