#!/bin/bash
fr () {
	FIND="$1"
	REPLACE="$2"
	FILTER="$3"
	if [ -z "${FIND}" ] || [ -z "${REPLACE}" ]
	then
		echo "ERR: must include two parameters for find and replace" >&2
		fr_usage
		return 1
	fi
	if command -v rg 2>&1 > /dev/null
	then
		if [ -z "${FILTER}" ]
		then
			rg --hidden --glob '!.git/' -l "$FIND" | xargs sed -i "s/${FIND}/${REPLACE}/g"
		else
			rg --hidden --glob '!.git/' -l "$FIND" | rg --hidden --glob '!.git/' -i "$FILTER" | xargs sed -i "s/${FIND}/${REPLACE}/g"
		fi
	else
		if [ -z "${FILTER}" ]
		then
			grep --color -l "$FIND" | xargs sed -i "s/${FIND}/${REPLACE}/g"
		else
			grep --color -l "$FIND" | grep --color -i "$FILTER" | xargs sed -i "s/${FIND}/${REPLACE}/g"
		fi
	fi
}
