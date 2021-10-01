#!/bin/bash

declare -a monsters
declare -a map_sur
readarray -t map_sur < <(find "$PWD" -maxdepth 1 -type d)
temp_sur=$(cd .. && echo "$PWD")
map_sur[0]="$temp_sur"
begin=$PWD
previous=$PWD
cmd=""
loc_sur=0
cmd_bit=0
bigc=""
sc_x=$(tput cols)
sc_y=$(tput lines)
sc_help=${#"<H>elp"}
sc_dir=${#PWD}
health_points=100
energy_points=100
steps_taken=0
points=0
tput reset
stty -echo

# Monsters
m=0
m_loc=$PWD
m_hp=0
m_energy=0
monsters[m]="$m,$m_loc,$m_hp,$m_energy"

tput sc
sc_dir=${#PWD}
tput cup 3 $((sc_x/3)) && echo "$message"
tput cup 1 $((sc_x/3)) && echo "You are now at $PWD"
tput cup 2 $((sc_x/3)) && echo "You are looking at ${map_sur[loc_sur]}"
tput cup 0 $((sc_x-7)) && echo "<H>elp"
message=""
st_len=${#steps_taken}
tput cup $(tput lines) 1 && echo "Health: $health_points    Energy: $energy_points    Steps Taken: $steps_taken    Points: $points"
#tput cup $(tput lines) 2 && echo "Health: $health_points"
#tput cup $((sc_y-1)) 20 && echo "Energy: $energy_points"
tput cup $(tput lines) 1

while [ "$cmd" != "q" ]
do
	sc_y=$(tput lines)
	sc_x=$(tput cols)
	if [ $cmd_bit -eq 0 ]; then
		read -n1 cmd
	else
		read cmd
	fi

	case "$cmd" in
		w|'forward'|f)

			if [ "${map_sur[loc_sur]}" != "/root" ] && [ "${map_sur[loc_sur]}" != "/proc" ]; then
				if [ $loc_sur -gt 0 ] && [ "$map_sur[loc_sur]}" != "//" ]; then
					previous="$PWD"
					cd "${map_sur[loc_sur]}"
					map_sur=()
					readarray -t map_sur < <(find "$PWD" -maxdepth 1 -type d 2>&1 | grep -v "Permission denied" | sort -fi)
					temp_sur=$(cd .. && echo $PWD)
					map_sur[0]="$temp_sur"
					loc_sur=${#map_sur[*]}
					loc_sur=$((loc_sur/2))
					message="Foreward"
				elif [ "${map_sur[loc_sur]}" == "//" ]; then
					message="You plumet to your death."
					cmd='q'
				else
					previous="$PWD"
					cd ..
					map_sur=()
					readarray -t map_sur < <(find "$PWD" -maxdepth 1 -type d 2>&1 | grep -v "Permission denied | sort -fi")
					temp_sur=$(cd .. && echo $PWD)
					map_sur[0]="$temp_sur"
					loc_sur=${#map_sur[*]}
					loc_sur=$((loc_sur/2))
					message="Foreward"
				fi
			else
				message="Stop trying to walk into the wall."
			fi
			if [ $RANDOM -gt 1 ]; then
				seed=$(ls -a | wc -l)
				m=$(( m + 1 ))
				m_loc=$PWD
				m_hp=$(($RANDOM%seed + 1 ))
				#m_hp=$(( m_hp - seed ))
				m_energy=0
				monsters[m]="$m,$m_loc,$m_hp,$m_energy"
			fi
mon_msg="rawr"

			steps_taken=$((steps_taken+2))
			;;
		a|l|'left')
			if [ $loc_sur -gt 0 ] && [ $loc_sur -lt ${#map_sur[*]} ]; then
				message="Turned Right"
				loc_sur=$((loc_sur-1))
			elif [ $loc_sur -eq ${#map_sur[*]} ]; then
				temp_sur=${#map_sur[*]}
				loc_sur=$((temp_sur-1))
			else
				temp_sur=${#map_sur[*]}
				loc_sur=$((temp_sur-1))
			fi
#			echo -e "You are facing ${map_sur[loc_sur]} $loc_sur\n"
			steps_taken=$((steps_taken+1))
			;;
		s|b|'back')
			if [ "$PWD" == "/" ]; then
				message="You plumet to your death."
				cmd='q'
			elif [ "$PWD" != "/" ]; then
				cd ..
				readarray -t map_sur < <(find "$PWD" -maxdepth 1 -type d 2>&1 | grep -v "Permission denied | sort -fi")
				temp_sur=$(cd .. && echo $PWD)
				map_sur[0]="$temp_sur"
				message="Backward"
			else
				readarray -t map_sur < <(find "$PWD" -maxdepth 1 -type d 2>&1 | grep -v "Permission denied | sort -fi")
				temp_sur=$(cd .. && echo $PWD)
				map_sur[0]="$temp_sur"
				cd ..
				message="Backward"
			fi
			steps_taken=$((steps_taken+2))
			;;
		d|r|'right')
			if [ $loc_sur -lt "${#map_sur[*]}" ] && [ $((loc_sur+1)) -ne "${#map_sur[*]}" ]; then
#				echo -e "Turned Right\n"
				loc_sur=$((loc_sur+1))
			else
				loc_sur=0
			fi
#			echo -e "You are facing ${map_sur[loc_sur]} $loc_sur\n"
			steps_taken=$((steps_taken+1))
			;;
		'-')
			if [ $cmd_bit -eq 0 ]; then
				cmd_bit=1
				stty echo
			else
				cmd_bit=0
				stty -echo
			fi
			;;
                = )
				echo -e "\n"
				read bigc
				bigc="$($bigc)"
                                echo "$bigc"
                        ;;
		" " )
			tput reset
			;;
		p )
			echo "${map_sur[0]}"
			read -n1
			;;
		h|H|'help')
			echo "Commands List"
			echo -e "    w, f, forward - Enter the directory you are currently facing"
			echo -e "    s, b, back - return to the previous directory"
			echo -e "    a, l, left - rotate to face directories lower on the list"
			echo -e "    d, r, right - rotate to face directories higher on the list"
			echo -e "    - - enter long game commands"
			echo -e "    = - enter command line commands and view output <careful this"
			echo -e "        might break the game>"
			echo -e "    o - observe your location without moving"
			echo -e "    space - clear the screen"
			read -n1
			;;
		*)
			;;
	esac
#	if [ "${map[$loc]}" == "$begin" ]; then
#		echo "This is where you started"
#	fi
tput reset
tput sc
sc_dir=${#PWD}
#monster output
#monsters[m]="$m,$m_loc,$m_hp,$m_energy"
for mondets in '$(monsters[@])'; do
	lmon=$(echo "$(mondets)" | sed -F, 'BEGIN {OFS=FS} {Print $2}')

	if [ "$lmon" = "$PWD" ]; then
		tput cup $((lines/2)) $((sc_x/3)) && echo "$mon_msg"
	fi
done
#tput cup $((lines/2)) $((sc_x/3)) && echo "$mon_msg"

tput cup 3 $((sc_x/3)) && echo "$message"
tput cup 1 $((sc_x/3)) && echo "You are now at $PWD"
tput cup 2 $((sc_x/3)) && echo "You are looking at ${map_sur[loc_sur]}"
tput cup 0 $((sc_x-7)) && echo "<H>elp"
message=""
st_len=${#steps_taken}
tput cup $(tput lines) 1 && echo "Health: $health_points    Energy: $energy_points    Steps Taken: $steps_taken"
#tput cup $(tput lines) 1 && echo "Health: $health_points"
#tput cup $((sc_y-1_)) 20 && echo "Energy: $energy_points"
tput cup $(tput lines) 1
st_y=$(tput lines)
st_x=$(tput cols)
done
read -n1
tput reset
exit 0
