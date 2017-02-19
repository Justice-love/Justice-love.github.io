---
layout: post
title:  "AbstractProcessor"
date:   2017-02-19
excerpt: "编译期运行，对指定注解的类源文件进行额外操作"
tag:
- java
- annotation
comments: true
---

> 新建过注解的同学肯定知道```java.lang.annotation.RetentionPolicy#SOURCE```，而AbstractProcessor就是配合源码期保留的注解来进行一些列工作的。

## 编写一个源码期注解

{% highlight java %}
{% raw %}
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.SOURCE)
@Documented
public @interface CheckFile {
}
{% endraw %}
{% endhighlight %}

## 实现自己的AbstractProcessor类

* 继承抽象类AbstractProcessor
* 指定AbstractProcessor所支持的注解类型
* 实现抽象方法process
    * 可以使用javax.annotation.processing.ProcessingEnvironment，为父类的属性，访问权限为子类可见。

{% highlight java %}
{% raw %}
@SupportedAnnotationTypes({"org.eddy.CheckFile"})
public class AbstractProcessorImpl extends AbstractProcessor {
    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        Messager messager = processingEnv.getMessager();
        annotations.stream().forEach(an -> {
            roundEnv.getElementsAnnotatedWith(an).stream().forEach(el -> {
                messager.printMessage(Diagnostic.Kind.NOTE, "Element:" + el);
            });

        });
        return true;
    }

    @Override
    public SourceVersion getSupportedSourceVersion() {
        return SourceVersion.latestSupported();
    }
}
{% endraw %}
{% endhighlight %}

## 修改pom文件

* 指定编译期不执行任何AbstractProcessor，否则会出现问题 -proc:none
* 主要代码```-proc:none```
{% highlight xml %}
{% raw %}
    <build>
        <plugins>
            <plugin>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>2.3.2</version>
                <configuration>
                    <source>1.6</source>
                    <target>1.6</target>
                    <!-- 禁止自己执行任何AbstractProcessor -->
                    <compilerArgument>-proc:none</compilerArgument>
                </configuration>
            </plugin>
        </plugins>
    </build>
{% endraw %}
{% endhighlight %}

## 增加SPI配置

* 增加SPI实现，接口为```javax.annotation.processing.Processor```，实现类为```org.eddy.AbstractProcessorImpl```