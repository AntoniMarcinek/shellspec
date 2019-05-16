#shellcheck shell=sh disable=SC2004

: "${specfile_count:-} ${example_count:-}"

# shellcheck source=lib/libexec.sh
. "${SHELLSPEC_LIB:-./lib}/libexec.sh"
use constants

formatter() {
  formatters=$1
  eval "${1}_begin() { :; }; ${1}_format() { :; }; ${1}_end() { :; }; ${1}_output() { :; };"
}

load_formatters() {
  for f in "$@"; do
    formatters="$formatters $f"
    eval "${f}_begin() { :; }; ${f}_format() { :; }; ${f}_end() { :; }; ${f}_output() { :; };"
    import "${f}_formatter"
    "${f}_formatter"
  done
}

invoke_formatters() {
  for f in $formatters; do
    #shellcheck shell=sh disable=SC2145
    "${f}_$@"
  done
}

output() {
  eval "shift; while [ \$# -gt 0 ]; do \"\$1_output\" \"$1\"; shift; done"
}

count() {
  specfile_count=0 example_count=0
  #shellcheck shell=sh disable=SC2046
  set -- $($SHELLSPEC_SHELL "$SHELLSPEC_LIBEXEC/shellspec-list.sh" "$@")
  specfile_count=$1 example_count=$2
}

# $1: prefix, $2: filename
read_time_log() {
  [ -r "$2" ] || return 0
  # shellcheck disable=SC2034
  while read -r time_log_name time_log_value; do
    case $time_log_name in (real|user|sys) ;; (*) continue; esac
    case $time_log_value in (*[!0-9.]*) continue; esac
    eval "$1_${time_log_name}=\"\$time_log_value\""
  done < "$2"
}

buffer() {
  eval "
    $1_buffer=''
    $1() {
      case \${1:-} in
        ''   ) [ \"\$$1_buffer\" ] ;;
        '='  ) shift; $1_buffer=\${*:-} ;;
        '||=') shift; $1 || $1 += \"\$@\" ;;
        '+=' ) shift; $1_buffer=\$$1_buffer\${*:-} ;;
        '>>' ) shift; puts \"\$$1_buffer\" ;;
      esac
    }
  "
}

field_description() {
  description=${field_description:-}
  replace description "$VT" " "
  putsn "$description"
}
