---
layout: post
title: Jekyll & Compass Static WebPage
published: true
---

<p class="notice">
 This website is generated using the exact method described bellow, see the source at <a href="https://github.com/StefanLiebenberg/slieb.org">https://github.com/StefanLiebenberg/slieb.org</a>
</p>

Jekyll is a static site generator used by github to produce git pages. It generates a host of plain text formats into .html files and supports multiple plugins. The static html output of this site is then easily served from apache or similiar webserver.



<p class="notice">You will require some form or ruby and rubygems installed</p>


## Creating a jekyll project

```shell
$ mkdir /path/to/project;
$ cd /path/to/project;
```

### Installing the gems


```shell
$ gem install bundler
```



**./Gemfile**

```ruby
gem 'jekyll' # the jekyll gem
gem 'jekyll-compass' # compass integration into jekyll
gem 'rouge' # a alternative markup for jekyll

# some other plugins..
gem 'jekyll-last-modified-at'
gem 'compass-blueprint'
```

```shell
$ bundle install
```


### Configuration

```yaml
source: source
destination: site
excerpt_separator: ""
highlighter: rouge
markdown_ext: "markdown,mkdown,mkdn,mkd,md"
markdown: redcarpet
permalink: /blog/:title
paginate: 5
paginate_path: "/page/:num/"
gems:
- jekyll-compass
- rouge
- jekyll-last-modified-at

redcarpet:
  extensions:
  - tables
```

### Directory Layout


| Name          | Location          | Description                  |
|---------------|-------------------|------------------------------|
| Configuration | ./_config.yml     | The configuration for jekyll |
| Gemfile       | ./Gemfile         |                              |
| Jekyll Source | ./source          |                              |
| Compass Css   | ./source/_compass |                              |


### Build Commands

```shell
# generate a new, empty skeleton jekyll project
bundle exec jekyll new .
```

```shell
# test your installation
bundle exec jekyll serve
```

### Deployment

You should now be able to host the contents of **./site** on the root of your domain.