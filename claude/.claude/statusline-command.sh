#!/bin/bash
# no jq; grep -P parses single-line JSON.
input=$(cat)
get() { grep -oP "$1" <<< "$input" | head -1; }

cwd=$(get '"current_dir":"\K[^"]+')
dir=$(basename "$cwd")
branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)

# assumes used_percentage field order.
ctx=$(get '"used_percentage":\K[0-9.]+')
model=$(get '"model":\{[^}]*"display_name":"\K[^"]+')
rate5h=$(get '"five_hour":\{[^}]*"used_percentage":\K[0-9.]+')
rate7d=$(get '"seven_day":\{[^}]*"used_percentage":\K[0-9.]+')
resets5h=$(get '"five_hour":\{[^}]*"resets_at":"\K[^"]+')
resets7d=$(get '"seven_day":\{[^}]*"resets_at":"\K[^"]+')

# naive diff, DST-unsafe by seconds.
fmt_reset() {
    local target now diff d h m
    target=$(date -d "$1" +%s 2>/dev/null) || return
    now=$(date +%s)
    diff=$((target - now))
    [ "$diff" -le 0 ] && return
    d=$((diff / 86400)); h=$((diff % 86400 / 3600)); m=$((diff % 3600 / 60))
    if [ "$d" -gt 0 ]; then printf '%dd%dh%dm' "$d" "$h" "$m"
    elif [ "$h" -gt 0 ]; then printf '%dh%dm' "$h" "$m"
    else printf '%dm' "$m"; fi
}

sep=$'\033[38;5;240m \xe2\x94\x82\033[0m '

# green <50%, yellow 50-80%, red >=80%
pct_color() {
    local p=${1%.*}
    if [ "$p" -ge 80 ]; then printf 196; elif [ "$p" -ge 50 ]; then printf 220; else printf 46; fi
}

flag="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.ponytail-active"
ponytail=""
if [ -f "$flag" ]; then
    pmode=$(head -n1 "$flag" | tr -d '[:space:]')
    pcolor=108
    [ "$pmode" = "ultra" ] && pcolor=173
    if [ -z "$pmode" ] || [ "$pmode" = "full" ]; then
        ponytail=$(printf '\033[38;5;%sm[PONYTAIL]\033[0m' "$pcolor")
    else
        ponytail=$(printf '\033[38;5;%sm[PONYTAIL:%s]\033[0m' "$pcolor" "$(printf '%s' "$pmode" | tr '[:lower:]' '[:upper:]')")
    fi
fi

out=""
[ -n "$ponytail" ] && out="$ponytail$sep"
out="$out$(printf '\033[38;5;39m%s\033[0m' "$dir")"
[ -n "$branch" ] && out="$out$sep$(printf '\033[38;5;135m\xe2\x8e\x87 %s\033[0m' "$branch")"
if [ -n "$ctx" ]; then
    c=$(pct_color "$ctx")
    out="$out$sep$(printf '\033[38;5;%sm\xe2\x9a\xa1 ctx %.0f%%\033[0m' "$c" "$ctx")"
fi
[ -n "$model" ] && out="$out$sep$(printf '\033[38;5;244m%s\033[0m' "$model")"
if [ -n "$rate5h" ]; then
    c=$(pct_color "$rate5h")
    r=$(fmt_reset "$resets5h")
    [ -n "$r" ] && r=" (in $r)"
    out="$out$sep$(printf '\033[38;5;%sm5h %.0f%%%s\033[0m' "$c" "$rate5h" "$r")"
fi
if [ -n "$rate7d" ]; then
    c=$(pct_color "$rate7d")
    r=$(fmt_reset "$resets7d")
    [ -n "$r" ] && r=" (in $r)"
    out="$out$sep$(printf '\033[38;5;%sm7d %.0f%%%s\033[0m' "$c" "$rate7d" "$r")"
fi

printf '%s\n' "$out"
