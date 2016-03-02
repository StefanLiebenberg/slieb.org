---
layout: post
title: Java 8 Functional Interfaces with Exceptions
published: true
---

One problem with using lambda's in Java 8, is that dealing with checked exceptions results in unnecessary exception handling code. Consider a lambda of 
`Function` where you  need to deal with an `IOException`: 


```java
public List<String> mapFiles(List<File> files,  Function<File, String> function) {
  return files.stream().map(function).collect(Collectors.toList());
}

public List<String> readFiles(List<File> files) {
  return mapFiles(files, FunctionWithIO.toSafeFunction(file -> {
    try {
      // some method that throws IOException
      return IOUtils.toString(file);   
    } catch(IOException io) {
      throw new RuntimeException(io);
    }
  }));
}
```

To add `try-catch` statements in all of our lambda's is a tedious exercise, and only helps us hide exceptions. We can start to improve the situation with 
the following interface and helper method:
 
 
```java
@FunctionalInterface
public interface FunctionWithIO<A, B> {

  // The functional interface method, notice it declares a throws exception.
  B apply(A value) throws IOException;
  
  // helper method to catch the declared method and rethrow as a checked exception.
  public static <A, B> Function<A, B> toSafeFunction(final FunctionWithIO<A, B> functionWithIO) {
    return (value) -> {
      try {
        return functionWithIO.apply(value);
      } catch(IOException io) {
        throw new RuntimeException(io);  
      }
    };
  }
}
```

And now our original method is simplified to:


```java
public List<String> mapFiles(List<File> files,  Function<File, String> function) {
  return files.stream().map(function).collect(Collectors.toList());
}

public List<String> readFiles(List<File> files) {
  return mapFiles(files, FunctionWithIO.toSafeFunction(file -> {
      // some method that throws IOException
      return IOUtils.toString(file);
  }));
}
```

We can take this further...

Currently, if needed checked exceptions thrown inside a `forEach` or `map` method on Stream, we have to use `toSafeFunction` to turn this interface into a 
usable `Function` interface. If the interface `FunctionWithIO` extended the original `Function` interface, it could be used directly.  


```java
@FunctionalInterface
public interface FunctionWithIO<A, B> extends Function<A, B> {

  // The functional interface method, notice it declares a throws exception.
  B applyWithIO(A value) throws IOException();

  @Overwrite
  default B apply(A value) {
      try {
        return functionWithIO.apply(value);
      } catch(IOException io) {
        throw new RuntimeException(io);  
      }  
  }
  
  // helper method to cast lambda's as FunctionWithIO.
  public static <A, B> FunctionWithIO<A, B> castFunctionWithIO(final FunctionWithIO<A, B> functionWithIO) {
     return functionWithIO;
  }
}
```

Now we only have to specify that its the 'WithIO' interface in mapFile's, and everything is taken care of.

```java
public List<String> mapFiles(List<File> files,  FunctionWithIO<File, String> functionWithIO) {
  return files.stream().map(functionWithIO).collect(Collectors.toList());
}

public List<String> readFiles(List<File> files) {
  return mapFiles(files, file -> {
      // some method that throws IOException
      return IOUtils.toString(file);
  });
}
```


##The Library

To solve this problem for all interfaces and for exceptions other than just IOException, I've created [throwable-interfaces][1] ( on [github][2] ). For any 
Functional interface in `java.util.function.*` this library will provide a corresponding "WithThrowable" interface. 

For example, there is a `Function<A, B>` interface in `java.util.function.*`, so there the library provides a `FunctionWithThrowable<A, B, E extends 
Throwable>` interface in the library.

###Cast Method

Each interface has a "cast...WithThrowable" method that just casts any lambda into the WithThrowable version.

```java
  files.stream()
     .filter(PredicateWithThrowable.castPredicateWithThrowable(file -> detectMimeType(file).equals("text/html"))) // PredicateWithThrowable example
     .map(FunctionWithThrowable.castFunctionWithThrowable(IOUtils::toString))                                     // FunctionWithThrowable example
     .forEach(ConsumerWithThrowable.castConsumerWithThrowable(content -> {                                        // ConsumerWithThrowable example
        // do stuff with content that throws Exception.
     });
```

###Convert Method

If you use the WithThrowable interface in methods, you might sometimes want to pass in a original interface. Each WithThrowable interface implements a "as..
.WithThrowable()" method to aid the conversion.
 
```java
  public List<String> mapFilesWithIO(List<File> files, FunctionWithThrowable<File, String, IOException> functionWithThrowable) {
    return files.stream().map(functionWithThrowable).collect(Collectors.toList());
  }
  
  public List<String> mapFiles(List<File> files, Function<File, String> function) {
    return mapFilesWithIO(files, FunctionWithThrowable.asFunctionWithThrowable(function)); // contrived example to demonstrate conversion.
  }
```

###SuppressedException and unwrapping

