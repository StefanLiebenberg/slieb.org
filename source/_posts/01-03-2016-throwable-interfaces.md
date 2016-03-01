---
layout: post
title: Java 8 Functional Interfaces with Exceptions
published: true
---

##Pre-Amble:

Java 8 Lambdas allow us to write code that is very compact, yet readable. One limitation is that checked exceptions gets in the way. Consider the following 
method:


```java
public Stream<File> findFiles(List<File> directories) {
  return directories.stream().flatMap(dir -> {
    try {
      return Files.walk(dir.toPath());
    } catch(IOException io) {
      throw new RuntimeException(io);
    }
  });
}
```

Rethrowing the `IOException` in all lambda statements is a tedious enterprise, so we could create a helper method:
 
 
```java

public class FunctionHelper { 

  @FunctionalInterface
  public interface FunctionWithIO<A, B> {
    B apply(A value) throws IOException;
  }

  public static <A, B> Function<A, B> safeFunction(final FunctionWithIO<A, B> functionWithIO) {
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
public Stream<File> findFiles(List<File> directories) {
  return directories.stream().flatMap(FunctionHelper.safeFunction(dir -> Files.walk(dir.toPath()));
}
```

##The Library

To solve this problem for all interfaces, I've created [throwable-interfaces][1] ( on [github][2] ). For any Functional interface Foo in `java.util.function.*` 
this library will provide a corresponding "WithThrowable" interface. 

For example, there is a `Function<A, B>` interface in `java.util.function.*`, so there the library provides a `FunctionWithThrowable<A, B, E extends 
Throwable>` interface.  

###Features:

* All "WithThrowable" interfaces extend the corresponding interfaces in `java.util.function.*`, so you can use them in the sample methods ( eg, Stream, 
Optional, etc ) 
* If an exception occurs inside these methods, it is rethrown as a SuppressedException, which is unchecked. So you can always catch it again. The 
SuppressedException.unwrapSuppressedException() is a utility method that does this for you. 
* There is exception handling baked into the "WithThrowable" classes, see the methods `.thatReturnsOptional()`, `.thatDoesNothing()`, `.onException()` 
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