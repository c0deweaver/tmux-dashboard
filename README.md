### A simple dashboard in tmux to see CPU+Mem usage from multiple boxes from 1

#### Pre-reqs:
	- tmux
	- htop
	- sshd setup on clients
	- ssh key based authentication for aforementioned clients
		- I also recomend adding this to you .ssh/config 'Host *\n\tConnectTimeout 1' because I hate waiting for offline hosts
	
#### Install:  
	- git clone https://github.com/c0deweaver/tmux-dashboard.git
	- cd tmux-dashboard
	- home-dash.sh
		- Further runs can be started anywhere with home-dash

#### Config:
	- hosts: hosts to connect and create panes/windows for
	- panes: how to resize panes 
	- launch: run one off commands at launch like what I use to create initial layouts and send commands to those panes in the layouts

#### Hosts file:
	- Pane:Win:Order:Name:Host
	- 0/1:0/1:{1..}:PrettyName:dns/ip extra args here

#### Launch file:
  - commands to run when you launch the dashboard
	- I fill mine with ```tmux split-pane -t SomeWin.X```
	- That lets me build layouts I want each time

#### Panes file:
  - Window name/num,pane#,height