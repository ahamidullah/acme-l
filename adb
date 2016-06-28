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
	echo -n dot=addr | _w "$1" ctl
	echo -n show | _w "$1" ctl
}

make_win()
{
	newid=$(_r new ctl | awk '{print $1}')
	echo "name $1" | _w "$newid" ctl
	echo -n get | _w "$newid" ctl
	echo "$newid"
}

get_path_from_tag()
{
	path=$(echo "$1" | awk '{print $1}')
	echo "$path"
	return
}

get_win_and_set_dot()
{
	read -r file line
	dir=$(pwd)
	goal_path="${dir}/$file"
	if [ ! -r "$goal_path -o -d "$goal_path" ]; then return; fi
	winids=$(9p ls acme | awk '/^[0-9]+$/ {print $1}')
	while IFS='\n' read -ra win_files; do
		for i in "${win_files[@]}"; do
			tag=$(_r "$i" tag)
			win_path=$(get_path_from_tag "$tag")
			if [ "$win_path" = "$goal_path" ]; then
				set_dot "$i" "$line"
				return
			fi
		done
	done <<< "$winids"
	newwinid=$(make_win "$goal_path")
	set_dot "$newwinid" "$line"
}

update_dot()
{
	_r $winid body | awk '/^#0 / {n=1} n{for(i=1;i<=NF;i++){if($i~/[0-9a-zA-Z]+\.[0-9a-zA-Z]+:[0-9]+$/){split($i, a, ":");n=0}}} END{printf("%s %s", a[1], a[2])}' | get_win_and_set_dot
}

update_dot
