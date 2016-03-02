PREVIEW_OPTIONS=-D --future --unpublished
BUILD_OPTIONS=
INSTALL_OPTIONS=

master:
	bundle exec jekyll build $(BUILD_OPTIONS)

preview:
	bundle exec jekyll build $(PREVIEW_OPTIONS) $(BUILD_OPTIONS)

serve:
	bundle exec jekyll serve $(PREVIEW_OPTIONS) $(BUILD_OPTIONS)

install:
	bundle install $(INSTALL_OPTIONS)

release:
	git checkout master && git merge preview && git checkout preview;	

deploy:
    git push --all