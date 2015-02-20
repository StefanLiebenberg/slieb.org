---
layout: default
title: goog.Disposable
---



A disposable object, as the implies, is something that you can dispose. In the most basic form, it goes like this:

```javascript
  var disposable = new goog.Disposable();
  disposable.dispose();
```


goog.Disposable objects gives us the ability to specify destructors to our code.



```javascript
/**
 * @constructor
 * @extends {goog.Disposable}
 */
var myClass = function () {
  myClass.base(this, 'constructor');
};
goog.inherits(myClass, goog.Disposable);

/**
 * @override
 */
myClass.prototype.disposeInternal = function () {
  // do distructor stuff here.
};
```

```javascript
var parent = new goog.Disposable();
var child = new goog.Disposable();
parent.registerDisposable(child);
parent.dispose(); // also disposes child.
```


```javascript
var disposable = new goog.Disposable();
disposable.addOnDisposeCallback(function () {
  alert('disposed!');
});
disposable.dispose();
```