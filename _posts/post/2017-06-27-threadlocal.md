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