
goog.provide('com.MyClass');
goog.require('goog.Disposable');

/**
 * @constructor
 * @extends {goog.Disposable}
 */
com.MyClass = function () {
    com.MyClass.base(this, 'constructor', goog.Disposable);

    // uncomment and add the following require -> goog.require('some.random.foo');
    // this.x = some.random.foo();

};
goog.inherits(com.MyClass, goog.Disposable);
