---
layout: post
title: Shaking unused Soy templates from a compiled Javascript Tree.
tags: [spring, soy, java]
description: A customer compiler pass that optimizes soy files  
---

Soy supports a special template type: Delegate Templates. These templates are not called directly, but are instead managed by a registration system. This 
system allows us to override delegate template's with each other.
 
When compiled to javascript, they take this form:
 
```javascript

namespace.__delegateTemplate_01 = function (opt_data, opt_ignore, opt_ijData) {
  return "content";
};
soy.$$registerDelegateFn(soy.$$getDelegateId("MyTemplate"), "MyVariant", 0);

```

And you can call them like this:


```javascript
  var template = soy.$$getDelegateFn(soy.$$getDelegateId("MyTemplate"), "MyVariant");
  var content = template({}).getContent();
```

A drawback is that because there are no direct calls between templates, the standard optimizations in the closure compiler cannot effectively shake unused 
templates, resulting in unnecessary code being included into the final product, but using a custom compiler pass, we can analyse the delegate 
registrations and remove those that are not needed.

There are two types of unused templates, those that are overridden and those that are not never called. Removing delegate templates that are overridden is 
straighforward. We scan the tree 

Analysing the tree, templates that first category 1 is fairly easy to find, but 2 is more difficult and depends on how strictly the soy.* namespace is used.


 
 
For example: 

```javascript

Component.prototype.doSomething = function(data) {
    var template = soy.$$getDelegateFn(soy.getDelegateId("FooTemplate"), "MyVariant"));
    return template(data);
};

```

Given the above code, we can mark the delegate template "FooTemplate" with "MyVariant" as definitely used. 



```javascript

Component.prototype.doSomething = function(data) {
  var templateId = this.getElementId();
  var templateVariant = this.getTemplateVariant();
  var template = soy.$$getDelegateFn(templateId, templateVariant);
  return template(data);
};

```

When we see this method, we have no idea what values `templateId` or `templateVariant` could be, so we cannot say for sure what templates are used/unused.
 
There are however some steps we can take. We can remove templates for which we do not find any uses of `soy.$$getDelegateId`, or we can try to analyse which 
id's are "strict" vs "not strict" and treat them accordingly.


