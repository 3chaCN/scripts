#!/bin/bash

# usage : iptables-config.sh <interface>
# todo : services to enable/disable, check if iptables installed...

###############
# Edit mode
# Choose default policy (ACCEPT, DROP)

# Create new rule :
# 	
# [x] chain (INPUT, OUTPUT)
# [x] interface(s) - (source ip) and/or (destination ip)
# [x] tcp/udp + ports
# [x] options (conntrack)
# [x] ACCEPT/DROP...
# 
# List/modify rules
# Set default policy
# Nat
# New chains

exe=$(which iptables)

declare -a menu=("Add" "Delete" "Policy" "List" "Exit")
declare -a dev=($(ls /sys/class/net) no)
declare -a chains=("INPUT" "OUTPUT" "FORWARD" "PREROUTING" "POSTROUTING")
declare -a protos=("tcp" "udp")
declare -a tcp_ports_lbl=("FTP" "SSH" "Telnet" "SMTP" "DNS" "HTTP" "HTTPS")
declare -a tcp_ports=("21" "22" "23" "25" "53" "80" "443")
declare -a udp_ports_lbl=("DNS" "DHCP(Server)" "DHCP(Client)" "Custom")
declare -a udp_ports=("53" "67" "68")
declare -a action=("ACCEPT" "FORWARD" "DROP" "MASQUERADE")

is_root() {
	if [[ "$UID" != "0" ]]; then
		echo "You must be root to run this tool."
		exit
	fi
}

# $1 : list values
choose() 
{
	declare ch=("${@}")
	select o in "${ch[@]}";
	do
		val=$REPLY
		break
	done
	echo -nE "${o}"
}

# multiple choices
m_choose() 
{
	declare -a mch=("${@}")
	select o in "${mch[@]}";
	do
		echo $REPLY 
		break
	done
}

yesno()
{
	read -r -p "${1} [y/n] " yn 
	echo -nE $yn
}

banner() 
{
	clear
	printf "Iptables configuration script\n"
	printf "=============================\n"
}

main_menu() 
{
	cmdline=$exe
	banner
	printf "Main menu\n"
	printf "Rules\n"
	printf "\n"
	
	c=($(choose "${menu[@]}"))

	case "${c}" in
		"Add") add_rule_chain;;
		"Delete") delete_rule;;
		"List") list_rules;;
		"Exit") exit;;
		*) echo -n "unknown choice";;
	esac

}

add_rule_chain()
{
 	banner
	printf "Adding rule\n"
	printf "\n"
	printf "Which chain ?\n"
	c=($(choose "${chains[@]}"))
	cmdline="${cmdline} -A ${c}"
	add_rule_proto
}

add_rule_proto()
{
	local src
	local dst
	local iface
 	banner
	
	echo "cmdline : ${cmdline}"
	
	printf "Adding rule\n"
	printf "\n"
	printf "Protocol ?\n"
	
	c=$(choose "${protos[@]}")
	cmdline="${cmdline} -p ${c}"

	if [[ "${cmdline}" =~ "INPUT" || "${cmdline}" =~ "FORWARD" ]]; then
		printf "Add input interface ?\n"
		c=$(choose "${dev[@]}")
		cmdline="${cmdline} -i ${c}"
	elif [[ "${cmdline}" =~ "OUTPUT" || "${cmdline}" =~ "FORWARD" ]]; then
		printf "Add output interface ?\n"
		c=$(choose "${dev[@]}")
		cmdline="${cmdline} -o ${c}"
	else 
		break
	fi
	
	printf "Add source [negate with '!'] (IP/n) ? "
	read src
	if [[ "$src" != "n" ]]; then cmdline="${cmdline} -s ${src}"; fi
	
	printf "Add destination [negate with '!'] (IP/n) ? "
	read dst
	if [[ "$dst" != "n" ]]; then cmdline="${cmdline} -s ${dst}"; fi
	
	add_rule_ports
}

add_rule_ports() {
	local p
	banner
	echo "cmdline : ${cmdline}"
	printf "Adding port(s)\n"
	printf "\n"
	
	if [[ "${cmdline}" =~ "tcp" ]]; then
		c=$(m_choose "${tcp_ports_lbl[@]}")
#	elif [[ "${cmdline}" =~ "udp" ]]; then
	else
		c=$(m_choose "${udp_ports_lbl[@]}")
	fi

	if [[ "${c}" =~ " " ]]; then
	# if multiple ports specified
		cmdline="${cmdline} -m multiport --dports"
		for v in ${c}
		do
			p+="${tcp_ports[$(($v-1))]},"
		done

		p=${p:0:-1}
		cmdline="${cmdline} ${p}"
	else
		echo ${c}
		read
		cmdline="${cmdline} --dport ${tcp_ports[$(($c-1))]}"
	fi
	add_rule_action	
}

add_rule_action() {
	banner
	echo "cmdline : ${cmdline}"
	printf "Action to do\n"
	printf "\n"
	

	c=$(choose "${action[@]}")
	cmdline="${cmdline} -j ${c}"
		
	c=$(yesno "Add this rule ? ")

	if [[ $c == "y" ]]; then 
		exec_cmd 
	else
		main_menu
	fi

}

get_rules_list() {
	declare -a rules_list

	for r in $(iptables -S)
	do
		rules_list+=("${r}")
	done
	
	rule=$(m_choose "${rules_list[@]}")
	echo -nE $rule
}

delete_rule() {
	c=$(get_rules_list)
	
	for v in "${c}"
	do
		#
	done
}

list_rules() {
	$exe -L -n -v
	read -s -r -p "Press any key to return to menu"
	main_menu
}

exec_cmd() {
	$cmdline
	echo "Rule added."
	c=$(yesno "Add another rule ? ")
	
	if [[ $c == "y" ]]; then
		main_menu
	else
		echo "Bye."
	fi
}

is_root
main_menu

