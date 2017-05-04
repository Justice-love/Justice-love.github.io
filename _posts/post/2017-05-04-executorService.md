---
layout: post
title:  "浅析ThreadPoolExecutor"
date:   2017-05-04
excerpt: "简单介绍多线程中ThreadPoolExecutor使用"
tag:
- ExecutorService
- 多线程
comments: true
---

### JDK默认提供的三种ThreadPoolExecutor

- __FixedThreadPool__

``` java
    public static ExecutorService newFixedThreadPool(int nThreads, ThreadFactory threadFactory) {
        return new ThreadPoolExecutor(nThreads, nThreads,
                                      0L, TimeUnit.MILLISECONDS,
                                      new LinkedBlockingQueue<Runnable>(),
                                      threadFactory);
```



线程池中核心线程数和最大允许的线程数相同，即线程池中的线程空闲后不会被回收，除非```allowCoreThreadTimeOut```被设置成```true```.

- __SingleThreadPool__

``` java
    public static ExecutorService newSingleThreadExecutor(ThreadFactory threadFactory) {
        return new FinalizableDelegatedExecutorService
            (new ThreadPoolExecutor(1, 1,
                                    0L, TimeUnit.MILLISECONDS,
                                    new LinkedBlockingQueue<Runnable>(),
                                    threadFactory));
    }
```

线程池中的线程数最多保持一个.

和```FixedThreadPool(1)```的区别为FixedThreadPool为ThreadPoolExecutor对象，可以调用ThreadPoolExecutor的一些方法对其进行配置。而SingleThreadPool返回的是ExecutorService的简单封装，仅暴露了ExecutorService的执行方法，无法进行配置。

- __CachedThreadPool__

  ``` java
      public static ExecutorService newCachedThreadPool(ThreadFactory threadFactory) {
          return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                        60L, TimeUnit.SECONDS,
                                        new SynchronousQueue<Runnable>(),
                                        threadFactory);
      }
  ```

  ​

一个无限容量的连接池，并且空闲的线程会缓存60S。



### ThreadPoolExecutor简单解析

- 构造函数

  ``` java
      public ThreadPoolExecutor(int corePoolSize,
                                int maximumPoolSize,
                                long keepAliveTime,
                                TimeUnit unit,
                                BlockingQueue<Runnable> workQueue,
                                ThreadFactory threadFactory,
                                RejectedExecutionHandler handler) {
          if (corePoolSize < 0 ||
              maximumPoolSize <= 0 ||
              maximumPoolSize < corePoolSize ||
              keepAliveTime < 0)
              throw new IllegalArgumentException();
          if (workQueue == null || threadFactory == null || handler == null)
              throw new NullPointerException();
          this.corePoolSize = corePoolSize;
          this.maximumPoolSize = maximumPoolSize;
          this.workQueue = workQueue;
          this.keepAliveTime = unit.toNanos(keepAliveTime);
          this.threadFactory = threadFactory;
          this.handler = handler;
      }
  ```

- 参数解析

  - corePoolSize：核心线程池大小，线程数如果不超过该值，线程会默认保留，就算线程处于空闲状态。
  - maximumPoolSize：线程池的最大容量，线程数的重量不能操过该值。
  - keepAliveTime：空闲线程最长保留时间。
  - unit：时间单位。
  - workQueue：接收请求的队列。
  - threadFactory：线程工厂。
  - handler：由于超出线程范围和队列容量而使执行被阻塞时所使用的处理程序。

- 部分参数意义

  - 当线程数不超过核心线程池大小时，创建的线程默认都将被保留下来，就算线程为空闲状态。
  - 当线程数超过核心线程池大小，而没超过最大线程池大小时，空闲的线程会等待```keepAliveTime```时长后被销毁。

- Future简单解析

  - ```future.get()```将会被阻塞知道获取数据，当任务被取消，任务抛出异常，任务被中断时均会抛出异常。

- 线程池增加新处理线程（woker）的时机

  ``` java
  public void execute(Runnable command) {
    if (command == null)
        throw new NullPointerException();
    /*
     * Proceed in 3 steps:
     *
     * 1. If fewer than corePoolSize threads are running, try to
     * start a new thread with the given command as its first
     * task.  The call to addWorker atomically checks runState and
     * workerCount, and so prevents false alarms that would add
     * threads when it shouldn't, by returning false.
     *
     * 2. If a task can be successfully queued, then we still need
     * to double-check whether we should have added a thread
     * (because existing ones died since last checking) or that
     * the pool shut down since entry into this method. So we
     * recheck state and if necessary roll back the enqueuing if
     * stopped, or start a new thread if there are none.
     *
     * 3. If we cannot queue task, then we try to add a new
     * thread.  If it fails, we know we are shut down or saturated
     * and so reject the task.
     */
    int c = ctl.get();
    if (workerCountOf(c) < corePoolSize) {
        if (addWorker(command, true))
            return;
        c = ctl.get();
    }
    if (isRunning(c) && workQueue.offer(command)) {
        int recheck = ctl.get();
        if (! isRunning(recheck) && remove(command))
            reject(command);
        else if (workerCountOf(recheck) == 0)
            addWorker(null, false);
    }
    else if (!addWorker(command, false))
        reject(command);
  }
  ```

- 通过阅读```java.util.concurrent.ThreadPoolExecutor#execute```方法可以发现，在当前线程数小于核心线程数时，默认增加一个执行线程。在执行线程数为0时，直接增加一个执行线程。其余则在线程数小于最大线程数时增加执行线程。
  ``` java
  private boolean addWorker(Runnable firstTask, boolean core) {
        retry:
        for (;;) {
            int c = ctl.get();
            int rs = runStateOf(c);

            // Check if queue empty only if necessary.
            if (rs >= SHUTDOWN &&
                ! (rs == SHUTDOWN &&
                   firstTask == null &&
                   ! workQueue.isEmpty()))
                return false;

            for (;;) {
                int wc = workerCountOf(c);
                if (wc >= CAPACITY ||
                    wc >= (core ? corePoolSize : maximumPoolSize))
                    return false;
                if (compareAndIncrementWorkerCount(c))
                    break retry;
                c = ctl.get();  // Re-read ctl
                if (runStateOf(c) != rs)
                    continue retry;
                // else CAS failed due to workerCount change; retry inner loop
            }
        }

        boolean workerStarted = false;
        boolean workerAdded = false;
        Worker w = null;
        try {
            w = new Worker(firstTask);
            final Thread t = w.thread;
            if (t != null) {
                final ReentrantLock mainLock = this.mainLock;
                mainLock.lock();
                try {
                    // Recheck while holding lock.
                    // Back out on ThreadFactory failure or if
                    // shut down before lock acquired.
                    int rs = runStateOf(ctl.get());

                    if (rs < SHUTDOWN ||
                        (rs == SHUTDOWN && firstTask == null)) {
                        if (t.isAlive()) // precheck that t is startable
                            throw new IllegalThreadStateException();
                        workers.add(w);
                        int s = workers.size();
                        if (s > largestPoolSize)
                            largestPoolSize = s;
                        workerAdded = true;
                    }
                } finally {
                    mainLock.unlock();
                }
                if (workerAdded) {
                    t.start();
                    workerStarted = true;
                }
            }
        } finally {
            if (! workerStarted)
                addWorkerFailed(w);
        }
        return workerStarted;
    }
  ```