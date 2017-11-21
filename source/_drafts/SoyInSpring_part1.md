---
layout: post
title: Using soy templates in Spring MVC - Part 1
tags: [spring, soy, java]
description: A guide to using soy templates in spring.
---

Recently, I was tasked with writing a very small spring app and as an experiment I wanted to see if I could use soy templates instead of the usual jsp.
 
 
 
## The Soy Template

Starting with a very basic soy template. One that does not contain data, plugins, injected data or globals. The 'Hello World' home page. This is a singlurary
 template at pages.HomePage that prints out the required html. To keep things simple, I won't cover using data in the template or adding custom plugins.
 
**src/main/resources/templates/pages.soy:**

```soy
{namespace pages}

/**
 * The hello world home page.
 */
{template .HomePage}
  <html>
    <head>
    </head>
    <body>
      <h1>Hello World</h1>
    </body>
  </html>
{/template}
```


## The Crude Controller

In spring, the natural place to serve this from would be a controller. You would return the template name as a string from a method and spring would render 
that template for you internally. As a first, crude, attempt. We will tell soy to just render what we provide with the `@ResponseBody` and render the 
template ourselves.   


**src/main/java/com/example/HelloWorldController.java:**

```java
@Controller
@RequestMapping("/pages")
public class HelloWorldController {

  @RequestMapping("home", method = GET)
  @ResponseBody
  public String homePage() {
     SoyFileSet.Builder builder = SoyFileSet.builder();
     builder.add(getClass().getResource("/templates/pages.soy"))
     SoyFileSet soyFileSet = builder.builder();
     SoyTofu tofu = soyFileSet.compileToTofu();
     SoyTofu.Renderer renderer = tofu.newRenderer("pages.HomePage");
     renderer.setContentKind(ContentKind.HTML);
     return renderer.render();
  }
  
}
```

## Bean Configuration

We can construct the `SoyTofu` object once as a `@Bean` instead of creating it on each request. This will clean up our code and make creating a **View** 
and **ViewResolver** easier. 


**src/main/java/com/example/HelloWorldConfiguration.java**

```java
@Configuration
public class HelloWorldConfiguration {

  /**
   * Constructs a SoyTofu object where we can find templates
   */ 
  @Bean
  public SoyTofu tofu(Injector guiceInjector) {
     SoyFileSet.Builder builder = SoyFileSet.builder();
     builder.add(getClass().getResource("/templates/pages.soy"))
     SoyFileSet soyFileSet = builder.builder();
     return soyFileSet.compileToTofu();
  }
  
}
```

Now we can just access the tofu object as a parameter.

**src/main/java/com/example/HelloWorldController.java:**

```java
@Controller
@RequestMapping("/pages")
public class HelloWorldController {

  @RequestMapping("home", method = GET)
  @ResponseBody
  public String homePage(SoyTofu tofu) {
      return tofu.newRenderer("pages.HomePage").setContentKind(ContentKind.HTML).render();
  }
  
}
```

## Using a View and ViewResolver

First we replace the `@ResponseBody` annotation on the controller method and return a implementation View directly.  

**src/main/java/com/example/HTMLSoyRendererView.java:**
 
 ```java
 public class HTMLSoyRendererView implements View {
 
   private final SoyTofu.Renderer renderer;
   
   public HTMLSoyRendererView(SoyTofu.Renderer renderer) {
     this.renderer = renderer;
   }
   
   @Override
   public String getContentType() {
     return "text/html";
   }
 
   @Override
   public void render(Map<String, ?> data, 
                      Request request,
                      Response response) throws Exception {             
        try(Writer writer = response.getWriter()) {
             renderer.setContentKind(ContentKind.HTML).render(writer);
        }                  
   }
                      
 }
 
 ```
 
 
 
**src/main/java/com/example/HelloWorldController.java:**

```java
@Controller
@RequestMapping("/pages")
public class HelloWorldController {

  @RequestMapping("home", method = GET)
  @ResponseBody
  public View homePage(SoyTofu tofu) {
      return new HTMLSoyRendererView(tofu.newRenderer("pages.HomePage"));
  }
  
}
```


And then we can configure Spring to create this view internally using a View resolver. 



```java
public class HTMLSoyRendererViewResolver implements ViewResolver {

  private final SoyTofu tofu
  
  public HTMLSoyRendererViewResolver(SoyTofu tofu) {
    this.tofu = tofu;
  }
  
 
  @Override
  public HTMLSoyRendererView render(String viewName, Locale locale) throws Exception {
    if(viewName.startsWith("soy:")) {
      return tofu.newRenderer(viewName.replaceFirst("soy:", ""));
    }
    return null;
  }
                     
}
```


```java
@Configuration
public class HelloWorldConfiguration {

  /**
   * Constructs a SoyTofu object where we can find templates
   */ 
  @Bean
  public SoyTofu tofu() {
     SoyFileSet.Builder builder = SoyFileSet.builder();
     builder.add(getClass().getResource("/templates/pages.soy"))
     SoyFileSet soyFileSet = builder.builder();
     return soyFileSet.compileToTofu();
  }
  
  
  /**
   * Constructs a SoyTofu object where we can find templates
   */ 
  @Bean
  public HTMLSoyRendererViewResolver htmlSoyRendererViewResolver(SoyTofu tofu) {
      return HTMLSoyRendererViewResolver(tofu);
  }  
}
```


Now our controller will look like this and should render our content.

```java
@Controller
@RequestMapping("/pages")
public class HelloWorldController {

  @RequestMapping("home", method = GET)
  public String homePage() {
    return "soy:pages.HomePage";
  }
  
}
```

## Next Steps:

We should now be ready to add the model data the template rendering. [See the next post](/blog/SoyInSpring_part2/). 


