---
layout: post
title: Parsing JavaScript with Google Closure in Java.
published: true
---

The google closure compiler includes a Parser that will parse JavaScript files into a AST and provides a visitor interface to scan the ast. This can be used to extract information from javascript files.

For example, in Google Closure goog.require and goog.provide calls are used to specify dependency relationship between files. Using the provided tools, we can extract this information in our build tool to calculate the required load order for files.


{% file examples/com/myClass.js javascript %}

If we wanted to extract all the provide and require calls. A simple regexp would not work well. Unless I make it incredibly complex, it would not understand the context of the matches it finds.

Instead, we build a visitor that will collect this information


{% file examples/DependencyVisitor.java java %}


Now we can parse the javascript file into an ast, and then visit that ast with out visitor.

```java

  import com.google.common.base.Predicates;
  import com.google.javascript.jscomp.NodeUtil;
  import com.google.javascript.jscomp.parsing.Config;
  import com.google.javascript.jscomp.parsing.ParserRunner;
  import com.google.javascript.jscomp.SourceFile;
  import com.google.javascript.rhino.ErrorReporter;
  import com.google.javascript.rhino.SimpleErrorReporter;

  import java.io.File;


  //  ...


  Config config = ParserRunner.createConfig(true, Config.LanguageMode.ECMASCRIPT6_STRICT, true, null);
  ErrorReporter errorReporter = new SimpleErrorReporter();

  // parse a source file into an ast.
  SourceFile sourceFile = SourceFile.fromFile(new File("com/MyClass.js"));
  ParserRunner.ParseResult parseResult = ParserRunner.parse(sourceFile, sourceFile.getCode(), config, errorReporter);

  // run the visitor on the ast to extract the needed values.
  DependencyVisitor visitor = new DependencyVisitor();
  NodeUtil.visitPreOrder(parseResult.ast, visitor, Predicates.<Node>alwaysTrue());

  visitor.provides; // HashSet of provide statements found in file.
  visitor.requires; // HashSet or require statements found in file.

```





