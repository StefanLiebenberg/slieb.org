---
layout: default
title: goog.Disposable
---


At the core of the closure library is the ```goog.Disposable``` class. This class provides a ```.dispose``` method that we use to destruct complex classes. In the most basic form, it goes like this:

```javascript
  var disposable = new goog.Disposable();
  disposable.dispose();
```

For arguments sake, lets assume our class is supposed to listen to some event.

```javascript
/**
 * @constructor
 * @param {!Element} element
 */
var myClass = function (element) {
  /** @type {!Element} */
  this.element = element;
  goog.events.listen(element, 'click', this.onClick, undefined, this);
};

/**
 * @param {goog.events.Event} event
 */
myClass.prototype.onClick = function(event) {
  // do click stuff
};
```

And we need to ```unlisten``` this event as soon as the instance is discarded. **goog.Disposable** objects gives us the ability to specify destructors to our code, by overwritting the ```disposeInternal``` method.

```javascript
/**
 * @constructor
 * @extends {goog.Disposable}
 * @param {!Element} element
 */
var myClass = function (element) {
  myClass.base(this, 'constructor'); // super call

  /** @type {!Element} */
  this.element = element;
  goog.events.listen(element, 'click', this.onClick, undefined, this);
};
goog.inherits(myClass, goog.Disposable);


/** @override */
myClass.prototype.disposeInternal = function () {
  goog.events.unlisten(this.element, 'click', this.onClick, undefined, this);
};

/**
 * @param {goog.events.Event} event
 */
myClass.prototype.onClick = function(event) {
  // do click stuff
};
```

Now, no click events would fire after we call the the .dispose() method.


We can also attach callbacks to any disposable object:

```javascript
var mine = new myClass();
mine.addOnDisposeCallback(function () {
  alert('disposed!'); // do destructor stuff here!
});
mine.dispose();
```

or we can chain disposable objects together, so that you only need to dispose the top one.

```javascript
var parent = new goog.Disposable();
var child = new goog.Disposable();
parent.registerDisposable(child);
parent.dispose(); // also disposes child.
```


