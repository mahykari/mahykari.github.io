.PHONY: all clean serve

POSTS = $(patsubst %.md,%.html,$(wildcard posts/*.md))

all: index.html $(POSTS)

# For posts, we need to go up one directory to find the CSS
posts/%.html: posts/%.md style.css
	pandoc -s $< -c ../style.css -o $@

# Detect OS
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
    SED_INPLACE = sed -i ''
else
    SED_INPLACE = sed -i
endif

# For index, first update recent posts section, then convert to HTML
index.html: index.md $(wildcard posts/*.md) style.css
	@echo "Updating recent posts section..."
	@cp index.md index.tmp
	@echo "### Recent Posts\n" > recent.tmp
	@ls posts/*.md | sort -r | head -n 3 | while read post; do \
		title=`sed -n '/^title:/s/title: *//p' "$$post"`; \
		date=`sed -n '/^date:/s/date: *//p' "$$post" | sed 's/\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)/\3.\2.\1/'`; \
		html_file=`basename "$$post" .md`.html; \
		echo "- [$$title](posts/$$html_file) ($$date)" >> recent.tmp; \
	done
	@$(SED_INPLACE) -e '/<!-- RECENT_POSTS -->/r recent.tmp' -e '/<!-- RECENT_POSTS -->/d' index.tmp
	pandoc -f markdown -s index.tmp -c style.css -o $@
	@rm -f index.tmp recent.tmp

clean:
	rm -f index.html posts/*.html

serve:
	python3 -m http.server 8000
