---
title: "goog.events.EventHandler in Google Closure"
layout: "post"
author: "Stefan Liebenberg"
---

## Description

Managing events in the component lifecycle is made very easy with the use of goog.events.EventHandler.




## enterDocument

```javascript

my.Component.prototype.enterDocument = {
   this.domHandler = new goog.events.EventHandler(this);
};

```

## exitDocument

```javascript

my.Component.prototype.exitDocument = {
   if(goog.isDefAndNotNull(this.domHandler) && !this.domHandler.isDisposed()) {
     this.domHandler.dispose();
   }
};

```