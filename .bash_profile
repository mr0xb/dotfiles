export GOPATH=$HOME/go_projects
alias fp='stat --format "%a"'
gsay() { if [[ "${1}" =~ -[a-z]{2} ]]; then local lang=${1#-}; local text="${*#$1}"; else local lang=${LANG%_*}; local text="$*";fi; mplayer "http://translate.google.com/translate_tts?ie=UTF-8&tl=${lang}&q=${text}" &> /dev/null ; }
function google {
	xdg-open "https://www.google.com/search?q=`urlencode "${(j: :)@}"`"
}
# https://stackoverflow.com/questions/6250698/how-to-decode-url-encoded-string-in-shell
# Encode with URLEncode

function urlencode {
	python -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.stdin.read()))"
}

# Decode URLencoded string
function urldecode {
	python -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()), end='')"
}
#public c ip
function myip {
  local api
  case "$1" in
      "-4")
            api="http://v4.ipv6-test.com/api/myip.php"
          ;;
      "-6")
            api="http://v6.ipv6-test.com/api/myip.php"
          ;;
      *)
            api="http://ipv6-test.com/api/myip.php"
          ;;
    esac
  curl -s "$api"
  echo # Newline.
}

alias such=git
alias very=git
alias wow='git status' 
alias hogs="ps aux | sort -nk +4 | tail -n 20"
alias perms="stat -c '%A %a %n'"
