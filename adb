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
	read -r winid line
	echo -n "$line" | _w "$winid" addr
	echo -n dot=addr | _w "$winid" ctl
	echo -n show | _w "$winid" ctl
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

get_win()
{
	read -r file line
	dir=$(pwd)
	goal_path="${dir}/$file"
	
	if [ ! -f "$goal_path" ]; then
		return 1
	fi

	winids=$(9p ls acme | awk '/^[0-9]+$/ {print $1}')
	while IFS='\n' read -ra win_files; do
		for i in "${win_files[@]}"; do
			tag=$(_r "$i" tag)
			win_path=$(get_path_from_tag "$tag")
			if [ "$win_path" = "$goal_path" ]; then
				echo "$i" "$line"
				return 0
			fi
		done
	done <<< "$winids"

	#couldn't find a win with file name
	newwinid=$(make_win "$goal_path")
	echo "$newwinid" "$line"
	return 0
}

#get the file and line number of the first stack trace frame from a file
#in the current directory
get_file_and_line()
{
	awk -v regexp="$1" '\
		$0 ~ regexp { n=1 }\
		n { for (i=1;i<=NF;i++)\
			{ if ($i ~ /[0-9a-zA-Z]+\.[0-9a-zA-Z]+:[0-9]+$/)\
				{ split($i, a, ":");\
				if (system("[ -f " a[1] " ]") == 0)\
					{ n=0 }}}}\
		END { printf("%s %s", a[1], a[2]) }'
}

update_dot()
{
	winid_and_line=$(_r "$winid" body | get_file_and_line "$1" | get_win)
	if [ $? -eq 0 ]; then
		echo "$winid_and_line" | set_dot
	fi
}

if [ "$1" = "backtrace" ]; then
	update_dot "^#0 "
fi
if [ "$1" = "frame" ]; then
	update_dot "^#[0-9]+ "
fi
