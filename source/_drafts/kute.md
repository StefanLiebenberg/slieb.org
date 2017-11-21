---
layout: post
title: Kute, a Java 8 resource management library
description: Kute is a resource management library built around two main interfaces, <code>Resource.Readable</code> and <code>Resource.Provider</code>. 
             The first represents some resource that has a path and content, while second represents a container that has many resources. A directory could be 
             represented as a <code>Resource.Provider</code> that provides many file resources.
tags: [kute, java]
---


##The resource interface: Resource.Readable  

```java

  // just the basic methods of a Resource.Readable
  public void handleResource(Resource.Readable resource) throws IOException {
    resource.getReader(); // returns a reader that will read the resource.
    resource.getInputStream(); // returns a input stream that will read the resource.
    resource.getPath(); // returns the string path of a resource.
  }
  
```

##The container interface: Resource.Provider

```java

  // just the basic methods of a Resource.Provider
  public void handleProvider(Resource.Provider provider) throws IOException {
     provider.stream(); // return Stream<Resource.Readable>
     provider.getResourceByPath("/some/path"); //returns Optional<Resource.Readable>
  }
  
```


##The result of the library

###Kute:
```java
  Kute.defaultProvider(); // provider for the entire classpath
```

###KuteFactory:

```java
  KuteFactory.urlResource(url); // constructs resource from url
```

###KuteIO:

```java
  KuteIO.readResource(resource); // returns string of resource content
```