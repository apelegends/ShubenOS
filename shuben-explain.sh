# shubenOS SmartShell: after a command fails, show WHY it failed and HOW to fix it.
# Loaded by every interactive bash shell. Works from the exit code + the command you typed.
case $- in *i*) ;; *) return 0 2>/dev/null ;; esac
[ -n "${__SB_LOADED:-}" ] && return 0
__SB_LOADED=1

__sb_show() {
  local why=$1; shift
  local b=$'\e[1;31m' y=$'\e[33m' g=$'\e[32m' d=$'\e[90m' r=$'\e[0m' i=1 f
  printf '\n%s╭─ shubenOS SmartShell ─ command failed%s\n' "$b" "$r"
  printf '%s│%s %sWhy:%s %s\n' "$d" "$r" "$y" "$r" "$why"
  printf '%s│%s %sHow to fix:%s\n' "$d" "$r" "$g" "$r"
  for f in "$@"; do printf '%s│%s   %d. %s\n' "$d" "$r" "$i" "$f"; i=$((i+1)); done
  printf '%s╰──────────────────────────────────────%s\n\n' "$d" "$r"
}

__sb_explain() {
  local code=$1 line=$2 w cmd arg1 sudo=0 root=0 i=0
  read -ra w <<<"$line"
  [ "${w[0]:-}" = sudo ] && sudo=1
  [ "$(id -u)" -eq 0 ] && root=1
  while [ "${w[i]:-}" = sudo ] || [ "${w[i]:-}" = env ] || [[ "${w[i]:-}" == *=* ]]; do i=$((i+1)); done
  cmd=${w[i]:-}; cmd=${cmd##*/}; arg1=${w[i+1]:-}

  case $code in
    130|141) return ;;   # Ctrl+C / closed pipe: normal, nothing to explain
    127)
      __sb_show "\"$cmd\" isn't installed, or you mistyped it." \
        "Check the spelling (Tab completes names)." \
        "Search for it: apt search $cmd" \
        "Install it: sudo apt install <package-name>" \
        "If you just installed it, open a new terminal so PATH refreshes."
      return ;;
    126)
      __sb_show "\"$cmd\" exists but can't be run (not executable, or it's a folder)." \
        "Make it executable: chmod +x $cmd" \
        "Check what it is: ls -l $cmd && file $cmd" \
        "Try with sudo if it needs higher permissions."
      return ;;
    124) __sb_show "The command hit its time limit." "Run it again or give it a longer timeout." "Check your network if it talks to a server."; return ;;
    137) __sb_show "The process was force-killed (SIGKILL), usually because the PC ran out of memory." \
        "Check memory: free -h" "Close heavy apps (htop shows who uses RAM)." "See kernel messages: sudo dmesg | tail -20"; return ;;
    139) __sb_show "The program crashed (segmentation fault): a bug or a broken install." \
        "Update it: sudo apt update && sudo apt upgrade" "Reinstall it: sudo apt install --reinstall <package>" "Try running it with --help to check your options."; return ;;
    134) __sb_show "The program aborted itself (SIGABRT), usually after detecting an internal error." "Read the message printed above." "Update or reinstall the package."; return ;;
    143) return ;;
  esac

  case $cmd in
    apt|apt-get|aptitude|dpkg|add-apt-repository)
      if [ $root -eq 0 ] && [ $sudo -eq 0 ]; then
        __sb_show "Installing or changing packages needs administrator rights." "Run it again with sudo: sudo $line"
      else
        __sb_show "The package manager hit a problem (bad package name, no network, or a lock)." \
          "Refresh the lists: sudo apt update" "Check the name: apt search <word>" \
          "Check the internet: ping -c1 deb.debian.org" \
          "If it says 'could not get lock': wait for the other update to finish, then: sudo dpkg --configure -a"
      fi; return ;;
    cd)
      __sb_show "That folder doesn't exist, isn't a folder, or you aren't allowed in." \
        "Look around: ls" "Names are case-sensitive; use Tab to complete." "Put quotes around names with spaces: cd \"My Folder\""; return ;;
    ls|cat|cp|mv|rm|mkdir|touch|rmdir|head|tail|less|nano|chmod|chown|ln)
      __sb_show "A file or folder is missing, already exists, or you lack permission." \
        "Check the path: ls -la $(dirname "${arg1:-.}" 2>/dev/null)" \
        "Quote names with spaces: \"like this\"" \
        "For system files add sudo: sudo $line"; return ;;
    systemctl|service)
      __sb_show "The service name is wrong, or the action needs administrator rights." \
        "Use sudo: sudo $line" "List services: systemctl list-units --type=service" "See why it failed: journalctl -xeu <service>"; return ;;
    mount|umount)
      __sb_show "Mount failed: needs root, wrong device/filesystem, or the device is busy." \
        "Use sudo: sudo $line" "See devices: lsblk -f" "NTFS drives need ntfs-3g (included): sudo mount -t ntfs-3g /dev/sdXN /mnt" "Busy? Close files on it, then: sudo umount <path>"; return ;;
    git)
      __sb_show "Git couldn't do that here (not a repo, no access, or a merge conflict)." \
        "Are you in the repo folder? git status" "No repo yet? git init" "Access denied: check the URL and your login."; return ;;
    ping)
      __sb_show "No reply: no internet, a wrong address, or DNS isn't working." \
        "Wi-Fi/network state: nmcli device status" "Try a raw IP: ping -c3 1.1.1.1  (works = DNS problem)" "Reconnect: nmcli radio wifi off && nmcli radio wifi on"; return ;;
    curl|wget)
      __sb_show "The download failed (no network, bad address, or the server refused)." \
        "Check connection: ping -c3 1.1.1.1" "Check the URL for typos." "Certificate errors: check your clock with: date"; return ;;
    ssh|scp)
      __sb_show "SSH couldn't connect or log in." "Check host/user: ssh user@host" "Is the server up? ping host" "Permission denied: wrong password or key."; return ;;
    python|python3|node|perl|ruby)
      __sb_show "Your script raised an error. The real reason is in the message above." \
        "Read the last lines of the traceback above, they name the file and line." "Missing module? sudo apt install python3-<name>"; return ;;
    make|gcc|g++|cc|cmake)
      __sb_show "The build stopped on an error." \
        "Find the first line containing 'error:' above; later errors are often side-effects." \
        "Missing tools or headers: sudo apt install build-essential" "Missing library: sudo apt install lib<name>-dev"; return ;;
  esac

  case $code in
    2) __sb_show "\"$cmd\" was used wrongly (bad option or arguments), or the shell couldn't parse the line." \
         "See its options: $cmd --help" "Open the manual: man $cmd" "Check quotes and brackets are closed."; ;;
    1) __sb_show "\"$cmd\" reported a general error. Its message is just above." \
         "Read the line above; it usually says what it didn't like." "See usage: $cmd --help" "Try sudo if it touches system settings."; ;;
    *) __sb_show "\"$cmd\" stopped with exit code $code." "Read the message above." "See usage: $cmd --help" "Search the exact message online for details."; ;;
  esac
}

__sb_at_prompt=1
__sb_ran=
__sb_debug() {
  case $BASH_COMMAND in __sb_prompt*) return ;; esac
  if [ -n "$__sb_at_prompt" ]; then __sb_at_prompt=; __sb_ran=1; fi
}
__sb_prompt() {
  local code=$?
  if [ -n "$__sb_ran" ] && [ "$code" -ne 0 ]; then
    local line
    line=$(HISTTIMEFORMAT= builtin history 1 | sed -E 's/^ *[0-9]+\*? +//')
    __sb_explain "$code" "$line"
  fi
  __sb_ran=
  __sb_at_prompt=1
}
trap '__sb_debug' DEBUG
PROMPT_COMMAND="__sb_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
