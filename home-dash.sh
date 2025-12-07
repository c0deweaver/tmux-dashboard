#!/usr/bin/env bash
#window=$1
export thisBin="$(realpath $0 )"
export whereAmI="$(dirname "$thisBin")"
export bin_dir="$(echo $PATH | sed -e "s/\:/\n/g" | grep -e '^/usr.*/bin$' | head -n1 )"
export hostsConfig="$whereAmI/hosts"
printf "$thisBin\n$whereAmI\n$bin_dir\n$hostConfig\n"
if [ -f "$hostsConfig" ]; then \
  echo "Setting hostconfig: $hostsConfig"
  export hosts=$(cat $hostsConfig | sort -k3 -t: )
else
  echo 'failed to find hostConfig'
  exit 1
fi
pane=0
dash=0
window=$(tmux display-message -p '#I')
tmux rename-session dash
echo 'create windows'
echo "$hosts" | while read i in; do \
 enablePane=$(echo $i | cut -f1 -d: )
 enableWin=$(echo $i | cut -f2 -d: )
 enableExt=$(echo $i | cut -f3 -d: )
 name=$(echo $i | cut -f4 -d: )
 host=$(echo $i | cut -f5 -d: )
 echo -e "\tName\t $name\n\tEnabled\t$enableWin\n\tHost\t$host"
 if [ "$enableWin" == "1" ]; then \
  tmux new-window; tmux rename-window "$name"
  tmux send-keys -t "$name" "while :; do ssh "$host"; ssh shawn@"$host"; read -t 120 -p \"Last Attempt:    \$(date)\"; done" Enter
  window=$((window+1))
 fi
done
tmux rename-window -t 0 "Dash"
tmux select-window -t "Dash"
tmux split-pane -t Dash.0
pane=$((pane+1))
echo "$hosts"| while read i; do \
  tmux split-pane -t Dash.$pane
  tmux select-layout -t Dash even-vertical
  tmux resize-pane -t Dash.$pane -y 1
  enablePane=$(echo $i | cut -f1 -d: )
  enableWin=$(echo $i | cut -f2 -d: )
  enableExt=$(echo $i | cut -f3 -d: )
  name=$(echo $i | cut -f4 -d: )
  host=$(echo $i | cut -f5 -d: )
  echo -e "\tName\t $name\n\tEnabled\t$enableWin\n\tHost\t$host"
 if [ "$enablePane" == "1" ]; then
  tmux send-keys -t Dash.$pane "mkdir -p ~/snap/htop/current/.config/htop/ ~/.config/htop/"
  tmux send-keys -t Dash.$pane "ssh -o 'StrictHostKeyCHecking=no'curl $host -t 'https://files.srweaver.com/htoprc > ~/snap/htop/current/.config/htop/htoprc'" Enter
  tmux send-keys -t Dash.$pane "ssh -o 'StrictHostKeyCHecking=no'curl $host -t 'https://files.srweaver.com/htoprc > ~/.config/htop/htoprc'" Enter
  tmux send-keys -t Dash.$pane "while :; do ssh -o 'StrictHostKeyCHecking=no' $host -t htop; ssh -o 'StrictHostKeyCHecking=no' $host -t /snap/bin/htop; read -t 300 -p '' ; done" Enter
  pane=$(($pane+1))
 fi
done
tmux kill-pane -t "Dash.$(tmux list-pane | tail -n1 | cut -f1 -d\:)"
tmux select-pane -t "Dash.$(tmux list-pane | tail -n1 | cut -f1 -d\:)"
sleep 2
if [ -f $whereAmI/launch ]; then \
  echo '[START] Launching $whereAmI/launch'
  bash $whereAmI/launch
  echo '[DONE] Launch of $whereAmI/lauch'
fi

hostCount=$(echo "$hosts" |cut -f1 -d\:|grep -e'1'|wc -l )
maxPane=$(($hostCount+1))
tmux select-pane -t "Dash.$maxPane"

tmux select-window -t Dash
tmux select-pane -t "Dash.$(tmux list-pane | tail -n1 | cut -f1 -d\:)"

paneConfig="$whereAmI/panes"
interval=5
wait
while :; do \
    for i in $(cat $paneConfig | grep -ve "^#" ); do \
        windowName=$(echo $i | cut -f1 -d, )
	windowNum=$(tmux list-windows | grep -i " $windowName#" | cut -f1 -d:)
        paneNum=$(echo $i | cut -f2 -d, )
        paneHeight=$(echo $i | cut -f3 -d, )
        tmux resize-pane -t $windowNum.$paneNum -y $paneHeight
    done
 sleep $interval
 done
