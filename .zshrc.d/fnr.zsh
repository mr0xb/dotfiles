fnr () {
        FIND="$1"
        REPLACE="$2"
        FILTER="$3"
        if [ -z "${FIND}" ] || [ -z "${REPLACE}" ]
        then
                echo "ERR: must include two parameters for find and replace" >&2
                echo "Usage: fnr <find_string> <replace_string> [filter]" >&2
                return 1
        fi

        if command -v rg 2>&1 > /dev/null
        then
                if [ -z "${FILTER}" ]
                then
                        rg --files --hidden --glob '!.git/' | rg "${FIND}" | sort -r | while read -r file; do
                                dir=$(dirname "$file")
                                base=$(basename "$file")
                                new_base=$(echo "$base" | sed "s/${FIND}/${REPLACE}/g")
                                [ "$base" != "$new_base" ] && mv -v "$file" "$dir/$new_base"
                        done
                else
                        rg --files --hidden --glob '!.git/' | rg "${FIND}" | rg -i "$FILTER" | sort -r | while read -r file; do
                                dir=$(dirname "$file")
                                base=$(basename "$file")
                                new_base=$(echo "$base" | sed "s/${FIND}/${REPLACE}/g")
                                [ "$base" != "$new_base" ] && mv -v "$file" "$dir/$new_base"
                        done
                fi
        else
                if [ -z "${FILTER}" ]
                then
                        find . -name '.git' -prune -o -type f -print | grep "${FIND}" | sort -r | while read -r file; do
                                dir=$(dirname "$file")
                                base=$(basename "$file")
                                new_base=$(echo "$base" | sed "s/${FIND}/${REPLACE}/g")
                                [ "$base" != "$new_base" ] && mv -v "$file" "$dir/$new_base"
                        done
                else
                        find . -name '.git' -prune -o -type f -print | grep "${FIND}" | grep -i "$FILTER" | sort -r | while read -r file; do
                                dir=$(dirname "$file")
                                base=$(basename "$file")
                                new_base=$(echo "$base" | sed "s/${FIND}/${REPLACE}/g")
                                [ "$base" != "$new_base" ] && mv -v "$file" "$dir/$new_base"
                        done
                fi
        fi
}