Instead of throwing a new instance of RuntimeException method, the WithThrowable interfaces will always wrap any caught exceptions as `SuppressedExceptions',
 so that you can catch them specifically. Here is three different ways you can unwrap exceptions.
 
```java
public List<String> mapFilesWithIO(List<File> files, FunctionWithThrowable<File, String, IOException> functionWithThrowable) throws Throwable {
  try {
    return files.stream().map(functionWithThrowable).collect(Collectors.toList());
  } catch(SuppressedException e) {
    throw e.getCause();
  }
}
```

```java
public List<String> mapFilesWithIO(List<File> files, FunctionWithThrowable<File, String, IOException> functionWithThrowable) throws IOException {
  try {
    return files.stream().map(functionWithThrowable).collect(Collectors.toList());
  } catch(SuppressedException e) {
    throw SuppressedException.unwrapException(e, IOException.class).orElseThrow(() -> e);
  }
}
```


```java
public List<String> mapFilesWithIO(List<File> files, FunctionWithThrowable<File, String, IOException> functionWithThrowable) throws IOException {
  return SuppressedException.unwrapException(() -> {
    return files.stream().map(functionWithThrowable).collect(Collectors.toList());
  }, IOException.class);
}
```


###Exception Handling

All the WithThrowable interfaces have some level of exception handling. All interfaces have the `.onException()` and `.withLogging()` methods. Interfaces 
that return a value has the `.thatReturnsOptional()` method, and interfaces with void methods have the `.thatThrowsNothing()` method.

####onException()

The `onException()` method allows you define some custom exception handling code. eg

```java
  files.stream().forEach(
      ConsumerWithThrowable.castConsumerWithThrowable(file -> {
        // do some io stuff with file.
      }).onException(exception, args -> {
        // do something with the exception ( logging? ) and the args passed to consumer
      })
    );
```

####withLogging()

The `withLogging()` will log any exceptions to a slf4j logger.

```java
  files.stream().forEach(
      ConsumerWithThrowable.castConsumerWithThrowable(file -> {
        // do some io stuff with file.
      }).withLogging())
    );
```

####thatThrowsNothing()

The `thatThrowsNothing()` method will ignore any exceptions. 

```java
  files.stream().forEach(
      ConsumerWithThrowable.castConsumerWithThrowable(file -> {
        // do some io stuff with file.
      }).thatThrowsNothing())
    );
```


####thatReturnsOptional()

The `.thatReturnsOptional()` will change the return type into an optional that will be empty if an exception was caught.

```java
  List<Optional<String>> readAttempts = files.stream()
    .map(FunctionWithThrowable.castConsumerWithThrowable(file -> {
        return IOUtils.toString(file);
    }).thatReturnsOptional()))
    .collect(Collectors.toList());
```

You can chain these methods together:


```java
  files.stream().forEach(ConsumerWithThrowable
     .castConsumerWithThrowable(file -> {
        // do some io stuff with file.
     })
     .withLogging()
     .thatThrowsNothing())
   );
   
  List<Optional<String>> readAttempts = files.stream()
    .map(
      FunctionWithThrowable
      .castConsumerWithThrowable(file -> IOUtils.toString(file))
      .onException(exception, args -> System.err.println(exception.getMessage()))
      .thatReturnsOptional())
    )
    .collect(Collectors.toList());
```

 

###Features:

* All "WithThrowable" interfaces extend the corresponding interfaces in `java.util.function.*`, so you can use them in the sample methods ( eg, Stream, 
Optional, etc ) 
* If an exception occurs inside these methods, it is rethrown as a SuppressedException, which is unchecked. So you can always catch it again. The 
SuppressedException.unwrapSuppressedException() is a utility method that does this for you. 
* There is exception handling baked into the "WithThrowable" classes, see the methods `.thatReturnsOptional()`, `.thatThrowsNothing()`, `.onException()` 
and `.withLogging()`
 


Here is a few example cases with [FunctionWithThrowable][3]

```java

public String fileToString(File file) throws IOException {
  return IOUtils.toString(file);
}

/**
 * No need to try-catch for the IOException that fileToString will throw.
 */
public List<String> filesToString(List<File> files) {
  return files.stream().map(FunctionWithThrowable.castWithThrowable(file -> fileToString(file)));
}


/**
 * You can accept the interface's in methods.
 */
public List<String> filesToStringWithCustomMapping(List<File> files, FunctionWithThrowable<File, String, IOException> functionWithThrowable) {
  return files.stream().map(functionWithThrowable);
}

/**
 * Showing how the ioException can be thrown inside a lambda when you're casting to FunctionWithThrowable.
 */
public List<String> filesToStringInvalid(List<File> files) {
  return filesToStringWithCustomMapping(files, file -> {
    throw new IOException("no io done here!");
  });
}

/**
 * If you need to the checked exceptions that happen inside lambda's, you
 * can use `SuppressedException.unwrapSuppressedException` to access them again.
 */
public List<String> filesToStringWithIO(List<File> files) throws IOException {
  return SuppressedException.unwrapSuppressedException(() -> {
    return filesToString(files);
  }, IOException.class);
}
```


   
  
[1]:http://stefanliebenberg.github.io/throwable-interfaces/project-info.html
[2]:https://github.com/StefanLiebenberg/throwable-interfaces/
[3]:http://stefanliebenberg.github.io/throwable-interfaces/apidocs/index.html