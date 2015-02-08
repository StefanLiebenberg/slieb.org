---
title: "Running the latest Google Closure libraries in maven"
layout: post
---

## Introduction

Applications built in google closure require four parts.

- The google library
- The google template compiler
- The google stylesheets compiler
- The google javascript compiler

Google maintains these projects seperately on github, but getting the latest versions in maven is always proved difficult. Using jenkins we've managed to create a automated proccess that deploys the latest versions of these as maven jar files to our internal nexus server.

One remaining issue is that we deploy the maven artifacts using a jenkins generated BUILD_ID variable, using some sort of SNAPSHOT system would improve the situation.

## Solutions

This article assumes you have a server with jenkins and nexus succesfully setup. Jenkins will have to have ant, maven, git and java configured correctly.

### [Closure Library][1]

The closure-library on github is just a collection of JavaScript files that we require as a dependency to our javascript libraries. There is no build.xml or pom.xml to turn this into a maven artifact.

- create a new "Freestyle" job in jenkins called "closure-library"
- add a "invoke shell script" with content

  ```bash
    rm -r closure-library-resources;
  ```

- set https://github.com/google/closure-library as git repository
- add a "checkout to sub directory" option and set it to "closure-library-resources"
- add a "invoke maven top-level goal" and set to "archetype:generate -D...."
- add a "invoke shell script" with the content

  ```bash
    rm -r src/{main,test}/java;
    git export --git-dir closure-library-git/.git -a --prefix=closure-library-resources/src/main/resources/
  ```

- add a "invoke maven top-level goal" and set to "deploy -Durl..."

### [Closure Templates][2]

 - Create jenkins job called closure-templates
 - create mvn job to deploy

### [Closure Stylesheets][3]

 - Create jenkins job called closure-stylesheets
 - create mvn job to run ant mvn-install
 - use mvn deploy:deploy-file to deploy artifact

### [Closure Compiler][4]

 - create jenkins job called closure-compiler
 - create mvn clean package deploy -Durl job

## Conclusion

There should now be 4 jobs on your jenkins box that succesfully build.


[1]:https://github.com/google/closure-library
[2]:https://github.com/google/closure-templates
[3]:https://github.com/google/closure-stylesheets
[4]:https://github.com/google/closure-compiler