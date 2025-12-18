#!/usr/bin/env bash
#Home dashboard built in tmux
function config() {
  thisBin="$(realpath $0 )"
  whereAmI="$(dirname "$thisBin")"
  bin_dir="$(echo $PATH | sed -e "s/\:/\n/g" | grep -e '^/usr.*/bin$' | head -n1 )"
  hostsConfig="$whereAmI/hosts"
  pane=0
  dash=0
  #printf "$thisBin\n$whereAmI\n$bin_dir\n$hostConfig\n"
  if [[ -f "$hostsConfig" ]]; then 
    export hosts=$(cat $hostsConfig | sort -k3 -t: )
  else
    echo 'failed to find hostConfig'
    exit 1
  fi
  if [[ ! -z dashName ]]; then
    dashName="NewDash"
  fi
  window=$(tmux display-message -p '#I')
  hostCount=$(echo "$hosts" |cut -f1 -d\:|grep -e'1'|wc -l )
  maxPane=$(($hostCount+1))
}

function windowCreator() {
  echo creating windows
  tmux rename-session "$dashName"
  if [[ -z $hosts ]]; then echo "Hosts:"; echo "$hosts";fi
  echo "$hosts" | while IFS=':' read -r enablePane enableWin enableExt name host
  do 
  if [ "$enableWin" == "1" ]; then 
    tmux new-window; tmux rename-window "$name"
    tmux send-keys -t "$name" "while :; do ssh "$host"; read -t 120 -p \"Last Attempt:    \$(date)\"; done" Enter
    window=$((window+1))
  fi
  done
  tmux rename-window -t 0 "Dash"
  tmux select-window -t "Dash"
  tmux split-pane -t Dash.0
}

function paneCreator() {
  pane=$((pane+1))
  echo "$hosts"| while read i; do 
    tmux split-pane -t Dash.$pane
    tmux select-layout -t Dash even-vertical
    tmux resize-pane -t Dash.$pane -y 1
    enablePane=$(echo $i | cut -f1 -d: )
    enableWin=$(echo $i | cut -f2 -d: )
    enableExt=$(echo $i | cut -f3 -d: )
    name=$(echo $i | cut -f4 -d: )
    host=$(echo $i | cut -f5 -d: )
    pane=$(($pane+1))
  done
  tmux kill-pane -t "Dash.$(tmux list-pane | tail -n1 | cut -f1 -d\:)"
  tmux select-pane -t "Dash.$(tmux list-pane | tail -n1 | cut -f1 -d\:)"
  sleep 2
  tmux select-pane -t"Dash$maxPane"                                                                                                                                
  tmux select-window -t Dash
  tmux select-pane -t "Dash.$(tmux list-pane | tail -n1 | cut -f1 -d\:)"
  paneConfig="$whereAmI/panes"
}

function launchScript() {
  if [ -f $whereAmI/launch ]; then \
    bash $whereAmI/launch
  fi
}

function paneManager() {
  tmux select-pane -t "Dash.$maxPane"
  tmux select-window -t Dash
  tmux select-pane -t "Dash.$(tmux list-pane | tail -n1 | cut -f1 -d\:)"
  while :; do
    grep -ve '^#' $paneConfig | while IFS=',' read -r name pane height; do 
      tmux resize-pane -t $name.$pane -y "$height"; 
    done; 
    read -t $paneManagerInterval -p "Waiting for $paneManagerInterval" ; 
  done
}

#function argParse() {
  while getopts 'i:pm:l:pc:wc' opt; do
    case "$opt" in
      i)
        arg="$OPTARG"
        paneManagerInterval="$OPTARG"
        #Change pane manager interval
        ;;
      pm)
        pane_manager=true 
        #-pm Disables pane manager  for auto resizing
        ;;
      l)
        launcher=true
        #-l Disableds the launcher script
        ;;
      pc)
        pane_creator=true
        #-pc disables the pane creator
        ;;
      wc)
        window_creator=true
        #-wc disables window creator
        ;;
      #*)
      #  echo noargs
      #  ;;
      *)
        echo "Usage: ... on my todo list... good luck."
        #exit 1
        ;;
    esac
  done
#}


#################################
# Start of excution of funtions #
#################################

unset paneManagerInterval pane_manager launcher pane_creator window_creator
#argParse
config
paneCreator
#if [[ ! -n $pane_creator ]]; then echo "running paneCreator"; paneCreator; fi
if [[ ! -n $window_creator ]]; then echo "running windowCreator"; windowCreator; fi
if [[ ! -n $launcher ]]; then echo "running launchScript"; launchScript; fi
if [[ ! -n $paneManagerInterval ]]; then echo "setting paneManagerInterval"; paneManagerInterval=5; fi 
    #if an interval is not set it defaults to 5s
    #paneManager runs in a loop so must be run last, it is interfaced with at Dash.0
if [[ ! -n $pane_manager ]]; then echo "running paneManager"; paneManager; fi




