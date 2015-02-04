PREVIEW_OPTIONS=--draft
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
