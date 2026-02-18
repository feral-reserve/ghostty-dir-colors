# ghostty-dir-colors.zsh
# Auto-colors ghostty tabs based on working directory.
# Each unique project dir gets a consistent, distinct dark background.
# Source from .zshrc:
#   source /path/to/ghostty-dir-colors.zsh

# How many path components to use as the "project key"
# e.g. 3 means ~/dev/myproject → uses "dev/myproject" as the key
# ~ itself gets a default color
_dir_color_depth=3

# Saturation and lightness constraints to keep colors dark but distinct
# Adjust these if colors are too subtle or too loud
_dir_color_sat=40    # 0-100 (color intensity)
_dir_color_lit=12    # 0-100 (keep low for dark backgrounds)

_dir_color_default="#0e0e0e"

_hash_to_hue() {
  # Deterministic hash of a string → hue 0-359
  local hash=$(printf '%s' "$1" | md5 -q 2>/dev/null || printf '%s' "$1" | md5sum | cut -d' ' -f1)
  printf '%d' "0x${hash:0:4}"
}

_hsl_to_hex() {
  # Convert HSL to hex RGB (integer math, good enough for backgrounds)
  local h=$1 s=$2 l=$3

  # Scale to 0-255 range math
  local s256=$(( s * 255 / 100 ))
  local l256=$(( l * 255 / 100 ))

  # Chroma, X, m
  local c=$(( (255 - (2 * l256 - 255 < 0 ? 255 - 2 * l256 : 2 * l256 - 255)) * s256 / 255 ))
  local h60=$(( h / 60 ))
  local h_rem=$(( (h % 60) * 255 / 60 ))
  local x=$(( c * (255 - (h_rem * 2 - 255 < 0 ? 255 - h_rem * 2 : h_rem * 2 - 255)) / 255 ))
  local m=$(( l256 - c / 2 ))

  local r g b
  case $h60 in
    0) r=$(( c + m )); g=$(( x + m )); b=$m ;;
    1) r=$(( x + m )); g=$(( c + m )); b=$m ;;
    2) r=$m; g=$(( c + m )); b=$(( x + m )) ;;
    3) r=$m; g=$(( x + m )); b=$(( c + m )) ;;
    4) r=$(( x + m )); g=$m; b=$(( c + m )) ;;
    *) r=$(( c + m )); g=$m; b=$(( x + m )) ;;
  esac

  # Clamp
  (( r < 0 )) && r=0; (( r > 255 )) && r=255
  (( g < 0 )) && g=0; (( g > 255 )) && g=255
  (( b < 0 )) && b=0; (( b > 255 )) && b=255

  printf '#%02x%02x%02x' "$r" "$g" "$b"
}

_ghostty_dir_color() {
  [[ "$TERM_PROGRAM" == "ghostty" ]] || return

  local dir="$PWD"

  # Use home as default
  if [[ "$dir" == "$HOME" || "$dir" == "$HOME/" ]]; then
    printf "\e]11;%s\e\\" "$_dir_color_default"
    return
  fi

  # Strip home prefix, take first N components as project key
  local rel="${dir#$HOME/}"
  local key=$(echo "$rel" | cut -d'/' -f1-$(( _dir_color_depth - 1 )))

  local raw_hue=$(_hash_to_hue "$key")
  local hue=$(( raw_hue % 360 ))
  local color=$(_hsl_to_hex $hue $_dir_color_sat $_dir_color_lit)

  printf "\e]11;%s\e\\" "$color"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _ghostty_dir_color

# Run on shell init
_ghostty_dir_color
