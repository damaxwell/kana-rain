# Install Kana Rain into another folder, e.g. a static-site repo.
#
#   make install DEST=../my-site/kana-rain
#
# Or put `DEST = ../my-site/kana-rain` in local.mk (git-ignored) and run `make install`.

-include local.mk

# Expand a leading ~ (make and zsh's DEST=~/... leave it literal).
D := $(patsubst ~%,$(HOME)%,$(DEST))

FILES = index.html sw.js manifest.webmanifest \
        icons/icon-192.png icons/icon-512.png icons/maskable-512.png icons/apple-touch-icon.png

.PHONY: install check
install: check
	@mkdir -p "$(D)/icons"
	@for f in $(FILES); do cp "$$f" "$(D)/$$f"; done
	@echo "Installed $$(grep -o 'kana-rain-v[0-9]*' sw.js) to $(D)"

# Refuse to install changed files under an unchanged service-worker VERSION,
# since installed phones would keep serving the old copy.
check:
	@test -n "$(D)" || { echo "Set DEST, e.g. make install DEST=../my-site/kana-rain"; exit 1; }
	@if [ -f "$(D)/sw.js" ]; then \
	  old=$$(grep -o 'kana-rain-v[0-9]*' "$(D)/sw.js"); new=$$(grep -o 'kana-rain-v[0-9]*' sw.js); \
	  changed=0; for f in $(FILES); do cmp -s "$$f" "$(D)/$$f" || changed=1; done; \
	  if [ $$changed = 1 ] && [ "$$old" = "$$new" ]; then \
	    echo "Files changed but VERSION in sw.js is still $$new. Bump it first."; exit 1; fi; \
	fi
