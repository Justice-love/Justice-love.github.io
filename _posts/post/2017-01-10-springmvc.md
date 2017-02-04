---
layout: post
title:  "spring mvc表单参数传递"
date:   2017-01-10
excerpt: "记一次spring mvc表单提交集合对象参数传递报错问题"
tag:
- spring
- spring mvc
comments: true
---
### 问题
spring mvc表单提交集合对象参数传递报错

### 页面代码

{% highlight html %}
{% raw %}
<form action="swingAdd.html" method="post">
<hr/>
<p>

id:<input type="text" name="list[0].id"/>,
root: <select name="list[0].root"><option value="false">false<option><option value="true" selected="selected">true<option><select>,
expression:<input type="text" name="list[0].expression"/>,
validate_type:<select name="list[0].validateType"><option value="buyPrice">buyPriceo<ption><select>,
expect:<input type="text" name="list[0].expect"/>,
or_else:<input type="text" name="list[0].orElse"/>,
child_id:<input type="text" name="list[0].child"/>。 <input type="button" onclick="addChild(this);" value="增加子节点"/>

<p>
<input type="submit" value="提交"/>
<form>
{% endraw %}
{% endhighlight %}

### controller 代码
{% highlight java %}
{% raw %}
@RequestMapping(value = "/swingAdd", method = RequestMethod.POST)
    public String swingAdd(SwingFormList formList, Model model) {
//        System.out.println(swingList);
  return "swing/swingRule";
    }
{% endraw %}
{% endhighlight %}

### SwingFormList源码

{% highlight java %}
{% raw %}
public class SwingFormList {
    private List<Swing> list;

    public List<Swing> getList() {
        return list;
    }

    public void setList(List<Swing> list) {
        this.list = list;
    }
}
{% endraw %}
{% endhighlight %}

### Swing源码
{% highlight java %}
{% raw %}
public class Swing {

    //REQUIRED
  private String id;
    private String expression;
    private Validater validateType;
    private String expect;
    //IMPLIED
  private boolean autoTrigger;
    private String orElse;
    private String executor;
    private Swing child;
    //other
  private boolean root;
 }
{% endraw %}
{% endhighlight %}
没拷贝 get/set方法了

### 页面错误信息

```
There was an unexpected error (type=Bad Request, status=400).

Validation failed for object='swingFormList'. Error count: 1
```

### 补充出错原因
child name 为```child_id:<input type="text" name="list[0].child"/>```， 而 ```Swing.class == org.eddy.swing.entity.Swing#child.getClass()```
spring会尝试获取参数为一个字符串类型的构造函数并newInstance

__spring代码见下方__

org.springframework.beans.TypeConverterDelegate#convertIfNecessary(java.lang.String, java.lang.Object, java.lang.Object, java.lang.Class<T>, org.springframework.core.convert.TypeDescriptor)

{% highlight java %}
else if (convertedValue instanceof String && !requiredType.isInstance(convertedValue)) {
   if (conversionAttemptEx == null && !requiredType.isInterface() && !requiredType.isEnum()) {
      try {
         Constructor<T> strCtor = requiredType.getConstructor(String.class);
         return BeanUtils.instantiateClass(strCtor, convertedValue);
      }
      catch (NoSuchMethodException ex) {
         // proceed with field lookup
  if (logger.isTraceEnabled()) {
            logger.trace("No String constructor found on type [" + requiredType.getName() + "]", ex);
         }
      }
      catch (Exception ex) {
         if (logger.isDebugEnabled()) {
            logger.debug("Construction via String failed for type [" + requiredType.getName() + "]", ex);
         }
      }
   }
{% endhighlight %}
__由于我没有定义一个参数为一个String对象的构造函数，导致在赋值的时候产生了异常。__

### 补充
spring 能够调用目标类型的工厂方法来构造对象。

见：__org.springframework.core.convert.support.ObjectToObjectConverter#determineFactoryMethod__
{% highlight java %}
private static Method determineFactoryMethod(Class<?> targetClass, Class<?> sourceClass) {
  if (String.class == targetClass) {
    // Do not accept the String.valueOf(Object) method
    return null;
  }

  Method method = ClassUtils.getStaticMethod(targetClass, "valueOf", sourceClass);
  if (method == null) {
    method = ClassUtils.getStaticMethod(targetClass, "of", sourceClass);
    if (method == null) {
      method = ClassUtils.getStaticMethod(targetClass, "from", sourceClass);
    }
  }
  return method;
}
{% endhighlight %}

触发方法:

org.springframework.beans.TypeConverterDelegate#convertIfNecessary(java.lang.String, java.lang.Object, java.lang.Object, java.lang.Class<T>, org.springframework.core.convert.TypeDescriptor)

{% highlight java %}
ConversionService conversionService = this.propertyEditorRegistry.getConversionService();
if (editor == null && conversionService != null && newValue != null && typeDescriptor != null) {
  TypeDescriptor sourceTypeDesc = TypeDescriptor.forObject(newValue);
  if (conversionService.canConvert(sourceTypeDesc, typeDescriptor)) {
    try {
      return (T) conversionService.convert(newValue, sourceTypeDesc, typeDescriptor);
    }
    catch (ConversionFailedException ex) {
      // fallback to default conversion logic below
      conversionAttemptEx = ex;
    }
  }
}
{% endhighlight %}

具体位置 __return (T) conversionService.convert(newValue, sourceTypeDesc, typeDescriptor);__
