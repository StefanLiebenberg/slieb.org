---
layout: post
title: Using Soy Templates in Spring MVC - Part 2
tags: [spring, soy, java]
description: A guide to using soy templates in spring - Part 2
---

In [Part 1](/blog/SoyInSpring_part1), we enabled soy templates in a spring mvc application. We still need to allow insert data and 
configure custom plugins. Lets start with a template 
that uses data.

 
**src/main/resources/templates/pages.soy:**

```soy
{namespace pages}

/**
 * The hello world home page.
 * @param Timestamp
 */
{template .HomePage}
  <html>
    <head>
    </head>
    <body>
      <h1>Hello World</h1>
      <p>Its {$Timestamp} now</p>
    </body>
  </html>
{/template}
```


```java
@Controller
@RequestMapping("/pages")
public class HelloWorldController {

  @RequestMapping("home", method = GET)
  public String homePage(Model mode) {
    model.addAttribute("Timestamp", Instant.now().toString());
    return "soy:pages.HomePage";
  }
  
}
```



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
             renderer
                 .setData(data)
                 .setContentKind(ContentKind.HTML)
                 .render(writer);
        }                  
   }
                      
 }
```

## Translating Custom data into SoyData

The spring Model interface might not always work with templates, especially if you start using custom data types.
  
**src/main/java/com/example/HTMLSoyRendererView.java:**
 
```java
 public class HTMLSoyRendererView implements View {
 
   private final SoyTofu.Renderer renderer;
   
   private final Function<Map<String, ?>, SoyRecord> dataConverter;
   
   public HTMLSoyRendererView(SoyTofu.Renderer renderer, Function<Map<String, ?>, SoyRecord> dataConverter) {
     this.renderer = renderer;
     this.dataConverter = dataConverter;
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
             renderer
                 .setData(dataConverter.apply(data))
                 .setContentKind(ContentKind.HTML)
                 .render(writer);
        }                  
   }
                      
 }
```  
  
  
  





