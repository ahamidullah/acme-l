_w()
{
	9p write acme/"$1"/"$2"
}

_r()
{
	9p read acme/"$1"/"$2"
}

set_dot()
{
	echo -n "$2" | _w "$1" addr
	echo -n addr=dot | _w "1" ctl
}

make_win()
{
	newwinid=$(_r new ctl | awk '{print $1}')
	echo "name $1" | _w "$newwinid" ctl
	echo -n get | _w "$newwinid" ctl
	return "$newwinid"
}

get_path_from_tag()
{
	path=$(echo "$1" | awk '{print $1}')
	echo "$path"
	return
}

find_win_and_set_dot()
{
	dir=$(pwd)
	goal_path="${dir}/$1"
	winids=$(9p ls acme | awk '/^[0-9]+$/ {print $1}')
	while IFS='\n' read -ra win_files; do
		for i in "${win_files[@]}"; do
			tag=$(_r "$i" tag)
			win_path=$(get_path_from_tag "$tag")
			if [ "$win_path" = "$goal_path" ]; then
				set_dot "$i" "$2"
				return
			fi
		done
	done <<< "$winids"
	newwinid=$(make_win "full_path")
	setdot "$newwinid" "$2"
}

update_dot()
{
	_r $winid body | awk '/^#0 / {for(i=1;i<=NF;i++){if($i~/[0-9a-zA-Z]+\.[0-9a-zA-Z]+:[0-9]+$/){split($i, a, ":")}}} END{print a[1]; print a[2]}' | find_win_and_set_dot
}



