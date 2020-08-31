A simple dashboard in tmux to see CPU+Mem usage from multiple boxes from 1

Pre-reqs:
	tmux
	htop
	sshd setup on clients
	ssh key based authentication for aforementioned clients
	
	
Install:
	git clone https://github.com/c0deweaver/tmux-dashboard.git
	cd tmux-dashboard
	sudo cp dashboard /usr/local/bin
	export $PATH=$PATH:/usr/local/bin


Configure:
	Add hostnames/ips to ~.dashboard with each node as its own line.
	dashboard push-htop-config #This will itterate through each node setting the htoprc file.
	if you don't have ssh-keys shared you will have to enter the password for each node.
	
Arguments:
	help (needs updated, I know)
	start (creates the tmux-panes and ssh->htop)
	kill (Make it go away)
	fix (to reset the sizing)
	restart (dashboard kill && dashboard start)
	push-htop-config (makes setup easy of htop on each node)
