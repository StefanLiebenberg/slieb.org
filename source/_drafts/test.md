---
title: "Javascript in Rhino"
layout: "post"
author: "Stefan Liebenberg"
---

## The basics:

```java
import org.mozilla.javascript.Context;
import org.mozilla.javascript.ContextFactory;
import org.mozilla.javascript.tools.shell.Global;

public class App {

  public static void main(String[] args) {

   // creating a context
   Context context = ContextFactory.getGlobal().enterContext();
   context.setOptimizationLevel(-1);
   context.setLanguageVersion(Context.VERSION_1_5);
   Global scope = new Global(context);

   // evaluating string
   String source = "/some/path/script.js";
   String code   = "return {};";
   Object result = context.evaluateString(scope, code, source, 1, null);

   // closing
   context.close();

  }

}
```


## Tricks

### ignoring java variables

I had trouble with google closure.

```java
context.evaluateString(scope, "com = undefined; java = undefined; Package = undefined;", "inline", 1, null);
```



See using rhino with envjs.



