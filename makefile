PREVIEW_OPTIONS=--draft
BUILD_OPTIONS=
INSTALL_OPTIONS=

master:
	jekyll build $(BUILD_OPTIONS)

preview:
	jekyll build $(PREVIEW_OPTIONS) $(BUILD_OPTIONS)

serve:
	jekyll serve $(PREVIEW_OPTIONS) $(BUILD_OPTIONS)

install:
	bundle install $(INSTALL_OPTIONS)
