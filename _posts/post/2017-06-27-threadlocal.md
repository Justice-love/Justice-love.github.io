---
layout: post
title:  "从RequestContextHolder到ThreadLocal"
date:   2017-06-27
excerpt: "从Spring的RequestContextHolder解读到ThreadLocal的应用"
tag:
- spring
- threadLocal
- RequestContextHolder
comments: true
---

## Spring中的RequestContextHolder

用来将当前请求的上下文信息绑定到线程上(可只绑定到当前线程也可绑定到自线程，需配置)

* context绑定方式：ThreadLocal

``` java
	/**
	 * Bind the given RequestAttributes to the current thread,
	 * <i>not</i> exposing it as inheritable for child threads.
	 * @param attributes the RequestAttributes to expose
	 * @see #setRequestAttributes(RequestAttributes, boolean)
	 */
	public static void setRequestAttributes(RequestAttributes attributes) {
		setRequestAttributes(attributes, false);
	}

	/**
	 * Bind the given RequestAttributes to the current thread.
	 * @param attributes the RequestAttributes to expose,
	 * or {@code null} to reset the thread-bound context
	 * @param inheritable whether to expose the RequestAttributes as inheritable
	 * for child threads (using an {@link InheritableThreadLocal})
	 */
	public static void setRequestAttributes(RequestAttributes attributes, boolean inheritable) {
		if (attributes == null) {
			resetRequestAttributes();
		}
		else {
			if (inheritable) {
				inheritableRequestAttributesHolder.set(attributes);
				requestAttributesHolder.remove();
			}
			else {
				requestAttributesHolder.set(attributes);
				inheritableRequestAttributesHolder.remove();
			}
		}
	}
```

* ThreadLocal与线程绑定，web容器均使用线程池，为了防止请求上下文信息跨请求保持长生命周期，需定义好其生命周期。
    * 在spring中，```RequestContextListener```监听了请求的初始化和请求的销毁，并在请求的初始化在ThreadLocal绑定请求信息，在请求销毁时从ThreadLocal中移除请求信息。

``` java
public class RequestContextListener implements ServletRequestListener {

	private static final String REQUEST_ATTRIBUTES_ATTRIBUTE =
			RequestContextListener.class.getName() + ".REQUEST_ATTRIBUTES";


	@Override
	public void requestInitialized(ServletRequestEvent requestEvent) {
		if (!(requestEvent.getServletRequest() instanceof HttpServletRequest)) {
			throw new IllegalArgumentException(
					"Request is not an HttpServletRequest: " + requestEvent.getServletRequest());
		}
		HttpServletRequest request = (HttpServletRequest) requestEvent.getServletRequest();
		ServletRequestAttributes attributes = new ServletRequestAttributes(request);
		request.setAttribute(REQUEST_ATTRIBUTES_ATTRIBUTE, attributes);
		LocaleContextHolder.setLocale(request.getLocale());
		RequestContextHolder.setRequestAttributes(attributes);
	}

	@Override
	public void requestDestroyed(ServletRequestEvent requestEvent) {
		ServletRequestAttributes attributes = null;
		Object reqAttr = requestEvent.getServletRequest().getAttribute(REQUEST_ATTRIBUTES_ATTRIBUTE);
		if (reqAttr instanceof ServletRequestAttributes) {
			attributes = (ServletRequestAttributes) reqAttr;
		}
		RequestAttributes threadAttributes = RequestContextHolder.getRequestAttributes();
		if (threadAttributes != null) {
			// We're assumably within the original request thread...
			LocaleContextHolder.resetLocaleContext();
			RequestContextHolder.resetRequestAttributes();
			if (attributes == null && threadAttributes instanceof ServletRequestAttributes) {
				attributes = (ServletRequestAttributes) threadAttributes;
			}
		}
		if (attributes != null) {
			attributes.requestCompleted();
		}
	}

}
```

通过上面方式，使用ThreadLocal实现了请求上下文信息的绑定和销毁。

## ThreadLocal

绑定在线程上的map，使用方式类似HashMap

``` java
    public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
    }
    
     public void remove() {
         ThreadLocalMap m = getMap(Thread.currentThread());
         if (m != null)
             m.remove(this);
     }
     
     public T get() {
             Thread t = Thread.currentThread();
             ThreadLocalMap map = getMap(t);
             if (map != null) {
                 ThreadLocalMap.Entry e = map.getEntry(this);
                 if (e != null) {
                     @SuppressWarnings("unchecked")
                     T result = (T)e.value;
                     return result;
                 }
             }
             return setInitialValue();
     }
```

Thread上绑定的ThreadLocalMap： java.lang.Thread#threadLocals

## InheritableThreadLocal

绑定在线程上的继承的ThreadLocalMap，Spring中的RequestContextHolder也是依靠他来实现请求上下文信息的线程上的继承。

``` java
    /**
     * Get the map associated with a ThreadLocal.
     *
     * @param t the current thread
     */
    ThreadLocalMap getMap(Thread t) {
       return t.inheritableThreadLocals;
    }

    /**
     * Create the map associated with a ThreadLocal.
     *
     * @param t the current thread
     * @param firstValue value for the initial entry of the table.
     */
    void createMap(Thread t, T firstValue) {
        t.inheritableThreadLocals = new ThreadLocalMap(this, firstValue);
    }
```
Thread上绑定的inheritableThreadLocals： java.lang.Thread#inheritableThreadLocals，在线程创建的时候会当前线程的inheritableThreadLocals赋值给子线程，具体位置可查看Thread的构造函数。

``` java
private void init(ThreadGroup g, Runnable target, String name,
                      long stackSize, AccessControlContext acc) {
        if (name == null) {
            throw new NullPointerException("name cannot be null");
        }

        this.name = name;

        Thread parent = currentThread();
        SecurityManager security = System.getSecurityManager();
        if (g == null) {
            /* Determine if it's an applet or not */

            /* If there is a security manager, ask the security manager
               what to do. */
            if (security != null) {
                g = security.getThreadGroup();
            }

            /* If the security doesn't have a strong opinion of the matter
               use the parent thread group. */
            if (g == null) {
                g = parent.getThreadGroup();
            }
        }

        /* checkAccess regardless of whether or not threadgroup is
           explicitly passed in. */
        g.checkAccess();

        /*
         * Do we have the required permissions?
         */
        if (security != null) {
            if (isCCLOverridden(getClass())) {
                security.checkPermission(SUBCLASS_IMPLEMENTATION_PERMISSION);
            }
        }

        g.addUnstarted();

        this.group = g;
        this.daemon = parent.isDaemon();
        this.priority = parent.getPriority();
        if (security == null || isCCLOverridden(parent.getClass()))
            this.contextClassLoader = parent.getContextClassLoader();
        else
            this.contextClassLoader = parent.contextClassLoader;
        this.inheritedAccessControlContext =
                acc != null ? acc : AccessController.getContext();
        this.target = target;
        setPriority(priority);
        if (parent.inheritableThreadLocals != null)
            this.inheritableThreadLocals =
                ThreadLocal.createInheritedMap(parent.inheritableThreadLocals);
        /* Stash the specified stack size in case the VM cares */
        this.stackSize = stackSize;

        /* Set thread ID */
        tid = nextThreadID();
    }
```

### InheritableThreadLocal补充

InheritableThreadLocal允许自定义子线程可继承的值，默认为可继承，开发人员可通过覆盖```java.lang.InheritableThreadLocal#childValue```方法来改变InheritableThreadLocal继承的行为。
