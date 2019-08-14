#shellcheck shell=sh disable=SC2016

shellspec_get_nth() {
  shellspec_reset_params '"$1" "$2" $4' "$3"
  eval "$SHELLSPEC_RESET_PARAMS"
  eval "$1=\${$(($2 + 2)):-}"
}

shellspec_is() {
  case $1 in
    number) case ${2:-} in ( '' | *[!0-9]* ) return 1; esac ;;
    funcname)
      case ${2:-} in ([a-zA-Z_]*) ;; (*) return 1; esac
      case ${2:-} in (*[!a-zA-Z0-9_]*) return 1; esac ;;
    *) shellspec_error "shellspec_is: invalid type name '$1'"
  esac
  return 0
}

shellspec_capture() {
  SHELLSPEC_EVAL="
    if $1=\"\$($2 && echo _)\"; then $1=\${$1%_}; else unset $1 ||:; fi
  "
  eval "$SHELLSPEC_EVAL"
}

shellspec_shell_option() {
  eval "set -- ${*:-}"
  while [ $# -gt 0 ]; do
    case $1 in
      *:on) shellspec_shell_option_on "${1%:*}" ;;
      *:off) shellspec_shell_option_off "${1%:*}" ;;
      *) shellspec_error "shellspec_shell_option: invalid option '$1'"
    esac
    shift
  done
}

shellspec_shell_option_set_on() {
  set -o "$1"
}
shellspec_shell_option_set_off() {
  set +o "$1"
}
shellspec_proxy shellspec_shell_option_on shellspec_shell_option_set_on
shellspec_proxy shellspec_shell_option_off shellspec_shell_option_set_off

if [ "${BASH_VERSION:-}" ]; then
  shellspec_shell_option_on() {
    #shellcheck disable=SC2039
    shopt -s "$1" 2>/dev/null || shellspec_shell_option_set_on "$1"
  }
  shellspec_shell_option_off() {
    #shellcheck disable=SC2039
    shopt -u "$1" 2>/dev/null || shellspec_shell_option_set_off "$1"
  }
fi
