#!/bin/sh
# pkg-info.sh <package>
# Prints "<installed>\t<latest>" for the named package, where either field is
# empty when unknown. Used by the Updates view to decide whether to enable
# the [Upgrade] button.

PKG="$1"
case "$PKG" in
	daed|luci-app-daed) ;;
	*) echo "" ; exit 64 ;;
esac

installed=""
latest=""

if command -v apk >/dev/null 2>&1; then
	# `apk info -e <pkg>` exits 0 if installed; `apk info <pkg>` includes version
	installed=$(apk info "$PKG" 2>/dev/null | head -1 | awk '{print $1}' | sed "s/^${PKG}-//")
	# `apk search` returns the highest version known to the cached indexes
	latest=$(apk search "^${PKG}\$" 2>/dev/null | sort -V | tail -1 | sed "s/^${PKG}-//")
elif command -v opkg >/dev/null 2>&1; then
	installed=$(opkg status "$PKG" 2>/dev/null | awk -F': ' '$1=="Version"{print $2; exit}')
	latest=$(opkg info "$PKG" 2>/dev/null | awk -F': ' '$1=="Version"{print $2; exit}')
fi

printf '%s\t%s\n' "$installed" "$latest"
