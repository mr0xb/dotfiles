# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
-- () {
	# undefined
	builtin autoload -XUz
}
-ftb-build-module () {
	# undefined
	builtin autoload -XUz
}
-ftb-colorize () {
	# undefined
	builtin autoload -XUz
}
-ftb-compadd () {
	local -A apre hpre dscrs _oad _mesg
	local -a isfile _opts __ expl
	zparseopts -a _opts P:=apre p:=hpre d:=dscrs X+:=expl O:=_oad A:=_oad D:=_oad f=isfile i: S: s: I: x:=_mesg r: R: W: F: M+: E: q e Q n U C J:=__ V:=__ a=__ l=__ k=__ o::=__ 1=__ 2=__
	_ftb_curcontext=${curcontext#:} 
	if (( $#_oad != 0 || ! IN_FZF_TAB )) || {
			-ftb-zstyle -m disabled-on "any"
		} || (
			{
				-ftb-zstyle -m disabled-on "files"
			} && [[ -n $isfile ]]
		)
	then
		builtin compadd "$@"
		return
	fi
	local -a __hits __dscr
	if (( $#dscrs == 1 ))
	then
		__dscr=("${(@P)${(v)dscrs}}") 
	fi
	builtin compadd -A __hits -D __dscr "$@"
	local ret=$? 
	if (( $#__hits == 0 ))
	then
		if is-at-least 5.9 && (( $#_mesg != 0 ))
		then
			builtin compadd -x $_mesg
		fi
		return $ret
	fi
	expl=$expl[2] 
	[[ -n $expl ]] && _ftb_groups+=$expl 
	local -a keys=(apre hpre PREFIX SUFFIX IPREFIX ISUFFIX) 
	local key expanded __tmp_value=$'<\0>' 
	for key in $keys
	do
		expanded=${(P)key} 
		if [[ -n $expanded ]]
		then
			__tmp_value+=$'\0'$key$'\0'$expanded 
		fi
	done
	if [[ -n $expl ]]
	then
		__tmp_value+=$'\0group\0'$_ftb_groups[(ie)$expl] 
	fi
	if [[ -n $isfile ]]
	then
		__tmp_value+=$'\0realdir\0'${${(Qe)~${:-$IPREFIX$hpre}}} 
	fi
	_opts+=("${(@kv)apre}" "${(@kv)hpre}" $isfile) 
	__tmp_value+=$'\0args\0'${(pj:\1:)_opts} 
	if (( $+builtins[fzf-tab-compcap-generate] ))
	then
		fzf-tab-compcap-generate __hits __dscr __tmp_value
	else
		local dscr word i
		for i in {1..$#__hits}
		do
			word=$__hits[i] dscr=$__dscr[i] 
			if [[ -n $dscr ]]
			then
				dscr=${dscr//$'\n'} 
			elif [[ -n $word ]]
			then
				dscr=$word 
			fi
			_ftb_compcap+=$dscr$'\2'$__tmp_value$'\0word\0'$word 
		done
	fi
	builtin compadd "$@"
}
-ftb-complete () {
	local -Ua _ftb_groups
	local choice choices _ftb_curcontext continuous_trigger print_query accept_line bs=$'\2' nul=$'\0' 
	local ret=0 
	(( $+builtins[fzf-tab-compcap-generate] )) && fzf-tab-compcap-generate -i
	COLUMNS=500 _ftb__main_complete "$@" || ret=$? 
	(( $+builtins[fzf-tab-compcap-generate] )) && fzf-tab-compcap-generate -o
	emulate -L zsh -o extended_glob
	local _ftb_query _ftb_complist=() _ftb_headers=() command opts 
	-ftb-generate-complist
	-ftb-zstyle -s continuous-trigger continuous_trigger || {
		[[ $OSTYPE == msys ]] && continuous_trigger=//  || continuous_trigger=/ 
	}
	case $#_ftb_complist in
		(0) return 1 ;;
		(1) choices=("EXPECT_KEY" "${_ftb_compcap[1]%$bs*}") 
			if (( _ftb_continue_last ))
			then
				choices[1]=$continuous_trigger 
			fi ;;
		(*) if (( ! _ftb_continue_last )) && [[ $compstate[insert] == *"unambiguous" ]] && [[ -n $compstate[unambiguous] ]] && [[ "$compstate[unambiguous]" != "$compstate[quote]$IPREFIX$PREFIX$compstate[quote]" ]]
			then
				compstate[list]= 
				compstate[insert]=unambiguous 
				_ftb_finish=1 
				return 0
			fi
			-ftb-generate-query
			-ftb-generate-header
			-ftb-zstyle -s print-query print_query || print_query=alt-enter 
			-ftb-zstyle -s accept-line accept_line
			choices=("${(@f)"$(builtin print -rl -- $_ftb_headers $_ftb_complist | -ftb-fzf)"}") 
			ret=$? 
			if [[ $choices[2] == $print_query ]] || [[ -n $choices[1] && $#choices == 1 ]]
			then
				local -A v=("${(@0)${_ftb_compcap[1]}}") 
				local -a args=("${(@ps:\1:)v[args]}") 
				[[ -z $args[1] ]] && args=() 
				IPREFIX=$v[IPREFIX] PREFIX=$v[PREFIX] SUFFIX=$v[SUFFIX] ISUFFIX=$v[ISUFFIX] 
				builtin compadd "${args[@]:--Q}" -Q -- $choices[1]
				compstate[list]= 
				compstate[insert]= 
				if (( $#choices[1] > 0 ))
				then
					compstate[insert]='1' 
					[[ $RBUFFER == ' '* ]] || compstate[insert]+=' ' 
				fi
				_ftb_finish=1 
				return $ret
			fi
			choices[1]=() 
			choices=("${(@)${(@)choices%$nul*}#*$nul}") 
			unset CTXT ;;
	esac
	if [[ -n $choices[1] && $choices[1] == $continuous_trigger ]]
	then
		typeset -gi _ftb_continue=1 
		typeset -gi _ftb_continue_last=1 
	fi
	if [[ -n $choices[1] && $choices[1] == $accept_line ]]
	then
		typeset -gi _ftb_accept=1 
	fi
	choices[1]=() 
	_ftb_choices=("${(@)choices}") 
	compstate[list]= 
	compstate[insert]= 
	return $ret
}
-ftb-fzf () {
	# undefined
	builtin autoload -XUz
}
-ftb-generate-complist () {
	# undefined
	builtin autoload -XUz
}
-ftb-generate-header () {
	# undefined
	builtin autoload -XUz
}
-ftb-generate-query () {
	# undefined
	builtin autoload -XUz
}
-ftb-version () {
	# undefined
	builtin autoload -XUz
}
-ftb-zstyle () {
	zstyle $1 ":fzf-tab:$_ftb_curcontext" ${@:2}
}
VCS_INFO_formats () {
	setopt localoptions noksharrays NO_shwordsplit
	local msg tmp
	local -i i
	local -A hook_com
	hook_com=(action "$1" action_orig "$1" branch "$2" branch_orig "$2" base "$3" base_orig "$3" staged "$4" staged_orig "$4" unstaged "$5" unstaged_orig "$5" revision "$6" revision_orig "$6" misc "$7" misc_orig "$7" vcs "${vcs}" vcs_orig "${vcs}") 
	hook_com[base-name]="${${hook_com[base]}:t}" 
	hook_com[base-name_orig]="${hook_com[base-name]}" 
	hook_com[subdir]="$(VCS_INFO_reposub ${hook_com[base]})" 
	hook_com[subdir_orig]="${hook_com[subdir]}" 
	: vcs_info-patch-9b9840f2-91e5-4471-af84-9e9a0dc68c1b
	for tmp in base base-name branch misc revision subdir
	do
		hook_com[$tmp]="${hook_com[$tmp]//\%/%%}" 
	done
	VCS_INFO_hook 'post-backend'
	if [[ -n ${hook_com[action]} ]]
	then
		zstyle -a ":vcs_info:${vcs}:${usercontext}:${rrn}" actionformats msgs
		(( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b|%a]%u%c-' 
	else
		zstyle -a ":vcs_info:${vcs}:${usercontext}:${rrn}" formats msgs
		(( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b]%u%c-' 
	fi
	if [[ -n ${hook_com[staged]} ]]
	then
		zstyle -s ":vcs_info:${vcs}:${usercontext}:${rrn}" stagedstr tmp
		[[ -z ${tmp} ]] && hook_com[staged]='S'  || hook_com[staged]=${tmp} 
	fi
	if [[ -n ${hook_com[unstaged]} ]]
	then
		zstyle -s ":vcs_info:${vcs}:${usercontext}:${rrn}" unstagedstr tmp
		[[ -z ${tmp} ]] && hook_com[unstaged]='U'  || hook_com[unstaged]=${tmp} 
	fi
	if [[ ${quiltmode} != 'standalone' ]] && VCS_INFO_hook "pre-addon-quilt"
	then
		local REPLY
		VCS_INFO_quilt addon
		hook_com[quilt]="${REPLY}" 
		unset REPLY
	elif [[ ${quiltmode} == 'standalone' ]]
	then
		hook_com[quilt]=${hook_com[misc]} 
	fi
	(( ${#msgs} > maxexports )) && msgs[$(( maxexports + 1 )),-1]=() 
	for i in {1..${#msgs}}
	do
		if VCS_INFO_hook "set-message" $(( $i - 1 )) "${msgs[$i]}"
		then
			zformat -f msg ${msgs[$i]} a:${hook_com[action]} b:${hook_com[branch]} c:${hook_com[staged]} i:${hook_com[revision]} m:${hook_com[misc]} r:${hook_com[base-name]} s:${hook_com[vcs]} u:${hook_com[unstaged]} Q:${hook_com[quilt]} R:${hook_com[base]} S:${hook_com[subdir]}
			msgs[$i]=${msg} 
		else
			msgs[$i]=${hook_com[message]} 
		fi
	done
	hook_com=() 
	backend_misc=() 
	return 0
}
_SUSEconfig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
__arguments () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
__git_prompt_git () {
	GIT_OPTIONAL_LOCKS=0 command git "$@"
}
__starship_get_time () {
	(( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) ))
}
_a2ps () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_a2utils () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_aap () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_abcde () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_absolute_command_paths () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ack () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_acpi () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_acpitool () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_acroread () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_adb () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_add-zle-hook-widget () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_add-zsh-hook () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_aerospace () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_alias () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_aliases () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_all_labels () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_all_matches () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_alsa-utils () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_alternative () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_analyseplugin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ansible () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ant () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_antiword () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_apachectl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_apm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_approximate () {
	(( ! IN_FZF_TAB )) || unfunction compadd
	_ftb__approximate
	(( ! IN_FZF_TAB )) || functions[compadd]=$functions[-ftb-compadd] 
}
_apt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_apt-file () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_apt-move () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_apt-show-versions () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_aptitude () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_arch_archives () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_arch_namespace () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_arg_compile () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_arguments () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_arp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_arping () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_arrays () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_asciidoctor () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_asciinema () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_assign () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_at () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_attr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_augeas () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_auto-apt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_autocd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_avahi () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_awk () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_aws-vault () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_axi-cache () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_az () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_base64 () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_basename () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_basenc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bash () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bash_complete () {
	local ret=1 
	local -a suf matches
	local -x COMP_POINT COMP_CWORD
	local -a COMP_WORDS COMPREPLY BASH_VERSINFO
	local -x COMP_LINE="$words" 
	local -A savejobstates savejobtexts
	(( COMP_POINT = 1 + ${#${(j. .)words[1,CURRENT-1]}} + $#QIPREFIX + $#IPREFIX + $#PREFIX ))
	(( COMP_CWORD = CURRENT - 1))
	COMP_WORDS=("${words[@]}") 
	BASH_VERSINFO=(2 05b 0 1 release) 
	savejobstates=(${(kv)jobstates}) 
	savejobtexts=(${(kv)jobtexts}) 
	[[ ${argv[${argv[(I)nospace]:-0}-1]} = -o ]] && suf=(-S '') 
	matches=(${(f)"$(compgen $@ -- ${words[CURRENT]})"}) 
	if [[ -n $matches ]]
	then
		if [[ ${argv[${argv[(I)filenames]:-0}-1]} = -o ]]
		then
			compset -P '*/' && matches=(${matches##*/}) 
			compset -S '/*' && matches=(${matches%%/*}) 
			compadd -f "${suf[@]}" -a matches && ret=0 
		else
			compadd "${suf[@]}" - "${(@)${(Q@)matches}:#*\ }" && ret=0 
			compadd -S ' ' - ${${(M)${(Q)matches}:#*\ }% } && ret=0 
		fi
	fi
	if (( ret ))
	then
		if [[ ${argv[${argv[(I)default]:-0}-1]} = -o ]]
		then
			_default "${suf[@]}" && ret=0 
		elif [[ ${argv[${argv[(I)dirnames]:-0}-1]} = -o ]]
		then
			_directories "${suf[@]}" && ret=0 
		fi
	fi
	return ret
}
_bash_completions () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_baudrates () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_baz () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_be_name () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_beadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_beep () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bibtex () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bind_addresses () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bindkey () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bison () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bittorrent () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bogofilter () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bpf_filters () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bpython () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_brace_parameter () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_brctl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_brew () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_bsd_disks () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bsd_pkg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bsdconfig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bsdinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_btrfs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bug () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_builtin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bzip2 () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_bzr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cabal () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cache_invalid () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_caffeinate () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cal () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_calendar () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_call_function () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_call_program () {
	local -xi COLUMNS=999 
	local curcontext="${curcontext}" tmp err_fd=-1 clocale='_comp_locale;' 
	local -a prefix
	if [[ "$1" = -p ]]
	then
		shift
		if (( $#_comp_priv_prefix ))
		then
			curcontext="${curcontext%:*}/${${(@M)_comp_priv_prefix:#^*[^\\]=*}[1]}:" 
			zstyle -t ":completion:${curcontext}:${1}" gain-privileges && prefix=($_comp_priv_prefix) 
		fi
	elif [[ "$1" = -l ]]
	then
		shift
		clocale='' 
	fi
	if (( ${debug_fd:--1} > 2 )) || [[ ! -t 2 ]]
	then
		exec {err_fd}>&2
	else
		exec {err_fd}> /dev/null
	fi
	{
		if zstyle -s ":completion:${curcontext}:${1}" command tmp
		then
			if [[ "$tmp" = -* ]]
			then
				eval $clocale "$tmp[2,-1]" "$argv[2,-1]"
			else
				eval $clocale $prefix "$tmp"
			fi
		else
			eval $clocale $prefix "$argv[2,-1]"
		fi 2>&$err_fd
	} always {
		exec {err_fd}>&-
	}
}
_canonical_paths () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_capabilities () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ccal () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cdbs-edit-patch () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cdcd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cdr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cdrdao () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cdrecord () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_chattr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_chcon () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_chflags () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_chkconfig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_chmod () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_choom () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_chown () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_chroot () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_chrt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_chsh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cksum () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_clay () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cmdambivalent () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cmdstring () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cmp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_code () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_column () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_combination () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_comm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_command () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_command_names () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_comp_locale () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_compadd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_compdef () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_complete () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_complete_debug () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_complete_help () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_complete_help_generic () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_complete_tag () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_completers () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_composer () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_compress () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_condition () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_configure () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_coreadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_correct () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_correct_filename () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_correct_word () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cowsay () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cpio () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cplay () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cpupower () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_crontab () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cryptsetup () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cscope () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_csplit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cssh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_csup () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ctags () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ctags_tags () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cu () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_curl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cut () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cvs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cvsup () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cygcheck () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cygpath () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cygrunsrv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cygserver () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_cygstart () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dak () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_darcs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_date () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_date_formats () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dates () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dbus () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dchroot () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dchroot-dsa () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dconf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dcop () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dcut () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_deb_architectures () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_deb_codenames () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_deb_files () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_deb_packages () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_debbugs_bugnumber () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_debchange () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_debcheckout () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_debdiff () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_debfoster () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_deborphan () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_debsign () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_debsnap () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_debuild () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_default () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_defaults () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_defer_async_git_register () {
	case "${PS1}:${PS2}:${PS3}:${PS4}:${RPROMPT}:${RPS1}:${RPS2}:${RPS3}:${RPS4}" in
		(*(\$\(git_prompt_info\)|\`git_prompt_info\`)*) _omz_register_handler _omz_git_prompt_info ;;
	esac
	case "${PS1}:${PS2}:${PS3}:${PS4}:${RPROMPT}:${RPS1}:${RPS2}:${RPS3}:${RPS4}" in
		(*(\$\(git_prompt_status\)|\`git_prompt_status\`)*) _omz_register_handler _omz_git_prompt_status ;;
	esac
	add-zsh-hook -d precmd _defer_async_git_register
	unset -f _defer_async_git_register
}
_delimiters () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_describe () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_description () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_devtodo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_df () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dhclient () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dhcpinfo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dict () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dict_words () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_diff () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_diff3 () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_diff_options () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_diffstat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dir_list () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_directories () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_directory_stack () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dirs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_disable () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dispatch () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_django () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dkms () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dladm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dlocate () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dmesg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dmidecode () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dnf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dns_types () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_doas () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_docker () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_domains () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dos2unix () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dpatch-edit-patch () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dpkg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dpkg-buildpackage () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dpkg-cross () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dpkg-repack () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dpkg_source () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dput () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_drill () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dropbox () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dscverify () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dsh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dtrace () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dtruss () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_du () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dumpadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dumper () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dupload () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dvi () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_dyff () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_dynamic_directory_name () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_e2label () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ecasound () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_echotc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_echoti () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ed () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_elfdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_elinks () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_email_addresses () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_emulate () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_enable () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_enscript () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_entr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_env () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_eog () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_equal () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_espeak () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_etags () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ethtool () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_evince () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_exec () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_expand () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_expand_alias () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_expand_word () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_extensions () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_external_pwds () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fakeroot () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fbsd_architectures () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fbsd_device_types () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_feh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fetch () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fetchmail () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ffmpeg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_figlet () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_file_descriptors () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_file_flags () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_file_modes () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_file_systems () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_files () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_find () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_find_net_interfaces () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_findmnt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_finger () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fink () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_first () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_flac () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_flex () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_floppy () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_flowadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_flux () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_fmadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fmt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fold () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fortune () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_free () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_freebsd-update () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fs_usage () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fsh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fstat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ftb__approximate () {
	[[ _matcher_num -gt 1 || "${#:-$PREFIX$SUFFIX}" -le 1 ]] && return 1
	local _comp_correct _correct_expl _correct_group comax cfgacc match
	local oldcontext="${curcontext}" opm="$compstate[pattern_match]" 
	local dounfunction
	integer ret=1 
	if [[ "$1" = -a* ]]
	then
		cfgacc="${1[3,-1]}" 
	elif [[ "$1" = -a ]]
	then
		cfgacc="$2" 
	else
		zstyle -s ":completion:${curcontext}:" max-errors cfgacc || cfgacc='2 numeric' 
	fi
	if [[ "$cfgacc" = *numeric* && ${NUMERIC:-1} -ne 1 ]]
	then
		[[ "$cfgacc" = *not-numeric* ]] && return 1
		comax="${NUMERIC:-1}" 
	else
		comax="${cfgacc//[^0-9]}" 
	fi
	[[ "$comax" -lt 1 ]] && return 1
	_tags corrections original
	{
		if (( ! $+functions[compadd] ))
		then
			dounfunction=1 
			compadd () {
				local ppre="$argv[(I)-p]" 
				[[ ${argv[(I)-[a-zA-Z]#U[a-zA-Z]#]} -eq 0 && "${#:-$PREFIX$SUFFIX}" -le _comp_correct ]] && return
				if [[ "$PREFIX" = \~* && ( ppre -eq 0 || "$argv[ppre+1]" != \~* ) ]]
				then
					PREFIX="~(#a${_comp_correct})${PREFIX[2,-1]}" 
				else
					PREFIX="(#a${_comp_correct})$PREFIX" 
				fi
				(( $_correct_group && ${${argv[1,(r)-(|-)]}[(I)-*[JV]]} )) && _correct_expl[_correct_group]=${argv[1,(r)-(-|)][(R)-*[JV]]} 
				builtin compadd "$_correct_expl[@]" "$@"
			}
		fi
		_comp_correct=1 
		[[ -z "$compstate[pattern_match]" ]] && compstate[pattern_match]='*' 
		while [[ _comp_correct -le comax ]]
		do
			curcontext="${oldcontext/(#b)([^:]#:[^:]#:)/${match[1][1,-2]}-${_comp_correct}:}" 
			_description corrections _correct_expl corrections "e:$_comp_correct" "o:$PREFIX$SUFFIX"
			_correct_group="$_correct_expl[(I)-*[JV]]" 
			if _complete
			then
				if zstyle -t ":completion:${curcontext}:" insert-unambiguous && [[ "${#compstate[unambiguous]}" -ge "${#:-$PREFIX$SUFFIX}" ]]
				then
					compstate[pattern_insert]=unambiguous 
				elif _requested original && {
						[[ compstate[nmatches] -gt 1 ]] || zstyle -t ":completion:${curcontext}:" original
					}
				then
					local expl
					_description -V original expl original
					builtin compadd "$expl[@]" -U -Q - "$PREFIX$SUFFIX"
					[[ "$compstate[list]" != list* ]] && compstate[list]="$compstate[list] force" 
				fi
				compstate[pattern_match]="$opm" 
				ret=0 
				break
			fi
			[[ "${#:-$PREFIX$SUFFIX}" -le _comp_correct+1 ]] && break
			(( _comp_correct++ ))
		done
	} always {
		[[ -n $dounfunction ]] && (( $+functions[compadd] )) && unfunction compadd
	}
	(( ret == 0 )) && return 0
	compstate[pattern_match]="$opm" 
	return 1
}
_ftb__main_complete () {
	local IFS=$' \t\n\0' 
	eval "$_comp_setup"
	local func funcs ret=1 tmp _compskip format nm call match min max i num _completers _completer _completer_num curtag _comp_force_list _matchers _matcher _c_matcher _matcher_num _comp_tags _comp_mesg mesg str context state state_descr line opt_args val_args curcontext="$curcontext" _last_nmatches=-1 _last_menu_style _def_menu_style _menu_style sel _tags_level=0 _saved_exact="${compstate[exact]}" _saved_lastprompt="${compstate[last_prompt]}" _saved_list="${compstate[list]}" _saved_insert="${compstate[insert]}" _saved_colors="$ZLS_COLORS" _saved_colors_set=${+ZLS_COLORS} _ambiguous_color='' 
	local _comp_priv_prefix
	unset _comp_priv_prefix
	local -a precommands
	local -ar builtin_precommands=(- builtin eval exec nocorrect noglob time) 
	typeset -U _lastdescr _comp_ignore _comp_colors
	{
		[[ -z "$curcontext" ]] && curcontext=::: 
		zstyle -s ":completion:${curcontext}:" insert-tab tmp || tmp=yes 
		if [[ ( "$tmp" = *pending(|[[:blank:]]*) && PENDING -gt 0 ) || ( "$tmp" = *pending=(#b)([0-9]##)(|[[:blank:]]*) && PENDING -ge $match[1] ) ]]
		then
			compstate[insert]=tab 
			return 0
		fi
		if [[ "$compstate[insert]" = tab* ]]
		then
			if [[ "$tmp" = (|*[[:blank:]])(yes|true|on|1)(|[[:blank:]]*) ]]
			then
				if [[ "$curcontext" != :* || -z "$compstate[vared]" ]] || zstyle -t ":completion:vared${curcontext}:" insert-tab
				then
					return 0
				fi
			fi
			compstate[insert]="${compstate[insert]//tab /}" 
		fi
		if [[ "$compstate[pattern_match]" = "*" && "$_lastcomp[unambiguous]" = "$PREFIX" && -n "$_lastcomp[unambiguous_cursor]" ]]
		then
			integer upos="$_lastcomp[unambiguous_cursor]" 
			SUFFIX="$PREFIX[upos,-1]$SUFFIX" 
			PREFIX="$PREFIX[1,upos-1]" 
		fi
		if [[ -z "$compstate[quote]" ]]
		then
			if [[ -o equals ]] && compset -P 1 '='
			then
				compstate[context]=equal 
			elif [[ "$PREFIX" != */* && "$PREFIX[1]" = '~' ]]
			then
				if [[ "$PREFIX" = '~['[^\]]# ]]
				then
					compset -p 2
					compset -S '\]*'
					compstate[context]=subscript 
					[[ -n $_comps[-subscript-] ]] && $_comps[-subscript-] && return
				else
					compset -p 1
					compstate[context]=tilde 
				fi
			fi
		fi
		_setup default
		_def_menu_style=("$_last_menu_style[@]") 
		_last_menu_style=() 
		if zstyle -s ":completion:${curcontext}:default" list-prompt tmp
		then
			LISTPROMPT="$tmp" 
			zmodload -i zsh/complist
		fi
		if zstyle -s ":completion:${curcontext}:default" select-prompt tmp
		then
			MENUPROMPT="$tmp" 
			zmodload -i zsh/complist
		fi
		if zstyle -s ":completion:${curcontext}:default" select-scroll tmp
		then
			MENUSCROLL="$tmp" 
			zmodload -i zsh/complist
		fi
		if (( $# ))
		then
			if [[ "$1" = - ]]
			then
				if [[ $# -lt 3 ]]
				then
					_completers=() 
				else
					_completers=("$2") 
					call=yes 
				fi
			else
				_completers=("$@") 
			fi
		else
			zstyle -a ":completion:${curcontext}:" completer _completers || _completers=(_complete _ignored) 
		fi
		_completer_num=1 
		integer SECONDS=0 
		TRAPINT () {
			zle -M "Killed by signal in ${funcstack[2]} after ${SECONDS}s"
			zle -R
			return 130
		}
		TRAPQUIT () {
			zle -M "Killed by signal in ${funcstack[2]} after ${SECONDS}s"
			zle -R
			return 131
		}
		funcs=("$compprefuncs[@]") 
		compprefuncs=() 
		for func in "$funcs[@]"
		do
			"$func"
		done
		for tmp in "$_completers[@]"
		do
			if [[ -n "$call" ]]
			then
				_completer="${tmp}" 
			elif [[ "$tmp" = *:-* ]]
			then
				_completer="${${tmp%:*}[2,-1]//_/-}${tmp#*:}" 
				tmp="${tmp%:*}" 
			elif [[ $tmp = *:* ]]
			then
				_completer="${tmp#*:}" 
				tmp="${tmp%:*}" 
			else
				_completer="${tmp[2,-1]//_/-}" 
			fi
			curcontext="${curcontext/:[^:]#:/:${_completer}:}" 
			zstyle -t ":completion:${curcontext}:" show-completer && zle -R "Trying completion for :completion:${curcontext}"
			zstyle -a ":completion:${curcontext}:" matcher-list _matchers || _matchers=('') 
			_matcher_num=1 
			_matcher='' 
			for _c_matcher in "$_matchers[@]"
			do
				if [[ "$_c_matcher" == +* ]]
				then
					_matcher="$_matcher $_c_matcher[2,-1]" 
				else
					_matcher="$_c_matcher" 
				fi
				_comp_mesg= 
				if [[ -n "$call" ]]
				then
					if "${(@)argv[3,-1]}"
					then
						ret=0 
						break 2
					fi
				elif "$tmp"
				then
					ret=0 
					break 2
				fi
				(( _matcher_num++ ))
			done
			[[ -n "$_comp_mesg" ]] && break
			(( _completer_num++ ))
		done
		curcontext="${curcontext/:[^:]#:/::}" 
		if [[ $compstate[old_list] = keep ]]
		then
			nm=$_lastcomp[nmatches] 
		else
			nm=$compstate[nmatches] 
		fi
		if [[ $compstate[old_list] = keep || nm -gt 1 ]]
		then
			[[ _last_nmatches -ge 0 && _last_nmatches -ne nm ]] && _menu_style=("$_last_menu_style[@]" "$_menu_style[@]") 
			tmp=$(( compstate[list_lines] + BUFFERLINES + 1 )) 
			_menu_style=("$_menu_style[@]" "$_def_menu_style[@]") 
			if [[ "$compstate[list]" = *list(| *) && tmp -gt LINES && ( -n "$_menu_style[(r)select=long-list]" || -n "$_menu_style[(r)(yes|true|on|1)=long-list]" ) ]]
			then
				compstate[insert]=menu 
			elif [[ "$compstate[insert]" = "$_saved_insert" ]]
			then
				if [[ -n "$compstate[insert]" && -n "$_menu_style[(r)(yes|true|1|on)=long]" && tmp -gt LINES ]]
				then
					compstate[insert]=menu 
				else
					sel=("${(@M)_menu_style:#(yes|true|1|on)*}") 
					if (( $#sel ))
					then
						min=9999999 
						for i in "$sel[@]"
						do
							if [[ "$i" = *\=[0-9]* ]]
							then
								num="${i#*\=}" 
								[[ num -lt 0 ]] && num=0 
							elif [[ "$i" != *\=* ]]
							then
								num=0 
							else
								num=9999999 
							fi
							[[ num -lt min ]] && min="$num" 
							(( min )) || break
						done
					fi
					sel=("${(@M)_menu_style:#(no|false|0|off)*}") 
					if (( $#sel ))
					then
						max=9999999 
						for i in "$sel[@]"
						do
							if [[ "$i" = *\=[0-9]* ]]
							then
								num="${i#*\=}" 
								[[ num -lt 0 ]] && num=0 
							elif [[ "$i" != *\=* ]]
							then
								num=0 
							else
								num=9999999 
							fi
							[[ num -lt max ]] && max="$num" 
							(( max )) || break
						done
					fi
					if [[ ( -n "$min" && nm -ge min && ( -z "$max" || nm -lt max ) ) || ( -n "$_menu_style[(r)auto*]" && "$compstate[insert]" = automenu ) ]]
					then
						compstate[insert]=menu 
					elif [[ -n "$max" && nm -ge max ]]
					then
						compstate[insert]=unambiguous 
					elif [[ -n "$_menu_style[(r)auto*]" && "$compstate[insert]" != automenu ]]
					then
						compstate[insert]=automenu-unambiguous 
					fi
				fi
			fi
			if [[ "$compstate[insert]" = *menu* ]]
			then
				[[ "$MENUSELECT" = 00 ]] && MENUSELECT=0 
				if [[ -n "$_menu_style[(r)no-select*]" ]]
				then
					unset MENUSELECT
				elif [[ -n "$_menu_style[(r)select=long*]" ]]
				then
					if [[ tmp -gt LINES ]]
					then
						zmodload -i zsh/complist
						MENUSELECT=00 
					fi
				fi
				if [[ "$MENUSELECT" != 00 ]]
				then
					sel=("${(@M)_menu_style:#select*}") 
					if (( $#sel ))
					then
						min=9999999 
						for i in "$sel[@]"
						do
							if [[ "$i" = *\=[0-9]* ]]
							then
								num="${i#*\=}" 
								[[ num -lt 0 ]] && num=0 
							elif [[ "$i" != *\=* ]]
							then
								num=0 
							else
								num=9999999 
							fi
							[[ num -lt min ]] && min="$num" 
							(( min )) || break
						done
						zmodload -i zsh/complist
						MENUSELECT="$min" 
					else
						unset MENUSELECT
					fi
				fi
				if [[ -n "$MENUSELECT" ]]
				then
					if [[ -n "$_menu_style[(r)interactive*]" ]]
					then
						MENUMODE=interactive 
					elif [[ -n "$_menu_style[(r)search*]" ]]
					then
						if [[ -n "$_menu_style[(r)*backward*]" ]]
						then
							MENUMODE=search-backward 
						else
							MENUMODE=search-forward 
						fi
					else
						unset MENUMODE
					fi
				fi
			fi
		elif [[ nm -lt 1 && -n "$_comp_mesg" ]]
		then
			compstate[insert]='' 
			compstate[list]='list force' 
		elif [[ nm -eq 0 && -z "$_comp_mesg" && $#_lastdescr -ne 0 && $compstate[old_list] != keep ]] && zstyle -s ":completion:${curcontext}:warnings" format format
		then
			compstate[list]='list force' 
			compstate[insert]='' 
			tmp=("\`${(@)^_lastdescr:#}'") 
			case $#tmp in
				(1) str="$tmp[1]"  ;;
				(2) str="$tmp[1] or $tmp[2]"  ;;
				(*) str="${(j:, :)tmp[1,-2]}, or $tmp[-1]"  ;;
			esac
			_setup warnings
			zformat -f mesg "$format" "d:$str" "D:${(F)${(@)_lastdescr:#}}"
			compadd -x "$mesg"
		fi
		if [[ -n "$_ambiguous_color" ]]
		then
			local toquote='[=\(\)\|~^?*[\]#<>]' 
			local prefix=${${compstate[unambiguous]}[1,${compstate[unambiguous_cursor]}-1]} 
			[[ -n $prefix ]] && _comp_colors+=("=(#i)${prefix[1,-2]//?/(}${prefix[1,-2]//(#m)?/${MATCH/$~toquote/\\$MATCH}|)}${prefix[-1]//(#m)$~toquote/\\$MATCH}(#b)(?|)*==$_ambiguous_color") 
		fi
		[[ "$_comp_force_list" = always || ( "$_comp_force_list" = ?* && nm -ge _comp_force_list ) ]] && compstate[list]="${compstate[list]//messages} force" 
	} always {
		if [[ "$compstate[old_list]" = keep ]]
		then
			if [[ $_saved_colors_set = 1 ]]
			then
				ZLS_COLORS="$_saved_colors" 
			else
				unset ZLS_COLORS
			fi
		elif (( $#_comp_colors ))
		then
			ZLS_COLORS="${(j.:.)_comp_colors}" 
		else
			unset ZLS_COLORS
		fi
	}
	funcs=("$comppostfuncs[@]") 
	comppostfuncs=() 
	for func in "$funcs[@]"
	do
		"$func"
	done
	_lastcomp=("${(@kv)compstate}") 
	_lastcomp[nmatches]=$nm 
	_lastcomp[completer]="$_completer" 
	_lastcomp[prefix]="$PREFIX" 
	_lastcomp[suffix]="$SUFFIX" 
	_lastcomp[iprefix]="$IPREFIX" 
	_lastcomp[isuffix]="$ISUFFIX" 
	_lastcomp[qiprefix]="$QIPREFIX" 
	_lastcomp[qisuffix]="$QISUFFIX" 
	_lastcomp[tags]="$_comp_tags" 
	return ret
}
_functions () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fuse_arguments () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fuse_values () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fuser () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fusermount () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fw_update () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_fx () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_fzf-tab-apply () {
	local choice bs=$'\2' 
	for choice in "$_ftb_choices[@]"
	do
		local -A v=("${(@0)${_ftb_compcap[(r)${(b)choice}$bs*]#*$bs}}") 
		local -a args=("${(@ps:\1:)v[args]}") 
		[[ -z $args[1] ]] && args=() 
		IPREFIX=$v[IPREFIX] PREFIX=$v[PREFIX] SUFFIX=$v[SUFFIX] ISUFFIX=$v[ISUFFIX] 
		builtin compadd "${args[@]:--Q}" -Q -- "$v[word]"
	done
	compstate[list]= 
	if (( $#_ftb_choices == 1 ))
	then
		compstate[insert]='1' 
		[[ $RBUFFER == ' '* ]] || compstate[insert]+=' ' 
	elif (( $#_ftb_choices > 1 ))
	then
		compstate[insert]='all' 
	fi
}
_gcc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gcore () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gdb () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_geany () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gem () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_generic () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_genisoimage () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_getclip () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_getconf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_getent () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_getfacl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_getmail () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_getopt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gh () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_ghostscript () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ghostty () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_git () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_git-buildpackage () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_git_log_prettily () {
	if ! [ -z $1 ]
	then
		git log --pretty=$1
	fi
}
_global () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_global_tags () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_globflags () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_globqual_delims () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_globquals () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gnome-gv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gnu_generic () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gnupod () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gnutls () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_go () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gpasswd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gpg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gphoto2 () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gprof () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gqview () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gradle () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_graphicsmagick () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_grep () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_grep-excuses () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_groff () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_groups () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_growisofs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gsettings () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gstat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_guard () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_guilt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_gzip () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_hash () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_have_glob_qual () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_hdiutil () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_head () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_hexdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_history () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_history_complete_word () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_history_modifiers () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_host () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_hostname () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_hosts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_htop () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_hwinfo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_iconv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_iconvconfig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_id () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ifconfig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_iftop () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ignored () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_imagemagick () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_in_vared () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_inetadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_init_d () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_initctl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_install () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_invoke-rc.d () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ionice () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_iostat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ip () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ipadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ipfw () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ipsec () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ipset () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_iptables () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_irssi () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ispell () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_iwconfig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jail () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jails () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_java () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_java_class () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jexec () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jls () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jobs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jobs_bg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jobs_builtin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jobs_fg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_joe () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_join () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jot () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_jq () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_kdeconnect () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_kdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_kfmclient () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_kill () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_killall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_kj () {
	words=(kubectl "${words[@]:1}") 
	_kubectl
}
_kjx () {
	words=(kubectl "${words[@]:1}") 
	_kubectl
}
_kld () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_knock () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_kpartx () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ktrace () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ktrace_points () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_kubectl () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_kvno () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ky () {
	words=(kubectl "${words[@]:1}") 
	_kubectl
}
_kyverno () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_last () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ld_debug () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ldap () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ldconfig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ldd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_less () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lha () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_libvirt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lighttpd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_limit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_limits () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_links () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lintian () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_list () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_list_files () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lldb () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ln () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_loadkeys () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_locale () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_localedef () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_locales () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_locate () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_logger () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_logical_volumes () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_login_classes () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_look () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_losetup () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ls () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lsattr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lsblk () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lscfg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lsd () {
	# undefined
	builtin autoload -XUz /opt/homebrew/share/zsh/site-functions
}
_lsdev () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lslv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lsns () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lsof () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lspv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lsusb () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lsvg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ltrace () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lua () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_luarocks () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lynx () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lz4 () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_lzop () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mac_applications () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mac_files_for_application () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_madison () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mail () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mailboxes () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_main_complete () {
	-ftb-complete "$@"
}
_make () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_make-kpkg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_man () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mat2 () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_match () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_math () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_math_params () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_matlab () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_md5sum () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mdadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mdfind () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mdls () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mdutil () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_members () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mencal () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_menu () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mere () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mergechanges () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_message () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mii-tool () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mime_types () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mise_hook () {
	eval "$(/Users/steve.briggs/.local/bin/mise hook-env -s zsh)"
}
_mise_hook_chpwd () {
	eval "$(/Users/steve.briggs/.local/bin/mise hook-env -s zsh --reason chpwd)"
}
_mise_hook_precmd () {
	eval "$(/Users/steve.briggs/.local/bin/mise hook-env -s zsh --reason precmd)"
}
_mixerctl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mkdir () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mkfifo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mknod () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mkshortcut () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mktemp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mkzsh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_module () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_module-assistant () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_module_math_func () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_modutils () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mondo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_monotone () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_moosic () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mosh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_most_recent_file () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mount () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mozilla () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mpc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mplayer () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mtools () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mtr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_multi_parts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mupdf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mutt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_my_accounts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_myrepos () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mysql_utils () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_mysqldiff () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nautilus () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nbsd_architectures () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ncftp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nedit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_net_interfaces () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_netcat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_netscape () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_netstat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_networkmanager () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_networksetup () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_newsgroups () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_next_label () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_next_tags () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ng_yargs_completions () {
	local reply
	local si=$IFS 
	IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" ng --get-yargs-completions "${words[@]}")) 
	IFS=$si 
	if [[ ${#reply} -gt 0 ]]
	then
		_describe 'values' reply
	else
		_default
	fi
}
_nginx () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ngrep () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nice () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nkf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nmap () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_normal () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nothing () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_npm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nsenter () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nslookup () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_numbers () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_numfmt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_nvram () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_objdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_object_classes () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_object_files () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_obsd_architectures () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_od () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_okular () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_oldlist () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_omz () {
	local -a cmds subcmds
	cmds=('changelog:Print the changelog' 'help:Usage information' 'plugin:Manage plugins' 'pr:Manage Oh My Zsh Pull Requests' 'reload:Reload the current zsh session' 'shop:Open the Oh My Zsh shop' 'theme:Manage themes' 'update:Update Oh My Zsh' 'version:Show the version') 
	if (( CURRENT == 2 ))
	then
		_describe 'command' cmds
	elif (( CURRENT == 3 ))
	then
		case "$words[2]" in
			(changelog) local -a refs
				refs=("${(@f)$(builtin cd -q "$ZSH"; command git for-each-ref --format="%(refname:short):%(subject)" refs/heads refs/tags)}") 
				_describe 'command' refs ;;
			(plugin) subcmds=('disable:Disable plugin(s)' 'enable:Enable plugin(s)' 'info:Get plugin information' 'list:List plugins' 'load:Load plugin(s)') 
				_describe 'command' subcmds ;;
			(pr) subcmds=('clean:Delete all Pull Request branches' 'test:Test a Pull Request') 
				_describe 'command' subcmds ;;
			(theme) subcmds=('list:List themes' 'set:Set a theme in your .zshrc file' 'use:Load a theme') 
				_describe 'command' subcmds ;;
		esac
	elif (( CURRENT == 4 ))
	then
		case "${words[2]}::${words[3]}" in
			(plugin::(disable|enable|load)) local -aU valid_plugins
				if [[ "${words[3]}" = disable ]]
				then
					valid_plugins=($plugins) 
				else
					valid_plugins=("$ZSH"/plugins/*/{_*,*.plugin.zsh}(-.N:h:t) "$ZSH_CUSTOM"/plugins/*/{_*,*.plugin.zsh}(-.N:h:t)) 
					[[ "${words[3]}" = enable ]] && valid_plugins=(${valid_plugins:|plugins}) 
				fi
				_describe 'plugin' valid_plugins ;;
			(plugin::info) local -aU plugins
				plugins=("$ZSH"/plugins/*/{_*,*.plugin.zsh}(-.N:h:t) "$ZSH_CUSTOM"/plugins/*/{_*,*.plugin.zsh}(-.N:h:t)) 
				_describe 'plugin' plugins ;;
			(plugin::list) local -a opts
				opts=('--enabled:List enabled plugins only') 
				_describe -o 'options' opts ;;
			(theme::(set|use)) local -aU themes
				themes=("$ZSH"/themes/*.zsh-theme(-.N:t:r) "$ZSH_CUSTOM"/**/*.zsh-theme(-.N:r:gs:"$ZSH_CUSTOM"/themes/:::gs:"$ZSH_CUSTOM"/:::)) 
				_describe 'theme' themes ;;
		esac
	elif (( CURRENT > 4 ))
	then
		case "${words[2]}::${words[3]}" in
			(plugin::(enable|disable|load)) local -aU valid_plugins
				if [[ "${words[3]}" = disable ]]
				then
					valid_plugins=($plugins) 
				else
					valid_plugins=("$ZSH"/plugins/*/{_*,*.plugin.zsh}(-.N:h:t) "$ZSH_CUSTOM"/plugins/*/{_*,*.plugin.zsh}(-.N:h:t)) 
					[[ "${words[3]}" = enable ]] && valid_plugins=(${valid_plugins:|plugins}) 
				fi
				local -a args
				args=(${words[4,$(( CURRENT - 1))]}) 
				valid_plugins=(${valid_plugins:|args}) 
				_describe 'plugin' valid_plugins ;;
		esac
	fi
	return 0
}
_omz::changelog () {
	local version=${1:-HEAD} format=${3:-"--text"} 
	if (
			builtin cd -q "$ZSH"
			! command git show-ref --verify refs/heads/$version && ! command git show-ref --verify refs/tags/$version && ! command git rev-parse --verify "${version}^{commit}"
		) &> /dev/null
	then
		cat >&2 <<EOF
Usage: ${(j: :)${(s.::.)0#_}} [version]

NOTE: <version> must be a valid branch, tag or commit.
EOF
		return 1
	fi
	ZSH="$ZSH" command zsh -f "$ZSH/tools/changelog.sh" "$version" "${2:-}" "$format"
}
_omz::confirm () {
	if [[ -n "$1" ]]
	then
		_omz::log prompt "$1" "${${functrace[1]#_}%:*}"
	fi
	read -r -k 1
	if [[ "$REPLY" != $'\n' ]]
	then
		echo
	fi
}
_omz::help () {
	cat >&2 <<EOF
Usage: omz <command> [options]

Available commands:

  help                Print this help message
  changelog           Print the changelog
  plugin <command>    Manage plugins
  pr     <command>    Manage Oh My Zsh Pull Requests
  reload              Reload the current zsh session
  shop                Open the Oh My Zsh shop
  theme  <command>    Manage themes
  update              Update Oh My Zsh
  version             Show the version

EOF
}
_omz::log () {
	setopt localoptions nopromptsubst
	local logtype=$1 
	local logname=${3:-${${functrace[1]#_}%:*}} 
	if [[ $logtype = debug && -z $_OMZ_DEBUG ]]
	then
		return
	fi
	case "$logtype" in
		(prompt) print -Pn "%S%F{blue}$logname%f%s: $2" ;;
		(debug) print -P "%F{white}$logname%f: $2" ;;
		(info) print -P "%F{green}$logname%f: $2" ;;
		(warn) print -P "%S%F{yellow}$logname%f%s: $2" ;;
		(error) print -P "%S%F{red}$logname%f%s: $2" ;;
	esac >&2
}
_omz::plugin () {
	(( $# > 0 && $+functions[$0::$1] )) || {
		cat >&2 <<EOF
Usage: ${(j: :)${(s.::.)0#_}} <command> [options]

Available commands:

  disable <plugin> Disable plugin(s)
  enable <plugin>  Enable plugin(s)
  info <plugin>    Get information of a plugin
  list [--enabled] List Oh My Zsh plugins
  load <plugin>    Load plugin(s)

EOF
		return 1
	}
	local command="$1" 
	shift
	$0::$command "$@"
}
_omz::plugin::disable () {
	if [[ -z "$1" ]]
	then
		echo "Usage: ${(j: :)${(s.::.)0#_}} <plugin> [...]" >&2
		return 1
	fi
	local -a dis_plugins
	for plugin in "$@"
	do
		if [[ ${plugins[(Ie)$plugin]} -eq 0 ]]
		then
			_omz::log warn "plugin '$plugin' is not enabled."
			continue
		fi
		dis_plugins+=("$plugin") 
	done
	if [[ ${#dis_plugins} -eq 0 ]]
	then
		return 1
	fi
	local awk_subst_plugins="  gsub(/[ \t]+(${(j:|:)dis_plugins})[ \t]+/, \" \") # with spaces before or after
  gsub(/[ \t]+(${(j:|:)dis_plugins})$/, \"\")       # with spaces before and EOL
  gsub(/^(${(j:|:)dis_plugins})[ \t]+/, \"\")       # with BOL and spaces after

  gsub(/\((${(j:|:)dis_plugins})[ \t]+/, \"(\")     # with parenthesis before and spaces after
  gsub(/[ \t]+(${(j:|:)dis_plugins})\)/, \")\")     # with spaces before or parenthesis after
  gsub(/\((${(j:|:)dis_plugins})\)/, \"()\")        # with only parentheses

  gsub(/^(${(j:|:)dis_plugins})\)/, \")\")          # with BOL and closing parenthesis
  gsub(/\((${(j:|:)dis_plugins})$/, \"(\")          # with opening parenthesis and EOL
" 
	local awk_script="
# if plugins=() is in oneline form, substitute disabled plugins and go to next line
/^[ \t]*plugins=\([^#]+\).*\$/ {
  $awk_subst_plugins
  print \$0
  next
}

# if plugins=() is in multiline form, enable multi flag and disable plugins if they're there
/^[ \t]*plugins=\(/ {
  multi=1
  $awk_subst_plugins
  print \$0
  next
}

# if multi flag is enabled and we find a valid closing parenthesis, remove plugins and disable multi flag
multi == 1 && /^[^#]*\)/ {
  multi=0
  $awk_subst_plugins
  print \$0
  next
}

multi == 1 && length(\$0) > 0 {
  $awk_subst_plugins
  if (length(\$0) > 0) print \$0
  next
}

{ print \$0 }
" 
	local zdot="${ZDOTDIR:-$HOME}" 
	local zshrc="${${:-"${zdot}/.zshrc"}:A}" 
	awk "$awk_script" "$zshrc" > "$zdot/.zshrc.new" && command cp -f "$zshrc" "$zdot/.zshrc.bck" && command mv -f "$zdot/.zshrc.new" "$zshrc"
	[[ $? -eq 0 ]] || {
		local ret=$? 
		_omz::log error "error disabling plugins."
		return $ret
	}
	if ! command zsh -n "$zdot/.zshrc"
	then
		_omz::log error "broken syntax in '"${zdot/#$HOME/\~}/.zshrc"'. Rolling back changes..."
		command mv -f "$zdot/.zshrc.bck" "$zshrc"
		return 1
	fi
	_omz::log info "plugins disabled: ${(j:, :)dis_plugins}."
	[[ ! -o interactive ]] || _omz::reload
}
_omz::plugin::enable () {
	if [[ -z "$1" ]]
	then
		echo "Usage: ${(j: :)${(s.::.)0#_}} <plugin> [...]" >&2
		return 1
	fi
	local -a add_plugins
	for plugin in "$@"
	do
		if [[ ${plugins[(Ie)$plugin]} -ne 0 ]]
		then
			_omz::log warn "plugin '$plugin' is already enabled."
			continue
		fi
		add_plugins+=("$plugin") 
	done
	if [[ ${#add_plugins} -eq 0 ]]
	then
		return 1
	fi
	local awk_script="
# if plugins=() is in oneline form, substitute ) with new plugins and go to the next line
/^[ \t]*plugins=\([^#]+\).*\$/ {
  sub(/\)/, \" $add_plugins&\")
  print \$0
  next
}

# if plugins=() is in multiline form, enable multi flag and indent by default with 2 spaces
/^[ \t]*plugins=\(/ {
  multi=1
  indent=\"  \"
  print \$0
  next
}

# if multi flag is enabled and we find a valid closing parenthesis,
# add new plugins with proper indent and disable multi flag
multi == 1 && /^[^#]*\)/ {
  multi=0
  split(\"$add_plugins\",p,\" \")
  for (i in p) {
    print indent p[i]
  }
  print \$0
  next
}

# if multi flag is enabled and we didnt find a closing parenthesis,
# get the indentation level to match when adding plugins
multi == 1 && /^[^#]*/ {
  indent=\"\"
  for (i = 1; i <= length(\$0); i++) {
    char=substr(\$0, i, 1)
    if (char == \" \" || char == \"\t\") {
      indent = indent char
    } else {
      break
    }
  }
}

{ print \$0 }
" 
	local zdot="${ZDOTDIR:-$HOME}" 
	local zshrc="${${:-"${zdot}/.zshrc"}:A}" 
	awk "$awk_script" "$zshrc" > "$zdot/.zshrc.new" && command cp -f "$zshrc" "$zdot/.zshrc.bck" && command mv -f "$zdot/.zshrc.new" "$zshrc"
	[[ $? -eq 0 ]] || {
		local ret=$? 
		_omz::log error "error enabling plugins."
		return $ret
	}
	if ! command zsh -n "$zdot/.zshrc"
	then
		_omz::log error "broken syntax in '"${zdot/#$HOME/\~}/.zshrc"'. Rolling back changes..."
		command mv -f "$zdot/.zshrc.bck" "$zshrc"
		return 1
	fi
	_omz::log info "plugins enabled: ${(j:, :)add_plugins}."
	[[ ! -o interactive ]] || _omz::reload
}
_omz::plugin::info () {
	if [[ -z "$1" ]]
	then
		echo "Usage: ${(j: :)${(s.::.)0#_}} <plugin>" >&2
		return 1
	fi
	local readme
	for readme in "$ZSH_CUSTOM/plugins/$1/README.md" "$ZSH/plugins/$1/README.md"
	do
		if [[ -f "$readme" ]]
		then
			if [[ ! -t 1 ]]
			then
				cat "$readme"
				return $?
			fi
			case 1 in
				(${+commands[glow]}) glow -p "$readme" ;;
				(${+commands[bat]}) bat -l md --style plain "$readme" ;;
				(${+commands[less]}) less "$readme" ;;
				(*) cat "$readme" ;;
			esac
			return $?
		fi
	done
	if [[ -d "$ZSH_CUSTOM/plugins/$1" || -d "$ZSH/plugins/$1" ]]
	then
		_omz::log error "the '$1' plugin doesn't have a README file"
	else
		_omz::log error "'$1' plugin not found"
	fi
	return 1
}
_omz::plugin::list () {
	local -a custom_plugins builtin_plugins
	if [[ "$1" == "--enabled" ]]
	then
		local plugin
		for plugin in "${plugins[@]}"
		do
			if [[ -d "${ZSH_CUSTOM}/plugins/${plugin}" ]]
			then
				custom_plugins+=("${plugin}") 
			elif [[ -d "${ZSH}/plugins/${plugin}" ]]
			then
				builtin_plugins+=("${plugin}") 
			fi
		done
	else
		custom_plugins=("$ZSH_CUSTOM"/plugins/*(-/N:t)) 
		builtin_plugins=("$ZSH"/plugins/*(-/N:t)) 
	fi
	if [[ ! -t 1 ]]
	then
		print -l ${(q-)custom_plugins} ${(q-)builtin_plugins}
		return
	fi
	if (( ${#custom_plugins} ))
	then
		print -P "%U%BCustom plugins%b%u:"
		print -lac ${(q-)custom_plugins}
	fi
	if (( ${#builtin_plugins} ))
	then
		(( ${#custom_plugins} )) && echo
		print -P "%U%BBuilt-in plugins%b%u:"
		print -lac ${(q-)builtin_plugins}
	fi
}
_omz::plugin::load () {
	if [[ -z "$1" ]]
	then
		echo "Usage: ${(j: :)${(s.::.)0#_}} <plugin> [...]" >&2
		return 1
	fi
	local plugin base has_completion=0 
	for plugin in "$@"
	do
		if [[ -d "$ZSH_CUSTOM/plugins/$plugin" ]]
		then
			base="$ZSH_CUSTOM/plugins/$plugin" 
		elif [[ -d "$ZSH/plugins/$plugin" ]]
		then
			base="$ZSH/plugins/$plugin" 
		else
			_omz::log warn "plugin '$plugin' not found"
			continue
		fi
		if [[ ! -f "$base/_$plugin" && ! -f "$base/$plugin.plugin.zsh" ]]
		then
			_omz::log warn "'$plugin' is not a valid plugin"
			continue
		elif (( ! ${fpath[(Ie)$base]} ))
		then
			fpath=("$base" $fpath) 
		fi
		local -a comp_files
		comp_files=($base/_*(N)) 
		has_completion=$(( $#comp_files > 0 )) 
		if [[ -f "$base/$plugin.plugin.zsh" ]]
		then
			source "$base/$plugin.plugin.zsh"
		fi
	done
	if (( has_completion ))
	then
		compinit -D -d "$_comp_dumpfile"
	fi
}
_omz::pr () {
	(( $# > 0 && $+functions[$0::$1] )) || {
		cat >&2 <<EOF
Usage: ${(j: :)${(s.::.)0#_}} <command> [options]

Available commands:

  clean                       Delete all PR branches (ohmyzsh/pull-*)
  test <PR_number_or_URL>     Fetch PR #NUMBER and rebase against master

EOF
		return 1
	}
	local command="$1" 
	shift
	$0::$command "$@"
}
_omz::pr::clean () {
	(
		set -e
		builtin cd -q "$ZSH"
		local fmt branches
		fmt="%(color:bold blue)%(align:18,right)%(refname:short)%(end)%(color:reset) %(color:dim bold red)%(objectname:short)%(color:reset) %(color:yellow)%(contents:subject)" 
		branches="$(command git for-each-ref --sort=-committerdate --color --format="$fmt" "refs/heads/ohmyzsh/pull-*")" 
		if [[ -z "$branches" ]]
		then
			_omz::log info "there are no Pull Request branches to remove."
			return
		fi
		echo "$branches\n"
		_omz::confirm "do you want remove these Pull Request branches? [Y/n] "
		[[ "$REPLY" != [yY$'\n'] ]] && return
		_omz::log info "removing all Oh My Zsh Pull Request branches..."
		command git branch --list 'ohmyzsh/pull-*' | while read branch
		do
			command git branch -D "$branch"
		done
	)
}
_omz::pr::test () {
	if [[ "$1" = https://* ]]
	then
		1="${1:t}" 
	fi
	if ! [[ -n "$1" && "$1" =~ ^[[:digit:]]+$ ]]
	then
		echo "Usage: ${(j: :)${(s.::.)0#_}} <PR_NUMBER_or_URL>" >&2
		return 1
	fi
	local branch
	branch=$(builtin cd -q "$ZSH"; git symbolic-ref --short HEAD)  || {
		_omz::log error "error when getting the current git branch. Aborting..."
		return 1
	}
	(
		set -e
		builtin cd -q "$ZSH"
		command git remote -v | while read remote url _
		do
			case "$url" in
				(https://github.com/ohmyzsh/ohmyzsh(|.git)) found=1 
					break ;;
				(git@github.com:ohmyzsh/ohmyzsh(|.git)) found=1 
					break ;;
			esac
		done
		(( $found )) || {
			_omz::log error "could not find the ohmyzsh git remote. Aborting..."
			return 1
		}
		_omz::log info "checking if PR #$1 has the 'testers needed' label..."
		local pr_json label label_id="MDU6TGFiZWw4NzY1NTkwNA==" 
		pr_json=$(
      curl -fsSL \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/ohmyzsh/ohmyzsh/pulls/$1"
    ) 
		if [[ $? -gt 0 || -z "$pr_json" ]]
		then
			_omz::log error "error when trying to fetch PR #$1 from GitHub."
			return 1
		fi
		if (( $+commands[jq] ))
		then
			label="$(command jq ".labels.[] | select(.node_id == \"$label_id\")" <<< "$pr_json")" 
		else
			label="$(command grep "\"$label_id\"" <<< "$pr_json" 2>/dev/null)" 
		fi
		if [[ -z "$label" ]]
		then
			_omz::log warn "PR #$1 does not have the 'testers needed' label. This means that the PR"
			_omz::log warn "has not been reviewed by a maintainer and may contain malicious code."
			_omz::log prompt "Do you want to continue testing it? [yes/N] "
			builtin read -r
			if [[ "${REPLY:l}" != yes ]]
			then
				_omz::log error "PR test canceled. Please ask a maintainer to review and label the PR."
				return 1
			else
				_omz::log warn "Continuing to check out and test PR #$1. Be careful!"
			fi
		fi
		_omz::log info "fetching PR #$1 to ohmyzsh/pull-$1..."
		command git fetch -f "$remote" refs/pull/$1/head:ohmyzsh/pull-$1 || {
			_omz::log error "error when trying to fetch PR #$1."
			return 1
		}
		_omz::log info "rebasing PR #$1..."
		local ret gpgsign
		{
			gpgsign=$(command git config --local commit.gpgsign 2>/dev/null)  || ret=$? 
			[[ $ret -ne 129 ]] || gpgsign=$(command git config commit.gpgsign 2>/dev/null) 
			command git config commit.gpgsign false
			command git rebase master ohmyzsh/pull-$1 || {
				command git rebase --abort &> /dev/null
				_omz::log warn "could not rebase PR #$1 on top of master."
				_omz::log warn "you might not see the latest stable changes."
				_omz::log info "run \`zsh\` to test the changes."
				return 1
			}
		} always {
			case "$gpgsign" in
				("") command git config --unset commit.gpgsign ;;
				(*) command git config commit.gpgsign "$gpgsign" ;;
			esac
		}
		_omz::log info "fetch of PR #${1} successful."
	)
	[[ $? -eq 0 ]] || return 1
	_omz::log info "running \`zsh\` to test the changes. Run \`exit\` to go back."
	command zsh -l
	_omz::confirm "do you want to go back to the previous branch? [Y/n] "
	[[ "$REPLY" != [yY$'\n'] ]] && return
	(
		set -e
		builtin cd -q "$ZSH"
		command git checkout "$branch" -- || {
			_omz::log error "could not go back to the previous branch ('$branch')."
			return 1
		}
	)
}
_omz::reload () {
	command rm -f $_comp_dumpfile $ZSH_COMPDUMP
	local zsh="${ZSH_ARGZERO:-${functrace[-1]%:*}}" 
	[[ "$zsh" = -* || -o login ]] && exec -l "${zsh#-}" || exec "$zsh"
}
_omz::shop () {
	local shop_url="https://commitgoods.com/collections/oh-my-zsh" 
	_omz::log info "Opening Oh My Zsh shop in your browser..."
	_omz::log info "$shop_url"
	open_command "$shop_url"
}
_omz::theme () {
	(( $# > 0 && $+functions[$0::$1] )) || {
		cat >&2 <<EOF
Usage: ${(j: :)${(s.::.)0#_}} <command> [options]

Available commands:

  list            List all available Oh My Zsh themes
  set <theme>     Set a theme in your .zshrc file
  use <theme>     Load a theme

EOF
		return 1
	}
	local command="$1" 
	shift
	$0::$command "$@"
}
_omz::theme::list () {
	local -a custom_themes builtin_themes
	custom_themes=("$ZSH_CUSTOM"/**/*.zsh-theme(-.N:r:gs:"$ZSH_CUSTOM"/themes/:::gs:"$ZSH_CUSTOM"/:::)) 
	builtin_themes=("$ZSH"/themes/*.zsh-theme(-.N:t:r)) 
	if [[ ! -t 1 ]]
	then
		print -l ${(q-)custom_themes} ${(q-)builtin_themes}
		return
	fi
	if [[ -n "$ZSH_THEME" ]]
	then
		print -Pn "%U%BCurrent theme%b%u: "
		[[ $ZSH_THEME = random ]] && echo "$RANDOM_THEME (via random)" || echo "$ZSH_THEME"
		echo
	fi
	if (( ${#custom_themes} ))
	then
		print -P "%U%BCustom themes%b%u:"
		print -lac ${(q-)custom_themes}
		echo
	fi
	print -P "%U%BBuilt-in themes%b%u:"
	print -lac ${(q-)builtin_themes}
}
_omz::theme::set () {
	if [[ -z "$1" ]]
	then
		echo "Usage: ${(j: :)${(s.::.)0#_}} <theme>" >&2
		return 1
	fi
	if [[ ! -f "$ZSH_CUSTOM/$1.zsh-theme" ]] && [[ ! -f "$ZSH_CUSTOM/themes/$1.zsh-theme" ]] && [[ ! -f "$ZSH/themes/$1.zsh-theme" ]]
	then
		_omz::log error "%B$1%b theme not found"
		return 1
	fi
	local awk_script='
!set && /^[ \t]*ZSH_THEME=[^#]+.*$/ {
  set=1
  sub(/^[ \t]*ZSH_THEME=[^#]+.*$/, "ZSH_THEME=\"'$1'\" # set by `omz`")
  print $0
  next
}

{ print $0 }

END {
  # If no ZSH_THEME= line was found, return an error
  if (!set) exit 1
}
' 
	local zdot="${ZDOTDIR:-$HOME}" 
	local zshrc="${${:-"${zdot}/.zshrc"}:A}" 
	awk "$awk_script" "$zshrc" > "$zdot/.zshrc.new" || {
		cat <<EOF
ZSH_THEME="$1" # set by \`omz\`

EOF
		cat "$zdot/.zshrc"
	} > "$zdot/.zshrc.new" && command cp -f "$zshrc" "$zdot/.zshrc.bck" && command mv -f "$zdot/.zshrc.new" "$zshrc"
	[[ $? -eq 0 ]] || {
		local ret=$? 
		_omz::log error "error setting theme."
		return $ret
	}
	if ! command zsh -n "$zdot/.zshrc"
	then
		_omz::log error "broken syntax in '"${zdot/#$HOME/\~}/.zshrc"'. Rolling back changes..."
		command mv -f "$zdot/.zshrc.bck" "$zshrc"
		return 1
	fi
	_omz::log info "'$1' theme set correctly."
	[[ ! -o interactive ]] || _omz::reload
}
_omz::theme::use () {
	if [[ -z "$1" ]]
	then
		echo "Usage: ${(j: :)${(s.::.)0#_}} <theme>" >&2
		return 1
	fi
	if [[ -f "$ZSH_CUSTOM/$1.zsh-theme" ]]
	then
		source "$ZSH_CUSTOM/$1.zsh-theme"
	elif [[ -f "$ZSH_CUSTOM/themes/$1.zsh-theme" ]]
	then
		source "$ZSH_CUSTOM/themes/$1.zsh-theme"
	elif [[ -f "$ZSH/themes/$1.zsh-theme" ]]
	then
		source "$ZSH/themes/$1.zsh-theme"
	else
		_omz::log error "%B$1%b theme not found"
		return 1
	fi
	ZSH_THEME="$1" 
	[[ $1 = random ]] || unset RANDOM_THEME
}
_omz::update () {
	(( $+commands[git] )) || {
		_omz::log error "git is not installed. Aborting..."
		return 1
	}
	[[ "$1" != --unattended ]] || {
		_omz::log error "the \`\e[2m--unattended\e[0m\` flag is no longer supported, use the \`\e[2mupgrade.sh\e[0m\` script instead."
		_omz::log error "for more information see https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-update-oh-my-zsh"
		return 1
	}
	local last_commit=$(builtin cd -q "$ZSH"; git rev-parse HEAD 2>/dev/null) 
	[[ $? -eq 0 ]] || {
		_omz::log error "\`$ZSH\` is not a git directory. Aborting..."
		return 1
	}
	zstyle -s ':omz:update' verbose verbose_mode || verbose_mode=default 
	ZSH="$ZSH" command zsh -f "$ZSH/tools/upgrade.sh" -i -v $verbose_mode || return $?
	zmodload zsh/datetime
	echo "LAST_EPOCH=$(( EPOCHSECONDS / 60 / 60 / 24 ))" >| "${ZSH_CACHE_DIR}/.zsh-update"
	command rm -rf "$ZSH/log/update.lock"
	if [[ "$(builtin cd -q "$ZSH"; git rev-parse HEAD)" != "$last_commit" ]]
	then
		local zsh="${ZSH_ARGZERO:-${functrace[-1]%:*}}" 
		[[ "$zsh" = -* || -o login ]] && exec -l "${zsh#-}" || exec "$zsh"
	fi
}
_omz::version () {
	(
		builtin cd -q "$ZSH"
		local version
		version=$(command git describe --tags HEAD 2>/dev/null)  || version=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)  || version=$(command git name-rev --no-undefined --name-only --exclude="remotes/*" HEAD 2>/dev/null)  || version="<detached>" 
		local commit=$(command git rev-parse --short HEAD 2>/dev/null) 
		printf "%s (%s)\n" "$version" "$commit"
	)
}
_omz_async_callback () {
	emulate -L zsh
	local fd=$1 
	local err=$2 
	if [[ -z "$err" || "$err" == "hup" ]]
	then
		local handler="${(k)_OMZ_ASYNC_FDS[(r)$fd]}" 
		local old_output="${_OMZ_ASYNC_OUTPUT[$handler]}" 
		IFS= read -r -u $fd -d '' "_OMZ_ASYNC_OUTPUT[$handler]"
		if [[ "$old_output" != "${_OMZ_ASYNC_OUTPUT[$handler]}" ]]
		then
			zle .reset-prompt
			zle -R
		fi
		exec {fd}<&-
	fi
	zle -F "$fd"
	_OMZ_ASYNC_FDS[$handler]=-1 
	_OMZ_ASYNC_PIDS[$handler]=-1 
}
_omz_async_request () {
	setopt localoptions noksharrays unset
	local -i ret=$? 
	typeset -gA _OMZ_ASYNC_FDS _OMZ_ASYNC_PIDS _OMZ_ASYNC_OUTPUT
	local handler
	for handler in ${_omz_async_functions}
	do
		(( ${+functions[$handler]} )) || continue
		local fd=${_OMZ_ASYNC_FDS[$handler]:--1} 
		local pid=${_OMZ_ASYNC_PIDS[$handler]:--1} 
		if (( fd != -1 && pid != -1 )) && {
				true <&$fd
			} 2> /dev/null
		then
			exec {fd}<&-
			zle -F $fd
			if [[ -o MONITOR ]]
			then
				kill -TERM -$pid 2> /dev/null
			else
				kill -TERM $pid 2> /dev/null
			fi
		fi
		_OMZ_ASYNC_FDS[$handler]=-1 
		_OMZ_ASYNC_PIDS[$handler]=-1 
		exec {fd}< <(
      # Tell parent process our PID
      builtin echo ${sysparams[pid]}
      # Set exit code for the handler if used
      () { return $ret }
      # Run the async function handler
      $handler
    )
		_OMZ_ASYNC_FDS[$handler]=$fd 
		is-at-least 5.8 || command true
		read -u $fd "_OMZ_ASYNC_PIDS[$handler]"
		zle -F "$fd" _omz_async_callback
	done
}
_omz_diag_dump_check_core_commands () {
	builtin echo "Core command check:"
	local redefined name builtins externals reserved_words
	redefined=() 
	reserved_words=(do done esac then elif else fi for case if while function repeat time until select coproc nocorrect foreach end '!' '[[' '{' '}') 
	builtins=(alias autoload bg bindkey break builtin bye cd chdir command comparguments compcall compctl compdescribe compfiles compgroups compquote comptags comptry compvalues continue dirs disable disown echo echotc echoti emulate enable eval exec exit false fc fg functions getln getopts hash jobs kill let limit log logout noglob popd print printf pushd pushln pwd r read rehash return sched set setopt shift source suspend test times trap true ttyctl type ulimit umask unalias unfunction unhash unlimit unset unsetopt vared wait whence where which zcompile zle zmodload zparseopts zregexparse zstyle) 
	if is-at-least 5.1
	then
		reserved_word+=(declare export integer float local readonly typeset) 
	else
		builtins+=(declare export integer float local readonly typeset) 
	fi
	builtins_fatal=(builtin command local) 
	externals=(zsh) 
	for name in $reserved_words
	do
		if [[ $(builtin whence -w $name) != "$name: reserved" ]]
		then
			builtin echo "reserved word '$name' has been redefined"
			builtin which $name
			redefined+=$name 
		fi
	done
	for name in $builtins
	do
		if [[ $(builtin whence -w $name) != "$name: builtin" ]]
		then
			builtin echo "builtin '$name' has been redefined"
			builtin which $name
			redefined+=$name 
		fi
	done
	for name in $externals
	do
		if [[ $(builtin whence -w $name) != "$name: command" ]]
		then
			builtin echo "command '$name' has been redefined"
			builtin which $name
			redefined+=$name 
		fi
	done
	if [[ -n "$redefined" ]]
	then
		builtin echo "SOME CORE COMMANDS HAVE BEEN REDEFINED: $redefined"
	else
		builtin echo "All core commands are defined normally"
	fi
}
_omz_diag_dump_echo_file_w_header () {
	local file=$1 
	if [[ -f $file || -h $file ]]
	then
		builtin echo "========== $file =========="
		if [[ -h $file ]]
		then
			builtin echo "==========    ( => ${file:A} )   =========="
		fi
		command cat $file
		builtin echo "========== end $file =========="
		builtin echo
	elif [[ -d $file ]]
	then
		builtin echo "File '$file' is a directory"
	elif [[ ! -e $file ]]
	then
		builtin echo "File '$file' does not exist"
	else
		command ls -lad "$file"
	fi
}
_omz_diag_dump_one_big_text () {
	local program programs progfile md5
	builtin echo oh-my-zsh diagnostic dump
	builtin echo
	builtin echo $outfile
	builtin echo
	command date
	command uname -a
	builtin echo OSTYPE=$OSTYPE
	builtin echo ZSH_VERSION=$ZSH_VERSION
	builtin echo User: $USERNAME
	builtin echo umask: $(umask)
	builtin echo
	_omz_diag_dump_os_specific_version
	builtin echo
	programs=(sh zsh ksh bash sed cat grep ls find git posh) 
	local progfile="" extra_str="" sha_str="" 
	for program in $programs
	do
		extra_str="" sha_str="" 
		progfile=$(builtin which $program) 
		if [[ $? == 0 ]]
		then
			if [[ -e $progfile ]]
			then
				if builtin whence shasum &> /dev/null
				then
					sha_str=($(command shasum $progfile)) 
					sha_str=$sha_str[1] 
					extra_str+=" SHA $sha_str" 
				fi
				if [[ -h "$progfile" ]]
				then
					extra_str+=" ( -> ${progfile:A} )" 
				fi
			fi
			builtin printf '%-9s %-20s %s\n' "$program is" "$progfile" "$extra_str"
		else
			builtin echo "$program: not found"
		fi
	done
	builtin echo
	builtin echo Command Versions:
	builtin echo "zsh: $(zsh --version)"
	builtin echo "this zsh session: $ZSH_VERSION"
	builtin echo "bash: $(bash --version | command grep bash)"
	builtin echo "git: $(git --version)"
	builtin echo "grep: $(grep --version)"
	builtin echo
	_omz_diag_dump_check_core_commands || return 1
	builtin echo
	builtin echo Process state:
	builtin echo pwd: $PWD
	if builtin whence pstree &> /dev/null
	then
		builtin echo Process tree for this shell:
		pstree -p $$
	else
		ps -fT
	fi
	builtin set | command grep -a '^\(ZSH\|plugins\|TERM\|LC_\|LANG\|precmd\|chpwd\|preexec\|FPATH\|TTY\|DISPLAY\|PATH\)\|OMZ'
	builtin echo
	builtin echo Exported:
	builtin echo $(builtin export | command sed 's/=.*//')
	builtin echo
	builtin echo Locale:
	command locale
	builtin echo
	builtin echo Zsh configuration:
	builtin echo setopt: $(builtin setopt)
	builtin echo
	builtin echo zstyle:
	builtin zstyle
	builtin echo
	builtin echo 'compaudit output:'
	compaudit
	builtin echo
	builtin echo '$fpath directories:'
	command ls -lad $fpath
	builtin echo
	builtin echo oh-my-zsh installation:
	command ls -ld ~/.z*
	command ls -ld ~/.oh*
	builtin echo
	builtin echo oh-my-zsh git state:
	(
		builtin cd $ZSH && builtin echo "HEAD: $(git rev-parse HEAD)" && git remote -v && git status | command grep "[^[:space:]]"
	)
	if [[ $verbose -ge 1 ]]
	then
		(
			builtin cd $ZSH && git reflog --date=default | command grep pull
		)
	fi
	builtin echo
	if [[ -e $ZSH_CUSTOM ]]
	then
		local custom_dir=$ZSH_CUSTOM 
		if [[ -h $custom_dir ]]
		then
			custom_dir=$(builtin cd $custom_dir && pwd -P) 
		fi
		builtin echo "oh-my-zsh custom dir:"
		builtin echo "   $ZSH_CUSTOM ($custom_dir)"
		(
			builtin cd ${custom_dir:h} && command find ${custom_dir:t} -name .git -prune -o -print
		)
		builtin echo
	fi
	if [[ $verbose -ge 1 ]]
	then
		builtin echo "bindkey:"
		builtin bindkey
		builtin echo
		builtin echo "infocmp:"
		command infocmp -L
		builtin echo
	fi
	local zdotdir=${ZDOTDIR:-$HOME} 
	builtin echo "Zsh configuration files:"
	local cfgfile cfgfiles
	cfgfiles=(/etc/zshenv /etc/zprofile /etc/zshrc /etc/zlogin /etc/zlogout $zdotdir/.zshenv $zdotdir/.zprofile $zdotdir/.zshrc $zdotdir/.zlogin $zdotdir/.zlogout ~/.zsh.pre-oh-my-zsh /etc/bashrc /etc/profile ~/.bashrc ~/.profile ~/.bash_profile ~/.bash_logout) 
	command ls -lad $cfgfiles 2>&1
	builtin echo
	if [[ $verbose -ge 1 ]]
	then
		for cfgfile in $cfgfiles
		do
			_omz_diag_dump_echo_file_w_header $cfgfile
		done
	fi
	builtin echo
	builtin echo "Zsh compdump files:"
	local dumpfile dumpfiles
	command ls -lad $zdotdir/.zcompdump*
	dumpfiles=($zdotdir/.zcompdump*(N)) 
	if [[ $verbose -ge 2 ]]
	then
		for dumpfile in $dumpfiles
		do
			_omz_diag_dump_echo_file_w_header $dumpfile
		done
	fi
}
_omz_diag_dump_os_specific_version () {
	local osname osver version_file version_files
	case "$OSTYPE" in
		(darwin*) osname=$(command sw_vers -productName) 
			osver=$(command sw_vers -productVersion) 
			builtin echo "OS Version: $osname $osver build $(sw_vers -buildVersion)" ;;
		(cygwin) command systeminfo | command head -n 4 | command tail -n 2 ;;
	esac
	if builtin which lsb_release > /dev/null
	then
		builtin echo "OS Release: $(command lsb_release -s -d)"
	fi
	version_files=(/etc/*-release(N) /etc/*-version(N) /etc/*_version(N)) 
	for version_file in $version_files
	do
		builtin echo "$version_file:"
		command cat "$version_file"
		builtin echo
	done
}
_omz_git_prompt_info () {
	if ! __git_prompt_git rev-parse --git-dir &> /dev/null || [[ "$(__git_prompt_git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]
	then
		return 0
	fi
	local ref
	ref=$(__git_prompt_git symbolic-ref --short HEAD 2> /dev/null)  || ref=$(__git_prompt_git describe --tags --exact-match HEAD 2> /dev/null)  || ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  || return 0
	local upstream
	if (( ${+ZSH_THEME_GIT_SHOW_UPSTREAM} ))
	then
		upstream=$(__git_prompt_git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null)  && upstream=" -> ${upstream}" 
	fi
	echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ref//\%/%%}${upstream//\%/%%}$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}
_omz_git_prompt_status () {
	[[ "$(__git_prompt_git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]] && return
	local -A prefix_constant_map
	prefix_constant_map=('\?\? ' 'UNTRACKED' 'A  ' 'ADDED' 'M  ' 'MODIFIED' 'MM ' 'MODIFIED' ' M ' 'MODIFIED' 'AM ' 'MODIFIED' ' T ' 'MODIFIED' 'R  ' 'RENAMED' ' D ' 'DELETED' 'D  ' 'DELETED' 'UU ' 'UNMERGED' 'ahead' 'AHEAD' 'behind' 'BEHIND' 'diverged' 'DIVERGED' 'stashed' 'STASHED') 
	local -A constant_prompt_map
	constant_prompt_map=('UNTRACKED' "$ZSH_THEME_GIT_PROMPT_UNTRACKED" 'ADDED' "$ZSH_THEME_GIT_PROMPT_ADDED" 'MODIFIED' "$ZSH_THEME_GIT_PROMPT_MODIFIED" 'RENAMED' "$ZSH_THEME_GIT_PROMPT_RENAMED" 'DELETED' "$ZSH_THEME_GIT_PROMPT_DELETED" 'UNMERGED' "$ZSH_THEME_GIT_PROMPT_UNMERGED" 'AHEAD' "$ZSH_THEME_GIT_PROMPT_AHEAD" 'BEHIND' "$ZSH_THEME_GIT_PROMPT_BEHIND" 'DIVERGED' "$ZSH_THEME_GIT_PROMPT_DIVERGED" 'STASHED' "$ZSH_THEME_GIT_PROMPT_STASHED") 
	local status_constants
	status_constants=(UNTRACKED ADDED MODIFIED RENAMED DELETED STASHED UNMERGED AHEAD BEHIND DIVERGED) 
	local status_text
	status_text="$(__git_prompt_git status --porcelain -b 2> /dev/null)" 
	if [[ $? -eq 128 ]]
	then
		return 1
	fi
	local -A statuses_seen
	if __git_prompt_git rev-parse --verify refs/stash &> /dev/null
	then
		statuses_seen[STASHED]=1 
	fi
	local status_lines
	status_lines=("${(@f)${status_text}}") 
	if [[ "$status_lines[1]" =~ "^## [^ ]+ \[(.*)\]" ]]
	then
		local branch_statuses
		branch_statuses=("${(@s/,/)match}") 
		for branch_status in $branch_statuses
		do
			if [[ ! $branch_status =~ "(behind|diverged|ahead) ([0-9]+)?" ]]
			then
				continue
			fi
			local last_parsed_status=$prefix_constant_map[$match[1]] 
			statuses_seen[$last_parsed_status]=$match[2] 
		done
	fi
	for status_prefix in "${(@k)prefix_constant_map}"
	do
		local status_constant="${prefix_constant_map[$status_prefix]}" 
		local status_regex=$'(^|\n)'"$status_prefix" 
		if [[ "$status_text" =~ $status_regex ]]
		then
			statuses_seen[$status_constant]=1 
		fi
	done
	local status_prompt
	for status_constant in $status_constants
	do
		if (( ${+statuses_seen[$status_constant]} ))
		then
			local next_display=$constant_prompt_map[$status_constant] 
			status_prompt="$next_display$status_prompt" 
		fi
	done
	echo $status_prompt
}
_omz_register_handler () {
	setopt localoptions noksharrays unset
	typeset -ga _omz_async_functions
	if [[ -z "$1" ]] || (( ! ${+functions[$1]} )) || (( ${_omz_async_functions[(Ie)$1]} ))
	then
		return
	fi
	_omz_async_functions+=("$1") 
	if (( ! ${precmd_functions[(Ie)_omz_async_request]} )) && (( ${+functions[_omz_async_request]}))
	then
		autoload -Uz add-zsh-hook
		add-zsh-hook precmd _omz_async_request
	fi
}
_omz_source () {
	local context filepath="$1" 
	case "$filepath" in
		(lib/*) context="lib:${filepath:t:r}"  ;;
		(plugins/*) context="plugins:${filepath:h:t}"  ;;
	esac
	local disable_aliases=0 
	zstyle -T ":omz:${context}" aliases || disable_aliases=1 
	local -A aliases_pre galiases_pre
	if (( disable_aliases ))
	then
		aliases_pre=("${(@kv)aliases}") 
		galiases_pre=("${(@kv)galiases}") 
	fi
	if [[ -f "$ZSH_CUSTOM/$filepath" ]]
	then
		source "$ZSH_CUSTOM/$filepath"
	elif [[ -f "$ZSH/$filepath" ]]
	then
		source "$ZSH/$filepath"
	fi
	if (( disable_aliases ))
	then
		if (( #aliases_pre ))
		then
			aliases=("${(@kv)aliases_pre}") 
		else
			(( #aliases )) && unalias "${(@k)aliases}"
		fi
		if (( #galiases_pre ))
		then
			galiases=("${(@kv)galiases_pre}") 
		else
			(( #galiases )) && unalias "${(@k)galiases}"
		fi
	fi
}
_open () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_openstack () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_opkg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_options () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_options_set () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_options_unset () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_opustools () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_osascript () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_osc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_other_accounts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_otool () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pack () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pandoc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_parameter () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_parameters () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_paste () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_patch () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_patchutils () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_path_commands () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_path_files () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pax () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pbcopy () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pbm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pbuilder () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pdf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pdftk () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_perf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_perforce () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_perl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_perl_basepods () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_perl_modules () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_perldoc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pfctl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pfexec () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pgids () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pgrep () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_php () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_physical_volumes () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pick_variant () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_picocom () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pidof () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pids () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pine () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ping () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pip () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_piuparts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pkg-config () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pkg5 () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pkg_instance () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pkgadd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pkgin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pkginfo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pkgrm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pkgtool () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_plutil () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pmap () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pon () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_portaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_portlint () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_portmaster () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ports () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_portsnap () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_postfix () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_postgresql () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_postscript () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_powerd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_precommand () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_prefix () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_print () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_printenv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_printers () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_process_names () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_procstat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_prompt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_prove () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_prstat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ps () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ps1234 () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pscp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pspdf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_psutils () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ptree () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ptx () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_putclip () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pwgen () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_pydoc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_python () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_python_modules () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_qdbus () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_qemu () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_qiv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_qtplay () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_quilt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rake () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ranlib () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rar () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rcctl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rclone () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rcs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rdesktop () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_read () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_read_comp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_readelf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_readlink () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_readshortcut () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rebootin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_redirect () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_regex_arguments () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_regex_words () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_remote_files () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_renice () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_reprepro () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_requested () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_retrieve_cache () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_retrieve_mac_apps () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ri () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rlogin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rmdir () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_route () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_routing_domains () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_routing_tables () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rpm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rrdtool () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rsync () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_rubber () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ruby () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_run-help () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_runit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_samba () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_savecore () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_say () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sbuild () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sc_usage () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sccs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sched () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_schedtool () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_schroot () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_scl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_scons () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_screen () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_script () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_scselect () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_scutil () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_seafile () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sed () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_selinux_contexts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_selinux_roles () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_selinux_types () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_selinux_users () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sep_parts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_seq () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sequence () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_service () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_services () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_set () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_set_command () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_setfacl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_setopt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_setpriv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_setsid () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_setup () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_setxkbmap () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_shasum () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_showmount () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_shred () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_shuf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_shutdown () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_signals () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_signify () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sisu () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_slabtop () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_slrn () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_smartmontools () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_smit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_snoop () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_socket () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sockstat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_softwareupdate () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sort () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_source () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_spamassassin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_split () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sqlite () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sqsh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ss () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ssh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ssh_hosts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sshfs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_stat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_stdbuf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_stgit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_store_cache () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_stow () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_strace () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_strftime () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_strings () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_strip () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_stty () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_su () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sub_commands () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sublimetext () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_subscript () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_subversion () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sudo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_suffix_alias_files () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_surfraw () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_svcadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_svccfg () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_svcprop () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_svcs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_svcs_fmri () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_svn-buildpackage () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sw_vers () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_swaks () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_swanctl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_swift () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sys_calls () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sysclean () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sysctl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sysmerge () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_syspatch () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sysrc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sysstat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_systat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_system_profiler () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_sysupgrade () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tac () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tags () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tail () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tar () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tar_archive () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tardy () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tcpdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tcpsys () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tcptraceroute () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tee () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_telnet () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_terminals () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tex () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_texi () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_texinfo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tidy () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tiff () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tilde () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tilde_files () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_time_zone () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_timeout () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tla () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tload () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tmux () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_todo.sh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_toilet () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_toolchain-source () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_top () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_topgit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_totd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_touch () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tpb () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tput () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tracepath () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_transmission () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_trap () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_trash () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tree () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_truncate () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_truss () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tty () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ttyctl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ttys () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_tune2fs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_twidge () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_twisted () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_typeset () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ulimit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_uml () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_umountable () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_unace () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_uname () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_unexpand () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_unhash () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_uniq () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_unison () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_units () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_unshare () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_update-alternatives () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_update-rc.d () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_uptime () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_urls () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_urpmi () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_urxvt () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_usbconfig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_uscan () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_user_admin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_user_at_host () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_user_expand () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_user_math_func () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_users () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_users_on () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_valgrind () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_value () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_values () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vared () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vars () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vcs_info () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vcs_info_hooks () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vi () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vim () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vim-addons () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_visudo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vmctl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vmstat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vnc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_volume_groups () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vorbis () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vpnc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_vserver () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_w () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_w3m () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wait () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wajig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wakeup_capable_devices () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wanna-build () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wanted () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_watch () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_watch-snoop () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_webbrowser () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wget () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_whereis () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_which () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_who () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_whois () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_widgets () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wiggle () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wipefs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_wpa_cli () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_arguments () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_borderwidth () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_color () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_colormapid () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_cursor () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_display () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_extension () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_font () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_geometry () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_keysym () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_locale () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_modifier () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_name () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_resource () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_selection_timeout () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_title () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_utils () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_visual () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_x_window () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xargs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xauth () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xautolock () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xclip () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xcode-select () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xdvi () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xfig () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xft_fonts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xinput () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xloadimage () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xmlsoft () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xmlstarlet () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xmms2 () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xmodmap () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xournal () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xpdf () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xrandr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xscreensaver () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xset () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xt_arguments () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xt_session_id () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xterm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xwit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xxd () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_xz () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_yafc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_yast () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_yodl () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_yp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_yum () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zargs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zattr () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zcalc () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zcalc_line () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zcat () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zcompile () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zeal () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zed () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zfs () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zfs_dataset () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zfs_pool () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zftp () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zip () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zle () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zlogin () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zmodload () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zmv () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zoneadm () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zones () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zparseopts () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zpty () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zsh () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zsh-mime-handler () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zsh_autosuggest_accept () {
	local -i retval max_cursor_pos=$#BUFFER 
	if [[ "$KEYMAP" = "vicmd" ]]
	then
		max_cursor_pos=$((max_cursor_pos - 1)) 
	fi
	if (( $CURSOR != $max_cursor_pos || !$#POSTDISPLAY ))
	then
		_zsh_autosuggest_invoke_original_widget $@
		return
	fi
	BUFFER="$BUFFER$POSTDISPLAY" 
	unset POSTDISPLAY
	_zsh_autosuggest_invoke_original_widget $@
	retval=$? 
	if [[ "$KEYMAP" = "vicmd" ]]
	then
		CURSOR=$(($#BUFFER - 1)) 
	else
		CURSOR=$#BUFFER 
	fi
	return $retval
}
_zsh_autosuggest_async_request () {
	zmodload zsh/system 2> /dev/null
	typeset -g _ZSH_AUTOSUGGEST_ASYNC_FD _ZSH_AUTOSUGGEST_CHILD_PID
	if [[ -n "$_ZSH_AUTOSUGGEST_ASYNC_FD" ]] && {
			true <&$_ZSH_AUTOSUGGEST_ASYNC_FD
		} 2> /dev/null
	then
		exec {_ZSH_AUTOSUGGEST_ASYNC_FD}<&-
		zle -F $_ZSH_AUTOSUGGEST_ASYNC_FD
		if [[ -n "$_ZSH_AUTOSUGGEST_CHILD_PID" ]]
		then
			if [[ -o MONITOR ]]
			then
				kill -TERM -$_ZSH_AUTOSUGGEST_CHILD_PID 2> /dev/null
			else
				kill -TERM $_ZSH_AUTOSUGGEST_CHILD_PID 2> /dev/null
			fi
		fi
	fi
	exec {_ZSH_AUTOSUGGEST_ASYNC_FD}< <(
		# Tell parent process our pid
		echo $sysparams[pid]

		# Fetch and print the suggestion
		local suggestion
		_zsh_autosuggest_fetch_suggestion "$1"
		echo -nE "$suggestion"
	)
	autoload -Uz is-at-least
	is-at-least 5.8 || command true
	read _ZSH_AUTOSUGGEST_CHILD_PID <&$_ZSH_AUTOSUGGEST_ASYNC_FD
	zle -F "$_ZSH_AUTOSUGGEST_ASYNC_FD" _zsh_autosuggest_async_response
}
_zsh_autosuggest_async_response () {
	emulate -L zsh
	local suggestion
	if [[ -z "$2" || "$2" == "hup" ]]
	then
		IFS='' read -rd '' -u $1 suggestion
		zle autosuggest-suggest -- "$suggestion"
		exec {1}<&-
	fi
	zle -F "$1"
}
_zsh_autosuggest_bind_widget () {
	typeset -gA _ZSH_AUTOSUGGEST_BIND_COUNTS
	local widget=$1 
	local autosuggest_action=$2 
	local prefix=$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX 
	local -i bind_count
	case $widgets[$widget] in
		(user:_zsh_autosuggest_(bound|orig)_*) bind_count=$((_ZSH_AUTOSUGGEST_BIND_COUNTS[$widget]))  ;;
		(user:*) _zsh_autosuggest_incr_bind_count $widget
			zle -N $prefix$bind_count-$widget ${widgets[$widget]#*:} ;;
		(builtin) _zsh_autosuggest_incr_bind_count $widget
			eval "_zsh_autosuggest_orig_${(q)widget}() { zle .${(q)widget} }"
			zle -N $prefix$bind_count-$widget _zsh_autosuggest_orig_$widget ;;
		(completion:*) _zsh_autosuggest_incr_bind_count $widget
			eval "zle -C $prefix$bind_count-${(q)widget} ${${(s.:.)widgets[$widget]}[2,3]}" ;;
	esac
	eval "_zsh_autosuggest_bound_${bind_count}_${(q)widget}() {
		_zsh_autosuggest_widget_$autosuggest_action $prefix$bind_count-${(q)widget} \$@
	}"
	zle -N -- $widget _zsh_autosuggest_bound_${bind_count}_$widget
}
_zsh_autosuggest_bind_widgets () {
	emulate -L zsh
	local widget
	local ignore_widgets
	ignore_widgets=(.\* _\* ${_ZSH_AUTOSUGGEST_BUILTIN_ACTIONS/#/autosuggest-} $ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX\* $ZSH_AUTOSUGGEST_IGNORE_WIDGETS) 
	for widget in ${${(f)"$(builtin zle -la)"}:#${(j:|:)~ignore_widgets}}
	do
		if [[ -n ${ZSH_AUTOSUGGEST_CLEAR_WIDGETS[(r)$widget]} ]]
		then
			_zsh_autosuggest_bind_widget $widget clear
		elif [[ -n ${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[(r)$widget]} ]]
		then
			_zsh_autosuggest_bind_widget $widget accept
		elif [[ -n ${ZSH_AUTOSUGGEST_EXECUTE_WIDGETS[(r)$widget]} ]]
		then
			_zsh_autosuggest_bind_widget $widget execute
		elif [[ -n ${ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS[(r)$widget]} ]]
		then
			_zsh_autosuggest_bind_widget $widget partial_accept
		else
			_zsh_autosuggest_bind_widget $widget modify
		fi
	done
}
_zsh_autosuggest_capture_completion_async () {
	_zsh_autosuggest_capture_setup
	zmodload zsh/parameter 2> /dev/null || return
	autoload +X _complete
	functions[_original_complete]=$functions[_complete] 
	_complete () {
		unset 'compstate[vared]'
		_original_complete "$@"
	}
	vared 1
}
_zsh_autosuggest_capture_completion_sync () {
	_zsh_autosuggest_capture_setup
	zle autosuggest-capture-completion
}
_zsh_autosuggest_capture_completion_widget () {
	local -a +h comppostfuncs
	comppostfuncs=(_zsh_autosuggest_capture_postcompletion) 
	CURSOR=$#BUFFER 
	zle -- ${(k)widgets[(r)completion:.complete-word:_main_complete]}
	if is-at-least 5.0.3
	then
		stty -onlcr -ocrnl -F /dev/tty
	fi
	echo -nE - $'\0'$BUFFER$'\0'
}
_zsh_autosuggest_capture_postcompletion () {
	compstate[insert]=1 
	unset 'compstate[list]'
}
_zsh_autosuggest_capture_setup () {
	if ! is-at-least 5.4
	then
		zshexit () {
			kill -KILL $$ 2>&- || command kill -KILL $$
			sleep 1
		}
	fi
	zstyle ':completion:*' matcher-list ''
	zstyle ':completion:*' path-completion false
	zstyle ':completion:*' max-errors 0 not-numeric
	bindkey '^I' autosuggest-capture-completion
}
_zsh_autosuggest_clear () {
	unset POSTDISPLAY
	_zsh_autosuggest_invoke_original_widget $@
}
_zsh_autosuggest_disable () {
	typeset -g _ZSH_AUTOSUGGEST_DISABLED
	_zsh_autosuggest_clear
}
_zsh_autosuggest_enable () {
	unset _ZSH_AUTOSUGGEST_DISABLED
	if (( $#BUFFER ))
	then
		_zsh_autosuggest_fetch
	fi
}
_zsh_autosuggest_escape_command () {
	setopt localoptions EXTENDED_GLOB
	echo -E "${1//(#m)[\"\'\\()\[\]|*?~]/\\$MATCH}"
}
_zsh_autosuggest_execute () {
	BUFFER="$BUFFER$POSTDISPLAY" 
	unset POSTDISPLAY
	_zsh_autosuggest_invoke_original_widget "accept-line"
}
_zsh_autosuggest_fetch () {
	if (( ${+ZSH_AUTOSUGGEST_USE_ASYNC} ))
	then
		_zsh_autosuggest_async_request "$BUFFER"
	else
		local suggestion
		_zsh_autosuggest_fetch_suggestion "$BUFFER"
		_zsh_autosuggest_suggest "$suggestion"
	fi
}
_zsh_autosuggest_fetch_suggestion () {
	typeset -g suggestion
	local -a strategies
	local strategy
	strategies=(${=ZSH_AUTOSUGGEST_STRATEGY}) 
	for strategy in $strategies
	do
		_zsh_autosuggest_strategy_$strategy "$1"
		[[ "$suggestion" != "$1"* ]] && unset suggestion
		[[ -n "$suggestion" ]] && break
	done
}
_zsh_autosuggest_highlight_apply () {
	typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
	if (( $#POSTDISPLAY ))
	then
		typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT="$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" 
		region_highlight+=("$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT") 
	else
		unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
	fi
}
_zsh_autosuggest_highlight_reset () {
	typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
	if [[ -n "$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT" ]]
	then
		region_highlight=("${(@)region_highlight:#$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT}") 
		unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
	fi
}
_zsh_autosuggest_incr_bind_count () {
	typeset -gi bind_count=$((_ZSH_AUTOSUGGEST_BIND_COUNTS[$1]+1)) 
	_ZSH_AUTOSUGGEST_BIND_COUNTS[$1]=$bind_count 
}
_zsh_autosuggest_invoke_original_widget () {
	(( $# )) || return 0
	local original_widget_name="$1" 
	shift
	if (( ${+widgets[$original_widget_name]} ))
	then
		zle $original_widget_name -- $@
	fi
}
_zsh_autosuggest_modify () {
	local -i retval
	local -i KEYS_QUEUED_COUNT
	local orig_buffer="$BUFFER" 
	local orig_postdisplay="$POSTDISPLAY" 
	unset POSTDISPLAY
	_zsh_autosuggest_invoke_original_widget $@
	retval=$? 
	emulate -L zsh
	if (( $PENDING > 0 || $KEYS_QUEUED_COUNT > 0 ))
	then
		POSTDISPLAY="$orig_postdisplay" 
		return $retval
	fi
	if [[ "$BUFFER" = "$orig_buffer"* && "$orig_postdisplay" = "${BUFFER:$#orig_buffer}"* ]]
	then
		POSTDISPLAY="${orig_postdisplay:$(($#BUFFER - $#orig_buffer))}" 
		return $retval
	fi
	if (( ${+_ZSH_AUTOSUGGEST_DISABLED} ))
	then
		return $?
	fi
	if (( $#BUFFER > 0 ))
	then
		if [[ -z "$ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" ]] || (( $#BUFFER <= $ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE ))
		then
			_zsh_autosuggest_fetch
		fi
	fi
	return $retval
}
_zsh_autosuggest_partial_accept () {
	local -i retval cursor_loc
	local original_buffer="$BUFFER" 
	BUFFER="$BUFFER$POSTDISPLAY" 
	_zsh_autosuggest_invoke_original_widget $@
	retval=$? 
	cursor_loc=$CURSOR 
	if [[ "$KEYMAP" = "vicmd" ]]
	then
		cursor_loc=$((cursor_loc + 1)) 
	fi
	if (( $cursor_loc > $#original_buffer ))
	then
		POSTDISPLAY="${BUFFER[$(($cursor_loc + 1)),$#BUFFER]}" 
		BUFFER="${BUFFER[1,$cursor_loc]}" 
	else
		BUFFER="$original_buffer" 
	fi
	return $retval
}
_zsh_autosuggest_start () {
	if (( ${+ZSH_AUTOSUGGEST_MANUAL_REBIND} ))
	then
		add-zsh-hook -d precmd _zsh_autosuggest_start
	fi
	_zsh_autosuggest_bind_widgets
}
_zsh_autosuggest_strategy_completion () {
	emulate -L zsh
	setopt EXTENDED_GLOB
	typeset -g suggestion
	local line REPLY
	whence compdef > /dev/null || return
	zmodload zsh/zpty 2> /dev/null || return
	[[ -n "$ZSH_AUTOSUGGEST_COMPLETION_IGNORE" ]] && [[ "$1" == $~ZSH_AUTOSUGGEST_COMPLETION_IGNORE ]] && return
	if zle
	then
		zpty $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME _zsh_autosuggest_capture_completion_sync
	else
		zpty $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME _zsh_autosuggest_capture_completion_async "\$1"
		zpty -w $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME $'\t'
	fi
	{
		zpty -r $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME line '*'$'\0''*'$'\0'
		suggestion="${${(@0)line}[2]}" 
	} always {
		zpty -d $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME
	}
}
_zsh_autosuggest_strategy_history () {
	emulate -L zsh
	setopt EXTENDED_GLOB
	local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}" 
	local pattern="$prefix*" 
	if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]
	then
		pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)" 
	fi
	typeset -g suggestion="${history[(r)$pattern]}" 
}
_zsh_autosuggest_strategy_match_prev_cmd () {
	emulate -L zsh
	setopt EXTENDED_GLOB
	local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}" 
	local pattern="$prefix*" 
	if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]
	then
		pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)" 
	fi
	local history_match_keys
	history_match_keys=(${(k)history[(R)$~pattern]}) 
	local histkey="${history_match_keys[1]}" 
	local prev_cmd="$(_zsh_autosuggest_escape_command "${history[$((HISTCMD-1))]}")" 
	for key in "${(@)history_match_keys[1,200]}"
	do
		[[ $key -gt 1 ]] || break
		if [[ "${history[$((key - 1))]}" == "$prev_cmd" ]]
		then
			histkey="$key" 
			break
		fi
	done
	typeset -g suggestion="$history[$histkey]" 
}
_zsh_autosuggest_suggest () {
	emulate -L zsh
	local suggestion="$1" 
	if [[ -n "$suggestion" ]] && (( $#BUFFER ))
	then
		POSTDISPLAY="${suggestion#$BUFFER}" 
	else
		unset POSTDISPLAY
	fi
}
_zsh_autosuggest_toggle () {
	if (( ${+_ZSH_AUTOSUGGEST_DISABLED} ))
	then
		_zsh_autosuggest_enable
	else
		_zsh_autosuggest_disable
	fi
}
_zsh_autosuggest_widget_accept () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_accept $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_autosuggest_widget_clear () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_clear $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_autosuggest_widget_disable () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_disable $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_autosuggest_widget_enable () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_enable $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_autosuggest_widget_execute () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_execute $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_autosuggest_widget_fetch () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_fetch $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_autosuggest_widget_modify () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_modify $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_autosuggest_widget_partial_accept () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_partial_accept $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_autosuggest_widget_suggest () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_suggest $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_autosuggest_widget_toggle () {
	local -i retval
	_zsh_autosuggest_highlight_reset
	_zsh_autosuggest_toggle $@
	retval=$? 
	_zsh_autosuggest_highlight_apply
	zle -R
	return $retval
}
_zsh_highlight () {
	local ret=$? 
	typeset -r ret
	(( ${+region_highlight[@]} )) || {
		echo 'zsh-syntax-highlighting: error: $region_highlight is not defined' >&2
		echo 'zsh-syntax-highlighting: (Check whether zsh-syntax-highlighting was installed according to the instructions.)' >&2
		return $ret
	}
	(( ${+zsh_highlight__memo_feature} )) || {
		region_highlight+=(" 0 0 fg=red, memo=zsh-syntax-highlighting") 
		case ${region_highlight[-1]} in
			("0 0 fg=red") integer -gr zsh_highlight__memo_feature=0  ;;
			("0 0 fg=red memo=zsh-syntax-highlighting") integer -gr zsh_highlight__memo_feature=1  ;;
			(" 0 0 fg=red, memo=zsh-syntax-highlighting")  ;&
			(*) if is-at-least 5.9
				then
					integer -gr zsh_highlight__memo_feature=1 
				else
					integer -gr zsh_highlight__memo_feature=0 
				fi ;;
		esac
		region_highlight[-1]=() 
	}
	if (( zsh_highlight__memo_feature ))
	then
		region_highlight=("${(@)region_highlight:#*memo=zsh-syntax-highlighting*}") 
	else
		region_highlight=() 
	fi
	if [[ $WIDGET == zle-isearch-update ]] && {
			$zsh_highlight__pat_static_bug || ! (( $+ISEARCHMATCH_ACTIVE ))
		}
	then
		return $ret
	fi
	local -A zsyh_user_options
	if zmodload -e zsh/parameter
	then
		zsyh_user_options=("${(kv)options[@]}") 
	else
		local canonical_options onoff option raw_options
		raw_options=(${(f)"$(emulate -R zsh; set -o)"}) 
		canonical_options=(${${${(M)raw_options:#*off}%% *}#no} ${${(M)raw_options:#*on}%% *}) 
		for option in "${canonical_options[@]}"
		do
			[[ -o $option ]]
			case $? in
				(0) zsyh_user_options+=($option on)  ;;
				(1) zsyh_user_options+=($option off)  ;;
				(*) echo "zsh-syntax-highlighting: warning: '[[ -o $option ]]' returned $?" ;;
			esac
		done
	fi
	typeset -r zsyh_user_options
	emulate -L zsh
	setopt localoptions warncreateglobal nobashrematch
	local REPLY
	[[ -n ${ZSH_HIGHLIGHT_MAXLENGTH:-} ]] && [[ $#BUFFER -gt $ZSH_HIGHLIGHT_MAXLENGTH ]] && return $ret
	(( KEYS_QUEUED_COUNT > 0 )) && return $ret
	(( PENDING > 0 )) && return $ret
	{
		local cache_place
		local -a region_highlight_copy
		local highlighter
		for highlighter in $ZSH_HIGHLIGHT_HIGHLIGHTERS
		do
			cache_place="_zsh_highlight__highlighter_${highlighter}_cache" 
			typeset -ga ${cache_place}
			if ! type "_zsh_highlight_highlighter_${highlighter}_predicate" >&/dev/null
			then
				echo "zsh-syntax-highlighting: warning: disabling the ${(qq)highlighter} highlighter as it has not been loaded" >&2
				ZSH_HIGHLIGHT_HIGHLIGHTERS=(${ZSH_HIGHLIGHT_HIGHLIGHTERS:#${highlighter}}) 
			elif "_zsh_highlight_highlighter_${highlighter}_predicate"
			then
				region_highlight_copy=("${region_highlight[@]}") 
				region_highlight=() 
				{
					"_zsh_highlight_highlighter_${highlighter}_paint"
				} always {
					: ${(AP)cache_place::="${region_highlight[@]}"}
				}
				region_highlight=("${region_highlight_copy[@]}") 
			fi
			region_highlight+=("${(@P)cache_place}") 
		done
		() {
			(( REGION_ACTIVE )) || return
			integer min max
			if (( MARK > CURSOR ))
			then
				min=$CURSOR max=$MARK 
			else
				min=$MARK max=$CURSOR 
			fi
			if (( REGION_ACTIVE == 1 ))
			then
				[[ $KEYMAP = vicmd ]] && (( max++ ))
			elif (( REGION_ACTIVE == 2 ))
			then
				local needle=$'\n' 
				(( min = ${BUFFER[(Ib:min:)$needle]} ))
				(( max = ${BUFFER[(ib:max:)$needle]} - 1 ))
			fi
			_zsh_highlight_apply_zle_highlight region standout "$min" "$max"
		}
		(( $+YANK_ACTIVE )) && (( YANK_ACTIVE )) && _zsh_highlight_apply_zle_highlight paste standout "$YANK_START" "$YANK_END"
		(( $+ISEARCHMATCH_ACTIVE )) && (( ISEARCHMATCH_ACTIVE )) && _zsh_highlight_apply_zle_highlight isearch underline "$ISEARCHMATCH_START" "$ISEARCHMATCH_END"
		(( $+SUFFIX_ACTIVE )) && (( SUFFIX_ACTIVE )) && _zsh_highlight_apply_zle_highlight suffix bold "$SUFFIX_START" "$SUFFIX_END"
		return $ret
	} always {
		typeset -g _ZSH_HIGHLIGHT_PRIOR_BUFFER="$BUFFER" 
		typeset -gi _ZSH_HIGHLIGHT_PRIOR_CURSOR=$CURSOR 
	}
}
_zsh_highlight__function_callable_p () {
	if _zsh_highlight__is_function_p "$1" && ! _zsh_highlight__function_is_autoload_stub_p "$1"
	then
		return 0
	else
		(
			autoload -U +X -- "$1" 2> /dev/null
		)
		return $?
	fi
}
_zsh_highlight__function_is_autoload_stub_p () {
	if zmodload -e zsh/parameter
	then
		[[ "$functions[$1]" == *"builtin autoload -X"* ]]
	else
		[[ "${${(@f)"$(which -- "$1")"}[2]}" == $'\t'$histchars[3]' undefined' ]]
	fi
}
_zsh_highlight__is_function_p () {
	if zmodload -e zsh/parameter
	then
		(( ${+functions[$1]} ))
	else
		[[ $(type -wa -- "$1") == *'function'* ]]
	fi
}
_zsh_highlight__zle-line-finish () {
	() {
		local -h -r WIDGET=zle-line-finish 
		_zsh_highlight
	}
}
_zsh_highlight__zle-line-pre-redraw () {
	true && _zsh_highlight "$@"
}
_zsh_highlight_add_highlight () {
	local -i start end
	local highlight
	start=$1 
	end=$2 
	shift 2
	for highlight
	do
		if (( $+ZSH_HIGHLIGHT_STYLES[$highlight] ))
		then
			region_highlight+=("$start $end $ZSH_HIGHLIGHT_STYLES[$highlight], memo=zsh-syntax-highlighting") 
			break
		fi
	done
}
_zsh_highlight_apply_zle_highlight () {
	local entry="$1" default="$2" 
	integer first="$3" second="$4" 
	local region="${zle_highlight[(r)${entry}:*]-}" 
	if [[ -z "$region" ]]
	then
		region=$default 
	else
		region="${region#${entry}:}" 
		if [[ -z "$region" ]] || [[ "$region" == none ]]
		then
			return
		fi
	fi
	integer start end
	if (( first < second ))
	then
		start=$first end=$second 
	else
		start=$second end=$first 
	fi
	region_highlight+=("$start $end $region, memo=zsh-syntax-highlighting") 
}
_zsh_highlight_bind_widgets () {
	
}
_zsh_highlight_brackets_match () {
	case $BUFFER[$1] in
		(\() [[ $BUFFER[$2] == \) ]] ;;
		(\[) [[ $BUFFER[$2] == \] ]] ;;
		(\{) [[ $BUFFER[$2] == \} ]] ;;
		(*) false ;;
	esac
}
_zsh_highlight_buffer_modified () {
	[[ "${_ZSH_HIGHLIGHT_PRIOR_BUFFER:-}" != "$BUFFER" ]]
}
_zsh_highlight_call_widget () {
	builtin zle "$@" && _zsh_highlight
}
_zsh_highlight_cursor_moved () {
	[[ -n $CURSOR ]] && [[ -n ${_ZSH_HIGHLIGHT_PRIOR_CURSOR-} ]] && (($_ZSH_HIGHLIGHT_PRIOR_CURSOR != $CURSOR))
}
_zsh_highlight_highlighter_brackets_paint () {
	local char style
	local -i bracket_color_size=${#ZSH_HIGHLIGHT_STYLES[(I)bracket-level-*]} buflen=${#BUFFER} level=0 matchingpos pos 
	local -A levelpos lastoflevel matching
	pos=0 
	for char in ${(s..)BUFFER}
	do
		(( ++pos ))
		case $char in
			(["([{"]) levelpos[$pos]=$((++level)) 
				lastoflevel[$level]=$pos  ;;
			([")]}"]) if (( level > 0 ))
				then
					matchingpos=$lastoflevel[$level] 
					levelpos[$pos]=$((level--)) 
					if _zsh_highlight_brackets_match $matchingpos $pos
					then
						matching[$matchingpos]=$pos 
						matching[$pos]=$matchingpos 
					fi
				else
					levelpos[$pos]=-1 
				fi ;;
		esac
	done
	for pos in ${(k)levelpos}
	do
		if (( $+matching[$pos] ))
		then
			if (( bracket_color_size ))
			then
				_zsh_highlight_add_highlight $((pos - 1)) $pos bracket-level-$(( (levelpos[$pos] - 1) % bracket_color_size + 1 ))
			fi
		else
			_zsh_highlight_add_highlight $((pos - 1)) $pos bracket-error
		fi
	done
	if [[ $WIDGET != zle-line-finish ]]
	then
		pos=$((CURSOR + 1)) 
		if (( $+levelpos[$pos] )) && (( $+matching[$pos] ))
		then
			local -i otherpos=$matching[$pos] 
			_zsh_highlight_add_highlight $((otherpos - 1)) $otherpos cursor-matchingbracket
		fi
	fi
}
_zsh_highlight_highlighter_brackets_predicate () {
	[[ $WIDGET == zle-line-finish ]] || _zsh_highlight_cursor_moved || _zsh_highlight_buffer_modified
}
_zsh_highlight_highlighter_cursor_paint () {
	[[ $WIDGET == zle-line-finish ]] && return
	_zsh_highlight_add_highlight $CURSOR $(( $CURSOR + 1 )) cursor
}
_zsh_highlight_highlighter_cursor_predicate () {
	[[ $WIDGET == zle-line-finish ]] || _zsh_highlight_cursor_moved
}
_zsh_highlight_highlighter_line_paint () {
	_zsh_highlight_add_highlight 0 $#BUFFER line
}
_zsh_highlight_highlighter_line_predicate () {
	_zsh_highlight_buffer_modified
}
_zsh_highlight_highlighter_main_paint () {
	setopt localoptions extendedglob
	if [[ $CONTEXT == (select|vared) ]]
	then
		return
	fi
	typeset -a ZSH_HIGHLIGHT_TOKENS_COMMANDSEPARATOR
	typeset -a ZSH_HIGHLIGHT_TOKENS_CONTROL_FLOW
	local -a options_to_set reply
	local REPLY
	local flags_with_argument
	local flags_sans_argument
	local flags_solo
	local -A precommand_options
	precommand_options=('-' '' 'builtin' '' 'command' :pvV 'exec' a:cl 'noglob' '' 'doas' aCu:Lns 'nice' n: 'pkexec' '' 'sudo' Cgprtu:AEHPSbilns:eKkVv 'stdbuf' ioe: 'eatmydata' '' 'catchsegv' '' 'nohup' '' 'setsid' :wc 'env' u:i 'ionice' cn:t:pPu 'strace' IbeaosXPpEuOS:ACdfhikqrtTvVxyDc 'proxychains' f:q 'torsocks' idq:upaP 'torify' idq:upaP 'ssh-agent' aEPt:csDd:k 'tabbed' gnprtTuU:cdfhs:v 'chronic' :ev 'ifne' :n 'grc' :se 'cpulimit' elp:ivz 'ktrace' fgpt:aBCcdiT) 
	if [[ $zsyh_user_options[ignorebraces] == on || ${zsyh_user_options[ignoreclosebraces]:-off} == on ]]
	then
		local right_brace_is_recognised_everywhere=false 
	else
		local right_brace_is_recognised_everywhere=true 
	fi
	if [[ $zsyh_user_options[pathdirs] == on ]]
	then
		options_to_set+=(PATH_DIRS) 
	fi
	ZSH_HIGHLIGHT_TOKENS_COMMANDSEPARATOR=('|' '||' ';' '&' '&&' $'\n' '|&' '&!' '&|') 
	ZSH_HIGHLIGHT_TOKENS_CONTROL_FLOW=($'\x7b' $'\x28' '()' 'while' 'until' 'if' 'then' 'elif' 'else' 'do' 'time' 'coproc' '!') 
	if (( $+X_ZSH_HIGHLIGHT_DIRS_BLACKLIST ))
	then
		print 'zsh-syntax-highlighting: X_ZSH_HIGHLIGHT_DIRS_BLACKLIST is deprecated. Please use ZSH_HIGHLIGHT_DIRS_BLACKLIST.' >&2
		ZSH_HIGHLIGHT_DIRS_BLACKLIST=($X_ZSH_HIGHLIGHT_DIRS_BLACKLIST) 
		unset X_ZSH_HIGHLIGHT_DIRS_BLACKLIST
	fi
	_zsh_highlight_main_highlighter_highlight_list -$#PREBUFFER '' 1 "$PREBUFFER$BUFFER"
	local start end_ style
	for start end_ style in $reply
	do
		(( start >= end_ )) && {
			print -r -- "zsh-syntax-highlighting: BUG: _zsh_highlight_highlighter_main_paint: start($start) >= end($end_)" >&2
			return
		}
		(( end_ <= 0 )) && continue
		(( start < 0 )) && start=0 
		_zsh_highlight_main_calculate_fallback $style
		_zsh_highlight_add_highlight $start $end_ $reply
	done
}
_zsh_highlight_highlighter_main_predicate () {
	[[ $WIDGET == zle-line-finish ]] || _zsh_highlight_buffer_modified
}
_zsh_highlight_highlighter_pattern_paint () {
	setopt localoptions extendedglob
	local pattern
	for pattern in ${(k)ZSH_HIGHLIGHT_PATTERNS}
	do
		_zsh_highlight_pattern_highlighter_loop "$BUFFER" "$pattern"
	done
}
_zsh_highlight_highlighter_pattern_predicate () {
	_zsh_highlight_buffer_modified
}
_zsh_highlight_highlighter_regexp_paint () {
	setopt localoptions extendedglob
	local pattern
	for pattern in ${(k)ZSH_HIGHLIGHT_REGEXP}
	do
		_zsh_highlight_regexp_highlighter_loop "$BUFFER" "$pattern"
	done
}
_zsh_highlight_highlighter_regexp_predicate () {
	_zsh_highlight_buffer_modified
}
_zsh_highlight_highlighter_root_paint () {
	if (( EUID == 0 ))
	then
		_zsh_highlight_add_highlight 0 $#BUFFER root
	fi
}
_zsh_highlight_highlighter_root_predicate () {
	_zsh_highlight_buffer_modified
}
_zsh_highlight_load_highlighters () {
	setopt localoptions noksharrays bareglobqual
	[[ -d "$1" ]] || {
		print -r -- "zsh-syntax-highlighting: highlighters directory ${(qq)1} not found." >&2
		return 1
	}
	local highlighter highlighter_dir
	for highlighter_dir in $1/*/(/)
	do
		highlighter="${highlighter_dir:t}" 
		[[ -f "$highlighter_dir${highlighter}-highlighter.zsh" ]] && . "$highlighter_dir${highlighter}-highlighter.zsh"
		if type "_zsh_highlight_highlighter_${highlighter}_paint" &> /dev/null && type "_zsh_highlight_highlighter_${highlighter}_predicate" &> /dev/null
		then
			
		elif type "_zsh_highlight_${highlighter}_highlighter" &> /dev/null && type "_zsh_highlight_${highlighter}_highlighter_predicate" &> /dev/null
		then
			if false
			then
				print -r -- "zsh-syntax-highlighting: warning: ${(qq)highlighter} highlighter uses deprecated entry point names; please ask its maintainer to update it: https://github.com/zsh-users/zsh-syntax-highlighting/issues/329" >&2
			fi
			eval "_zsh_highlight_highlighter_${(q)highlighter}_paint() { _zsh_highlight_${(q)highlighter}_highlighter \"\$@\" }"
			eval "_zsh_highlight_highlighter_${(q)highlighter}_predicate() { _zsh_highlight_${(q)highlighter}_highlighter_predicate \"\$@\" }"
		else
			print -r -- "zsh-syntax-highlighting: ${(qq)highlighter} highlighter should define both required functions '_zsh_highlight_highlighter_${highlighter}_paint' and '_zsh_highlight_highlighter_${highlighter}_predicate' in ${(qq):-"$highlighter_dir${highlighter}-highlighter.zsh"}." >&2
		fi
	done
}
_zsh_highlight_main__is_global_alias () {
	if zmodload -e zsh/parameter
	then
		(( ${+galiases[$arg]} ))
	elif [[ $arg == '='* ]]
	then
		return 1
	else
		alias -L -g -- "$1" > /dev/null
	fi
}
_zsh_highlight_main__is_redirection () {
	[[ $1 == (<0-9>|)(\<|\>)* ]] && [[ $1 != (\<|\>)$'\x28'* ]] && [[ $1 != *'<'*'-'*'>'* ]]
}
_zsh_highlight_main__is_runnable () {
	if _zsh_highlight_main__type "$1"
	then
		[[ $REPLY != none ]]
	else
		return 2
	fi
}
_zsh_highlight_main__precmd_hook () {
	setopt localoptions
	if eval '[[ -o warnnestedvar ]]' 2> /dev/null
	then
		unsetopt warnnestedvar
	fi
	_zsh_highlight_main__command_type_cache=() 
}
_zsh_highlight_main__resolve_alias () {
	if zmodload -e zsh/parameter
	then
		REPLY=${aliases[$arg]} 
	else
		REPLY="${"$(alias -- $arg)"#*=}" 
	fi
}
_zsh_highlight_main__stack_pop () {
	if [[ $braces_stack[1] == $1 ]]
	then
		braces_stack=${braces_stack:1} 
		if (( $+2 ))
		then
			style=$2 
		fi
		return 0
	else
		style=unknown-token 
		return 1
	fi
}
_zsh_highlight_main__type () {
	integer -r aliases_allowed=${2-1} 
	integer may_cache=1 
	if (( $+_zsh_highlight_main__command_type_cache ))
	then
		REPLY=$_zsh_highlight_main__command_type_cache[(e)$1] 
		if [[ -n "$REPLY" ]]
		then
			return
		fi
	fi
	if (( $#options_to_set ))
	then
		setopt localoptions $options_to_set
	fi
	unset REPLY
	if zmodload -e zsh/parameter
	then
		if (( $+aliases[(e)$1] ))
		then
			may_cache=0 
		fi
		if (( ${+galiases[(e)$1]} )) && (( aliases_allowed ))
		then
			REPLY='global alias' 
		elif (( $+aliases[(e)$1] )) && (( aliases_allowed ))
		then
			REPLY=alias 
		elif [[ $1 == *.* && -n ${1%.*} ]] && (( $+saliases[(e)${1##*.}] ))
		then
			REPLY='suffix alias' 
		elif (( $reswords[(Ie)$1] ))
		then
			REPLY=reserved 
		elif (( $+functions[(e)$1] ))
		then
			REPLY=function 
		elif (( $+builtins[(e)$1] ))
		then
			REPLY=builtin 
		elif (( $+commands[(e)$1] ))
		then
			REPLY=command 
		elif {
				[[ $1 != */* ]] || is-at-least 5.3
			} && ! (
				builtin type -w -- "$1"
			) > /dev/null 2>&1
		then
			REPLY=none 
		fi
	fi
	if ! (( $+REPLY ))
	then
		REPLY="${$(:; (( aliases_allowed )) || unalias -- "$1" 2>/dev/null; LC_ALL=C builtin type -w -- "$1" 2>/dev/null)##*: }" 
		if [[ $REPLY == 'alias' ]]
		then
			may_cache=0 
		fi
	fi
	if (( may_cache )) && (( $+_zsh_highlight_main__command_type_cache ))
	then
		_zsh_highlight_main__command_type_cache[(e)$1]=$REPLY 
	fi
	[[ -n $REPLY ]]
	return $?
}
_zsh_highlight_main_add_many_region_highlights () {
	for 1 2 3
	do
		_zsh_highlight_main_add_region_highlight $1 $2 $3
	done
}
_zsh_highlight_main_add_region_highlight () {
	integer start=$1 end=$2 
	shift 2
	if (( $#in_alias ))
	then
		[[ $1 == unknown-token ]] && alias_style=unknown-token 
		return
	fi
	if (( in_param ))
	then
		if [[ $1 == unknown-token ]]
		then
			param_style=unknown-token 
		fi
		if [[ -n $param_style ]]
		then
			return
		fi
		param_style=$1 
		return
	fi
	(( start += buf_offset ))
	(( end += buf_offset ))
	list_highlights+=($start $end $1) 
}
_zsh_highlight_main_calculate_fallback () {
	local -A fallback_of
	fallback_of=(alias arg0 suffix-alias arg0 global-alias dollar-double-quoted-argument builtin arg0 function arg0 command arg0 precommand arg0 hashed-command arg0 autodirectory arg0 arg0_\* arg0 path_prefix path path_pathseparator path path_prefix_pathseparator path_prefix single-quoted-argument{-unclosed,} double-quoted-argument{-unclosed,} dollar-quoted-argument{-unclosed,} back-quoted-argument{-unclosed,} command-substitution{-quoted,,-unquoted,} command-substitution-delimiter{-quoted,,-unquoted,} command-substitution{-delimiter,} process-substitution{-delimiter,} back-quoted-argument{-delimiter,}) 
	local needle=$1 value 
	reply=($1) 
	while [[ -n ${value::=$fallback_of[(k)$needle]} ]]
	do
		unset "fallback_of[$needle]"
		reply+=($value) 
		needle=$value 
	done
}
_zsh_highlight_main_highlighter__try_expand_parameter () {
	local arg="$1" 
	unset reply
	{
		{
			local -a match mbegin mend
			local MATCH
			integer MBEGIN MEND
			local parameter_name
			local -a words
			if [[ $arg[1] != '$' ]]
			then
				return 1
			fi
			if [[ ${arg[2]} == '{' ]] && [[ ${arg[-1]} == '}' ]]
			then
				parameter_name=${${arg:2}%?} 
			else
				parameter_name=${arg:1} 
			fi
			if [[ $res == none ]] && [[ ${parameter_name} =~ ^${~parameter_name_pattern}$ ]] && [[ ${(tP)MATCH} != *special* ]]
			then
				case ${(tP)MATCH} in
					(*array*|*assoc*) words=(${(P)MATCH})  ;;
					("") words=()  ;;
					(*) if [[ $zsyh_user_options[shwordsplit] == on ]]
						then
							words=(${(P)=MATCH}) 
						else
							words=(${(P)MATCH}) 
						fi ;;
				esac
				reply=("${words[@]}") 
			else
				return 1
			fi
		}
	}
}
_zsh_highlight_main_highlighter_check_assign () {
	setopt localoptions extended_glob
	[[ $arg == [[:alpha:]_][[:alnum:]_]#(|\[*\])(|[+])=* ]] || [[ $arg == [0-9]##(|[+])=* ]]
}
_zsh_highlight_main_highlighter_check_path () {
	_zsh_highlight_main_highlighter_expand_path "$1"
	local expanded_path="$REPLY" tmp_path 
	integer in_command_position=$2 
	if [[ $zsyh_user_options[autocd] == on ]]
	then
		integer autocd=1 
	else
		integer autocd=0 
	fi
	if (( in_command_position ))
	then
		REPLY=arg0 
	else
		REPLY=path 
	fi
	if [[ ${1[1]} == '=' && $1 == ??* && ${1[2]} != $'\x28' && $zsyh_user_options[equals] == 'on' && $expanded_path[1] != '/' ]]
	then
		REPLY=unknown-token 
		return 0
	fi
	[[ -z $expanded_path ]] && return 1
	if [[ $expanded_path[1] == / ]]
	then
		tmp_path=$expanded_path 
	else
		tmp_path=$PWD/$expanded_path 
	fi
	tmp_path=$tmp_path:a 
	while [[ $tmp_path != / ]]
	do
		[[ -n ${(M)ZSH_HIGHLIGHT_DIRS_BLACKLIST:#$tmp_path} ]] && return 1
		tmp_path=$tmp_path:h 
	done
	if (( in_command_position ))
	then
		if [[ -x $expanded_path ]]
		then
			if (( autocd ))
			then
				if [[ -d $expanded_path ]]
				then
					REPLY=autodirectory 
				fi
				return 0
			elif [[ ! -d $expanded_path ]]
			then
				return 0
			fi
		fi
	else
		if [[ -L $expanded_path || -e $expanded_path ]]
		then
			return 0
		fi
	fi
	if [[ $expanded_path != /* ]] && (( autocd || ! in_command_position ))
	then
		local cdpath_dir
		for cdpath_dir in $cdpath
		do
			if [[ -d "$cdpath_dir/$expanded_path" && -x "$cdpath_dir/$expanded_path" ]]
			then
				if (( in_command_position && autocd ))
				then
					REPLY=autodirectory 
				fi
				return 0
			fi
		done
	fi
	[[ ! -d ${expanded_path:h} ]] && return 1
	if (( has_end && (len == end_pos) )) && (( ! $#in_alias )) && [[ $WIDGET != zle-line-finish ]]
	then
		local -a tmp
		if (( in_command_position ))
		then
			tmp=(${expanded_path}*(N-*,N-/)) 
		else
			tmp=(${expanded_path}*(N)) 
		fi
		(( ${+tmp[1]} )) && REPLY=path_prefix  && return 0
	fi
	return 1
}
_zsh_highlight_main_highlighter_expand_path () {
	(( $# == 1 )) || print -r -- "zsh-syntax-highlighting: BUG: _zsh_highlight_main_highlighter_expand_path: called without argument" >&2
	setopt localoptions nonomatch
	unset REPLY
	: ${REPLY:=${(Q)${~1}}}
}
_zsh_highlight_main_highlighter_highlight_argument () {
	local base_style=default i=$1 option_eligible=${2:-1} path_eligible=1 ret start style 
	local -a highlights
	local -a match mbegin mend
	local MATCH
	integer MBEGIN MEND
	case "$arg[i]" in
		('%') if [[ $arg[i+1] == '?' ]]
			then
				(( i += 2 ))
			fi ;;
		('-') if (( option_eligible ))
			then
				if [[ $arg[i+1] == - ]]
				then
					base_style=double-hyphen-option 
				else
					base_style=single-hyphen-option 
				fi
				path_eligible=0 
			fi ;;
		('=') if [[ $arg[i+1] == $'\x28' ]]
			then
				(( i += 2 ))
				_zsh_highlight_main_highlighter_highlight_list $(( start_pos + i - 1 )) S $has_end $arg[i,-1]
				ret=$? 
				(( i += REPLY ))
				highlights+=($(( start_pos + $1 - 1 )) $(( start_pos + i )) process-substitution $(( start_pos + $1 - 1 )) $(( start_pos + $1 + 1 )) process-substitution-delimiter $reply) 
				if (( ret == 0 ))
				then
					highlights+=($(( start_pos + i - 1 )) $(( start_pos + i )) process-substitution-delimiter) 
				fi
			fi ;;
	esac
	(( --i ))
	while (( ++i <= $#arg ))
	do
		i=${arg[(ib.i.)[\\\'\"\`\$\<\>\*\?]]} 
		case "$arg[$i]" in
			("") break ;;
			("\\") (( i += 1 ))
				continue ;;
			("'") _zsh_highlight_main_highlighter_highlight_single_quote $i
				(( i = REPLY ))
				highlights+=($reply)  ;;
			('"') _zsh_highlight_main_highlighter_highlight_double_quote $i
				(( i = REPLY ))
				highlights+=($reply)  ;;
			('`') _zsh_highlight_main_highlighter_highlight_backtick $i
				(( i = REPLY ))
				highlights+=($reply)  ;;
			('$') if [[ $arg[i+1] != "'" ]]
				then
					path_eligible=0 
				fi
				if [[ $arg[i+1] == "'" ]]
				then
					_zsh_highlight_main_highlighter_highlight_dollar_quote $i
					(( i = REPLY ))
					highlights+=($reply) 
					continue
				elif [[ $arg[i+1] == $'\x28' ]]
				then
					if [[ $arg[i+2] == $'\x28' ]] && _zsh_highlight_main_highlighter_highlight_arithmetic $i
					then
						(( i = REPLY ))
						highlights+=($reply) 
						continue
					fi
					start=$i 
					(( i += 2 ))
					_zsh_highlight_main_highlighter_highlight_list $(( start_pos + i - 1 )) S $has_end $arg[i,-1]
					ret=$? 
					(( i += REPLY ))
					highlights+=($(( start_pos + start - 1)) $(( start_pos + i )) command-substitution-unquoted $(( start_pos + start - 1)) $(( start_pos + start + 1)) command-substitution-delimiter-unquoted $reply) 
					if (( ret == 0 ))
					then
						highlights+=($(( start_pos + i - 1)) $(( start_pos + i )) command-substitution-delimiter-unquoted) 
					fi
					continue
				fi
				while [[ $arg[i+1] == [=~#+'^'] ]]
				do
					(( i += 1 ))
				done
				if [[ $arg[i+1] == [*@#?$!-] ]]
				then
					(( i += 1 ))
				fi ;;
			([\<\>]) if [[ $arg[i+1] == $'\x28' ]]
				then
					start=$i 
					(( i += 2 ))
					_zsh_highlight_main_highlighter_highlight_list $(( start_pos + i - 1 )) S $has_end $arg[i,-1]
					ret=$? 
					(( i += REPLY ))
					highlights+=($(( start_pos + start - 1)) $(( start_pos + i )) process-substitution $(( start_pos + start - 1)) $(( start_pos + start + 1 )) process-substitution-delimiter $reply) 
					if (( ret == 0 ))
					then
						highlights+=($(( start_pos + i - 1)) $(( start_pos + i )) process-substitution-delimiter) 
					fi
					continue
				fi ;|
			(*) if $highlight_glob && [[ $zsyh_user_options[multios] == on || $in_redirection -eq 0 ]] && [[ ${arg[$i]} =~ ^[*?] || ${arg:$i-1} =~ ^\<[0-9]*-[0-9]*\> ]]
				then
					highlights+=($(( start_pos + i - 1 )) $(( start_pos + i + $#MATCH - 1)) globbing) 
					(( i += $#MATCH - 1 ))
					path_eligible=0 
				else
					continue
				fi ;;
		esac
	done
	if (( path_eligible ))
	then
		if (( in_redirection )) && [[ $last_arg == *['<>']['&'] && $arg[$1,-1] == (<0->|p|-) ]]
		then
			if [[ $arg[$1,-1] == (p|-) ]]
			then
				base_style=redirection 
			else
				base_style=numeric-fd 
			fi
		elif _zsh_highlight_main_highlighter_check_path $arg[$1,-1] 0
		then
			base_style=$REPLY 
			_zsh_highlight_main_highlighter_highlight_path_separators $base_style
			highlights+=($reply) 
		fi
	fi
	highlights=($(( start_pos + $1 - 1 )) $end_pos $base_style $highlights) 
	_zsh_highlight_main_add_many_region_highlights $highlights
}
_zsh_highlight_main_highlighter_highlight_arithmetic () {
	local -a saved_reply
	local style
	integer i j k paren_depth ret
	reply=() 
	for ((i = $1 + 3 ; i <= end_pos - start_pos ; i += 1 )) do
		(( j = i + start_pos - 1 ))
		(( k = j + 1 ))
		case "$arg[$i]" in
			([\'\"\\@{}]) style=unknown-token  ;;
			('(') (( paren_depth++ ))
				continue ;;
			(')') if (( paren_depth ))
				then
					(( paren_depth-- ))
					continue
				fi
				[[ $arg[i+1] == ')' ]] && {
					(( i++ ))
					break
				}
				(( has_end && (len == k) )) && break
				return 1 ;;
			('`') saved_reply=($reply) 
				_zsh_highlight_main_highlighter_highlight_backtick $i
				(( i = REPLY ))
				reply=($saved_reply $reply) 
				continue ;;
			('$') if [[ $arg[i+1] == $'\x28' ]]
				then
					saved_reply=($reply) 
					if [[ $arg[i+2] == $'\x28' ]] && _zsh_highlight_main_highlighter_highlight_arithmetic $i
					then
						(( i = REPLY ))
						reply=($saved_reply $reply) 
						continue
					fi
					(( i += 2 ))
					_zsh_highlight_main_highlighter_highlight_list $(( start_pos + i - 1 )) S $has_end $arg[i,end_pos]
					ret=$? 
					(( i += REPLY ))
					reply=($saved_reply $j $(( start_pos + i )) command-substitution-quoted $j $(( j + 2 )) command-substitution-delimiter-quoted $reply) 
					if (( ret == 0 ))
					then
						reply+=($(( start_pos + i - 1 )) $(( start_pos + i )) command-substitution-delimiter) 
					fi
					continue
				else
					continue
				fi ;;
			($histchars[1]) if [[ $arg[i+1] != ('='|$'\x28'|$'\x7b'|[[:blank:]]) ]]
				then
					style=history-expansion 
				else
					continue
				fi ;;
			(*) continue ;;
		esac
		reply+=($j $k $style) 
	done
	if [[ $arg[i] != ')' ]]
	then
		(( i-- ))
	fi
	style=arithmetic-expansion 
	reply=($(( start_pos + $1 - 1)) $(( start_pos + i )) arithmetic-expansion $reply) 
	REPLY=$i 
}
_zsh_highlight_main_highlighter_highlight_backtick () {
	local buf highlight style=back-quoted-argument-unclosed style_end 
	local -i arg1=$1 end_ i=$1 last offset=0 start subshell_has_end=0 
	local -a highlight_zone highlights offsets
	reply=() 
	last=$(( arg1 + 1 )) 
	while i=$arg[(ib:i+1:)[\\\\\`]] 
	do
		if (( i > $#arg ))
		then
			buf=$buf$arg[last,i] 
			offsets[i-arg1-offset]='' 
			(( i-- ))
			subshell_has_end=$(( has_end && (start_pos + i == len) )) 
			break
		fi
		if [[ $arg[i] == '\' ]]
		then
			(( i++ ))
			if [[ $arg[i] == ('$'|'`'|'\') ]]
			then
				buf=$buf$arg[last,i-2] 
				(( offset++ ))
				offsets[i-arg1-offset]=$offset 
			else
				buf=$buf$arg[last,i-1] 
			fi
		else
			style=back-quoted-argument 
			style_end=back-quoted-argument-delimiter 
			buf=$buf$arg[last,i-1] 
			offsets[i-arg1-offset]='' 
			break
		fi
		last=$i 
	done
	_zsh_highlight_main_highlighter_highlight_list 0 '' $subshell_has_end $buf
	for start end_ highlight in $reply
	do
		start=$(( start_pos + arg1 + start + offsets[(Rb:start:)?*] )) 
		end_=$(( start_pos + arg1 + end_ + offsets[(Rb:end_:)?*] )) 
		highlights+=($start $end_ $highlight) 
		if [[ $highlight == back-quoted-argument-unclosed && $style == back-quoted-argument ]]
		then
			style_end=unknown-token 
		fi
	done
	reply=($(( start_pos + arg1 - 1 )) $(( start_pos + i )) $style $(( start_pos + arg1 - 1 )) $(( start_pos + arg1 )) back-quoted-argument-delimiter $highlights) 
	if (( $#style_end ))
	then
		reply+=($(( start_pos + i - 1)) $(( start_pos + i )) $style_end) 
	fi
	REPLY=$i 
}
_zsh_highlight_main_highlighter_highlight_dollar_quote () {
	local -a match mbegin mend
	local MATCH
	integer MBEGIN MEND
	local i j k style
	local AA
	integer c
	reply=() 
	for ((i = $1 + 2 ; i <= $#arg ; i += 1 )) do
		(( j = i + start_pos - 1 ))
		(( k = j + 1 ))
		case "$arg[$i]" in
			("'") break ;;
			("\\") style=back-dollar-quoted-argument 
				for ((c = i + 1 ; c <= $#arg ; c += 1 )) do
					[[ "$arg[$c]" != ([0-9xXuUa-fA-F]) ]] && break
				done
				AA=$arg[$i+1,$c-1] 
				if [[ "$AA" =~ "^(x|X)[0-9a-fA-F]{1,2}" || "$AA" =~ "^[0-7]{1,3}" || "$AA" =~ "^u[0-9a-fA-F]{1,4}" || "$AA" =~ "^U[0-9a-fA-F]{1,8}" ]]
				then
					(( k += $#MATCH ))
					(( i += $#MATCH ))
				else
					if (( $#arg > $i+1 )) && [[ $arg[$i+1] == [xXuU] ]]
					then
						style=unknown-token 
					fi
					(( k += 1 ))
					(( i += 1 ))
				fi ;;
			(*) continue ;;
		esac
		reply+=($j $k $style) 
	done
	if [[ $arg[i] == "'" ]]
	then
		style=dollar-quoted-argument 
	else
		(( i-- ))
		style=dollar-quoted-argument-unclosed 
	fi
	reply=($(( start_pos + $1 - 1 )) $(( start_pos + i )) $style $reply) 
	REPLY=$i 
}
_zsh_highlight_main_highlighter_highlight_double_quote () {
	local -a breaks match mbegin mend saved_reply
	local MATCH
	integer last_break=$(( start_pos + $1 - 1 )) MBEGIN MEND 
	local i j k ret style
	reply=() 
	for ((i = $1 + 1 ; i <= $#arg ; i += 1 )) do
		(( j = i + start_pos - 1 ))
		(( k = j + 1 ))
		case "$arg[$i]" in
			('"') break ;;
			('`') saved_reply=($reply) 
				_zsh_highlight_main_highlighter_highlight_backtick $i
				(( i = REPLY ))
				reply=($saved_reply $reply) 
				continue ;;
			('$') style=dollar-double-quoted-argument 
				if [[ ${arg:$i} =~ ^([A-Za-z_][A-Za-z0-9_]*|[0-9]+) ]]
				then
					(( k += $#MATCH ))
					(( i += $#MATCH ))
				elif [[ ${arg:$i} =~ ^[{]([A-Za-z_][A-Za-z0-9_]*|[0-9]+)[}] ]]
				then
					(( k += $#MATCH ))
					(( i += $#MATCH ))
				elif [[ $arg[i+1] == '$' ]]
				then
					(( k += 1 ))
					(( i += 1 ))
				elif [[ $arg[i+1] == [-#*@?] ]]
				then
					(( k += 1 ))
					(( i += 1 ))
				elif [[ $arg[i+1] == $'\x28' ]]
				then
					saved_reply=($reply) 
					if [[ $arg[i+2] == $'\x28' ]] && _zsh_highlight_main_highlighter_highlight_arithmetic $i
					then
						(( i = REPLY ))
						reply=($saved_reply $reply) 
						continue
					fi
					breaks+=($last_break $(( start_pos + i - 1 ))) 
					(( i += 2 ))
					_zsh_highlight_main_highlighter_highlight_list $(( start_pos + i - 1 )) S $has_end $arg[i,-1]
					ret=$? 
					(( i += REPLY ))
					last_break=$(( start_pos + i )) 
					reply=($saved_reply $j $(( start_pos + i )) command-substitution-quoted $j $(( j + 2 )) command-substitution-delimiter-quoted $reply) 
					if (( ret == 0 ))
					then
						reply+=($(( start_pos + i - 1 )) $(( start_pos + i )) command-substitution-delimiter-quoted) 
					fi
					continue
				else
					continue
				fi ;;
			("\\") style=back-double-quoted-argument 
				if [[ \\\`\"\$${histchars[1]} == *$arg[$i+1]* ]]
				then
					(( k += 1 ))
					(( i += 1 ))
				else
					continue
				fi ;;
			($histchars[1]) if [[ $arg[i+1] != ('='|$'\x28'|$'\x7b'|[[:blank:]]) ]]
				then
					style=history-expansion 
				else
					continue
				fi ;;
			(*) continue ;;
		esac
		reply+=($j $k $style) 
	done
	if [[ $arg[i] == '"' ]]
	then
		style=double-quoted-argument 
	else
		(( i-- ))
		style=double-quoted-argument-unclosed 
	fi
	(( last_break != start_pos + i )) && breaks+=($last_break $(( start_pos + i ))) 
	saved_reply=($reply) 
	reply=() 
	for 1 2 in $breaks
	do
		(( $1 != $2 )) && reply+=($1 $2 $style) 
	done
	reply+=($saved_reply) 
	REPLY=$i 
}
_zsh_highlight_main_highlighter_highlight_list () {
	integer start_pos end_pos=0 buf_offset=$1 has_end=$3 
	local alias_style param_style last_arg arg buf=$4 highlight_glob=true saw_assignment=false style 
	local in_array_assignment=false 
	integer in_param=0 len=$#buf 
	local -a in_alias match mbegin mend list_highlights
	local -A seen_alias
	readonly parameter_name_pattern='([A-Za-z_][A-Za-z0-9_]*|[0-9]+)' 
	list_highlights=() 
	local braces_stack=$2 
	local this_word next_word=':start::start_of_pipeline:' 
	integer in_redirection
	local proc_buf="$buf" 
	local -a args
	if [[ $zsyh_user_options[interactivecomments] == on ]]
	then
		args=(${(zZ+c+)buf}) 
	else
		args=(${(z)buf}) 
	fi
	if [[ $braces_stack == 'S' ]] && (( $+args[3] && ! $+args[4] )) && [[ $args[3] == $'\x29' ]] && [[ $args[1] == *'<'* ]] && _zsh_highlight_main__is_redirection $args[1]
	then
		highlight_glob=false 
	fi
	while (( $#args ))
	do
		last_arg=$arg 
		arg=$args[1] 
		shift args
		if (( $#in_alias ))
		then
			(( in_alias[1]-- ))
			in_alias=($in_alias[$in_alias[(i)<1->],-1]) 
			if (( $#in_alias == 0 ))
			then
				seen_alias=() 
				_zsh_highlight_main_add_region_highlight $start_pos $end_pos $alias_style
			else
				() {
					local alias_name
					for alias_name in ${(k)seen_alias[(R)<$#in_alias->]}
					do
						seen_alias=("${(@kv)seen_alias[(I)^$alias_name]}") 
					done
				}
			fi
		fi
		if (( in_param ))
		then
			(( in_param-- ))
			if (( in_param == 0 ))
			then
				_zsh_highlight_main_add_region_highlight $start_pos $end_pos $param_style
				param_style="" 
			fi
		fi
		if (( in_redirection == 0 ))
		then
			this_word=$next_word 
			next_word=':regular:' 
		elif (( !in_param ))
		then
			(( --in_redirection ))
		fi
		style=unknown-token 
		if [[ $this_word == *':start:'* ]]
		then
			in_array_assignment=false 
			if [[ $arg == 'noglob' ]]
			then
				highlight_glob=false 
			fi
		fi
		if (( $#in_alias == 0 && in_param == 0 ))
		then
			[[ "$proc_buf" = (#b)(#s)(''([ $'\t']|[\\]$'\n')#)(?|)* ]]
			integer offset="${#match[1]}" 
			(( start_pos = end_pos + offset ))
			(( end_pos = start_pos + $#arg ))
			[[ $arg == ';' && ${match[3]} == $'\n' ]] && arg=$'\n' 
			proc_buf="${proc_buf[offset + $#arg + 1,len]}" 
		fi
		if [[ $zsyh_user_options[interactivecomments] == on && $arg[1] == $histchars[3] ]]
		then
			if [[ $this_word == *(':regular:'|':start:')* ]]
			then
				style=comment 
			else
				style=unknown-token 
			fi
			_zsh_highlight_main_add_region_highlight $start_pos $end_pos $style
			in_redirection=1 
			continue
		fi
		if [[ $this_word == *':start:'* ]] && ! (( in_redirection ))
		then
			_zsh_highlight_main__type "$arg" "$(( ! ${+seen_alias[$arg]} ))"
			local res="$REPLY" 
			if [[ $res == "alias" ]]
			then
				if [[ $arg == ?*=* ]]
				then
					_zsh_highlight_main_add_region_highlight $start_pos $end_pos unknown-token
					continue
				fi
				seen_alias[$arg]=$#in_alias 
				_zsh_highlight_main__resolve_alias $arg
				local -a alias_args
				if [[ $zsyh_user_options[interactivecomments] == on ]]
				then
					alias_args=(${(zZ+c+)REPLY}) 
				else
					alias_args=(${(z)REPLY}) 
				fi
				args=($alias_args $args) 
				if (( $#in_alias == 0 ))
				then
					alias_style=alias 
				else
					(( in_alias[1]-- ))
				fi
				in_alias=($(($#alias_args + 1)) $in_alias) 
				(( in_redirection++ ))
				continue
			else
				_zsh_highlight_main_highlighter_expand_path $arg
				_zsh_highlight_main__type "$REPLY" 0
				res="$REPLY" 
			fi
		fi
		if _zsh_highlight_main__is_redirection $arg
		then
			if (( in_redirection == 1 ))
			then
				_zsh_highlight_main_add_region_highlight $start_pos $end_pos unknown-token
			else
				in_redirection=2 
				_zsh_highlight_main_add_region_highlight $start_pos $end_pos redirection
			fi
			continue
		elif [[ $arg == '{'${~parameter_name_pattern}'}' ]] && _zsh_highlight_main__is_redirection $args[1]
		then
			in_redirection=3 
			_zsh_highlight_main_add_region_highlight $start_pos $end_pos named-fd
			continue
		fi
		if (( ! in_param )) && _zsh_highlight_main_highlighter__try_expand_parameter "$arg"
		then
			() {
				local -a words
				words=("${reply[@]}") 
				if (( $#words == 0 )) && (( ! in_redirection ))
				then
					(( ++in_redirection ))
					_zsh_highlight_main_add_region_highlight $start_pos $end_pos comment
					continue
				else
					(( in_param = 1 + $#words ))
					args=($words $args) 
					arg=$args[1] 
					_zsh_highlight_main__type "$arg" 0
					res=$REPLY 
				fi
			}
		fi
		if (( ! in_redirection ))
		then
			if [[ $this_word == *':sudo_opt:'* ]]
			then
				if [[ -n $flags_with_argument ]] && {
						if [[ -n $flags_sans_argument ]]
						then
							[[ $arg == '-'[$flags_sans_argument]#[$flags_with_argument] ]]
						else
							[[ $arg == '-'[$flags_with_argument] ]]
						fi
					}
				then
					this_word=${this_word//:start:/} 
					next_word=':sudo_arg:' 
				elif [[ -n $flags_with_argument ]] && {
						if [[ -n $flags_sans_argument ]]
						then
							[[ $arg == '-'[$flags_sans_argument]#[$flags_with_argument]* ]]
						else
							[[ $arg == '-'[$flags_with_argument]* ]]
						fi
					}
				then
					this_word=${this_word//:start:/} 
					next_word+=':start:' 
					next_word+=':sudo_opt:' 
				elif [[ -n $flags_sans_argument ]] && [[ $arg == '-'[$flags_sans_argument]# ]]
				then
					this_word=':sudo_opt:' 
					next_word+=':start:' 
					next_word+=':sudo_opt:' 
				elif [[ -n $flags_solo ]] && {
						if [[ -n $flags_sans_argument ]]
						then
							[[ $arg == '-'[$flags_sans_argument]#[$flags_solo]* ]]
						else
							[[ $arg == '-'[$flags_solo]* ]]
						fi
					}
				then
					this_word=':sudo_opt:' 
					next_word=':regular:' 
				elif [[ $arg == '-'* ]]
				then
					this_word=':sudo_opt:' 
					next_word+=':start:' 
					next_word+=':sudo_opt:' 
				else
					this_word=${this_word//:sudo_opt:/} 
				fi
			elif [[ $this_word == *':sudo_arg:'* ]]
			then
				next_word+=':sudo_opt:' 
				next_word+=':start:' 
			fi
		fi
		if [[ -n ${(M)ZSH_HIGHLIGHT_TOKENS_COMMANDSEPARATOR:#"$arg"} ]] && [[ $braces_stack != *T* || $arg != ('||'|'&&') ]]
		then
			if _zsh_highlight_main__stack_pop T || _zsh_highlight_main__stack_pop Q
			then
				style=unknown-token 
			elif $in_array_assignment
			then
				case $arg in
					($'\n') style=commandseparator  ;;
					(';') style=unknown-token  ;;
					(*) style=unknown-token  ;;
				esac
			elif [[ $this_word == *':regular:'* ]]
			then
				style=commandseparator 
			elif [[ $this_word == *':start:'* ]] && [[ $arg == $'\n' ]]
			then
				style=commandseparator 
			elif [[ $this_word == *':start:'* ]] && [[ $arg == ';' ]] && (( $#in_alias ))
			then
				style=commandseparator 
			else
				style=unknown-token 
			fi
			if [[ $arg == $'\n' ]] && $in_array_assignment
			then
				next_word=':regular:' 
			elif [[ $arg == ';' ]] && $in_array_assignment
			then
				next_word=':regular:' 
			else
				next_word=':start:' 
				highlight_glob=true 
				saw_assignment=false 
				() {
					local alias_name
					for alias_name in ${(k)seen_alias[(R)<$#in_alias->]}
					do
						seen_alias=("${(@kv)seen_alias[(I)^$alias_name]}") 
					done
				}
				if [[ $arg != '|' && $arg != '|&' ]]
				then
					next_word+=':start_of_pipeline:' 
				fi
			fi
		elif ! (( in_redirection)) && [[ $this_word == *':always:'* && $arg == 'always' ]]
		then
			style=reserved-word 
			highlight_glob=true 
			saw_assignment=false 
			next_word=':start::start_of_pipeline:' 
		elif ! (( in_redirection)) && [[ $this_word == *':start:'* ]]
		then
			if (( ${+precommand_options[$arg]} )) && _zsh_highlight_main__is_runnable $arg
			then
				style=precommand 
				() {
					set -- "${(@s.:.)precommand_options[$arg]}"
					flags_with_argument=$1 
					flags_sans_argument=$2 
					flags_solo=$3 
				}
				next_word=${next_word//:regular:/} 
				next_word+=':sudo_opt:' 
				next_word+=':start:' 
				if [[ $arg == 'exec' || $arg == 'env' ]]
				then
					next_word+=':regular:' 
				fi
			else
				case $res in
					(reserved) style=reserved-word 
						case $arg in
							(time|nocorrect) next_word=${next_word//:regular:/} 
								next_word+=':start:'  ;;
							($'\x7b') braces_stack='Y'"$braces_stack"  ;;
							($'\x7d') _zsh_highlight_main__stack_pop 'Y' reserved-word
								if [[ $style == reserved-word ]]
								then
									next_word+=':always:' 
								fi ;;
							($'\x5b\x5b') braces_stack='T'"$braces_stack"  ;;
							('do') braces_stack='D'"$braces_stack"  ;;
							('done') _zsh_highlight_main__stack_pop 'D' reserved-word ;;
							('if') braces_stack=':?'"$braces_stack"  ;;
							('then') _zsh_highlight_main__stack_pop ':' reserved-word ;;
							('elif') if [[ ${braces_stack[1]} == '?' ]]
								then
									braces_stack=':'"$braces_stack" 
								else
									style=unknown-token 
								fi ;;
							('else') if [[ ${braces_stack[1]} == '?' ]]
								then
									:
								else
									style=unknown-token 
								fi ;;
							('fi') _zsh_highlight_main__stack_pop '?' ;;
							('foreach') braces_stack='$'"$braces_stack"  ;;
							('end') _zsh_highlight_main__stack_pop '$' reserved-word ;;
							('repeat') in_redirection=2 
								this_word=':start::regular:'  ;;
							('!') if [[ $this_word != *':start_of_pipeline:'* ]]
								then
									style=unknown-token 
								else
									
								fi ;;
						esac
						if $saw_assignment && [[ $style != unknown-token ]]
						then
							style=unknown-token 
						fi ;;
					('suffix alias') style=suffix-alias  ;;
					('global alias') style=global-alias  ;;
					(alias) : ;;
					(builtin) style=builtin 
						[[ $arg == $'\x5b' ]] && braces_stack='Q'"$braces_stack"  ;;
					(function) style=function  ;;
					(command) style=command  ;;
					(hashed) style=hashed-command  ;;
					(none) if (( ! in_param )) && _zsh_highlight_main_highlighter_check_assign
						then
							_zsh_highlight_main_add_region_highlight $start_pos $end_pos assign
							local i=$(( arg[(i)=] + 1 )) 
							saw_assignment=true 
							if [[ $arg[i] == '(' ]]
							then
								in_array_assignment=true 
								_zsh_highlight_main_add_region_highlight start_pos+i-1 start_pos+i reserved-word
							else
								next_word+=':start:' 
								if (( i <= $#arg ))
								then
									() {
										local highlight_glob=false 
										[[ $zsyh_user_options[globassign] == on ]] && highlight_glob=true 
										_zsh_highlight_main_highlighter_highlight_argument $i
									}
								fi
							fi
							continue
						elif (( ! in_param )) && [[ $arg[0,1] = $histchars[0,1] ]] && (( $#arg[0,2] == 2 ))
						then
							style=history-expansion 
						elif (( ! in_param )) && [[ $arg[0,1] == $histchars[2,2] ]]
						then
							style=history-expansion 
						elif (( ! in_param )) && ! $saw_assignment && [[ $arg[1,2] == '((' ]]
						then
							_zsh_highlight_main_add_region_highlight $start_pos $((start_pos + 2)) reserved-word
							if [[ $arg[-2,-1] == '))' ]]
							then
								_zsh_highlight_main_add_region_highlight $((end_pos - 2)) $end_pos reserved-word
							fi
							continue
						elif (( ! in_param )) && [[ $arg == '()' ]]
						then
							style=reserved-word 
						elif (( ! in_param )) && ! $saw_assignment && [[ $arg == $'\x28' ]]
						then
							style=reserved-word 
							braces_stack='R'"$braces_stack" 
						elif (( ! in_param )) && [[ $arg == $'\x29' ]]
						then
							if _zsh_highlight_main__stack_pop 'S'
							then
								REPLY=$start_pos 
								reply=($list_highlights) 
								return 0
							fi
							_zsh_highlight_main__stack_pop 'R' reserved-word
						else
							if _zsh_highlight_main_highlighter_check_path $arg 1
							then
								style=$REPLY 
							else
								style=unknown-token 
							fi
						fi ;;
					(*) _zsh_highlight_main_add_region_highlight $start_pos $end_pos arg0_$res
						continue ;;
				esac
			fi
			if [[ -n ${(M)ZSH_HIGHLIGHT_TOKENS_CONTROL_FLOW:#"$arg"} ]]
			then
				next_word=':start::start_of_pipeline:' 
			fi
		elif _zsh_highlight_main__is_global_alias "$arg"
		then
			style=global-alias 
		else
			case $arg in
				($'\x29') if $in_array_assignment
					then
						_zsh_highlight_main_add_region_highlight $start_pos $end_pos assign
						_zsh_highlight_main_add_region_highlight $start_pos $end_pos reserved-word
						in_array_assignment=false 
						next_word+=':start:' 
						continue
					elif (( in_redirection ))
					then
						style=unknown-token 
					else
						if _zsh_highlight_main__stack_pop 'S'
						then
							REPLY=$start_pos 
							reply=($list_highlights) 
							return 0
						fi
						_zsh_highlight_main__stack_pop 'R' reserved-word
					fi ;;
				($'\x28\x29') if (( in_redirection )) || $in_array_assignment
					then
						style=unknown-token 
					else
						if [[ $zsyh_user_options[multifuncdef] == on ]] || false
						then
							next_word+=':start::start_of_pipeline:' 
						fi
						style=reserved-word 
					fi ;;
				(*) if false
					then
						
					elif [[ $arg = $'\x7d' ]] && $right_brace_is_recognised_everywhere
					then
						if (( in_redirection )) || $in_array_assignment
						then
							style=unknown-token 
						else
							_zsh_highlight_main__stack_pop 'Y' reserved-word
							if [[ $style == reserved-word ]]
							then
								next_word+=':always:' 
							fi
						fi
					elif [[ $arg[0,1] = $histchars[0,1] ]] && (( $#arg[0,2] == 2 ))
					then
						style=history-expansion 
					elif [[ $arg == $'\x5d\x5d' ]] && _zsh_highlight_main__stack_pop 'T' reserved-word
					then
						:
					elif [[ $arg == $'\x5d' ]] && _zsh_highlight_main__stack_pop 'Q' builtin
					then
						:
					else
						_zsh_highlight_main_highlighter_highlight_argument 1 $(( 1 != in_redirection ))
						continue
					fi ;;
			esac
		fi
		_zsh_highlight_main_add_region_highlight $start_pos $end_pos $style
	done
	(( $#in_alias )) && in_alias=() _zsh_highlight_main_add_region_highlight $start_pos $end_pos $alias_style
	(( in_param == 1 )) && in_param=0 _zsh_highlight_main_add_region_highlight $start_pos $end_pos $param_style
	[[ "$proc_buf" = (#b)(#s)(([[:space:]]|\\$'\n')#) ]]
	REPLY=$(( end_pos + ${#match[1]} - 1 )) 
	reply=($list_highlights) 
	return $(( $#braces_stack > 0 ))
}
_zsh_highlight_main_highlighter_highlight_path_separators () {
	local pos style_pathsep
	style_pathsep=$1_pathseparator 
	reply=() 
	[[ -z "$ZSH_HIGHLIGHT_STYLES[$style_pathsep]" || "$ZSH_HIGHLIGHT_STYLES[$1]" == "$ZSH_HIGHLIGHT_STYLES[$style_pathsep]" ]] && return 0
	for ((pos = start_pos; $pos <= end_pos; pos++ )) do
		if [[ $BUFFER[pos] == / ]]
		then
			reply+=($((pos - 1)) $pos $style_pathsep) 
		fi
	done
}
_zsh_highlight_main_highlighter_highlight_single_quote () {
	local arg1=$1 i q=\' style 
	i=$arg[(ib:arg1+1:)$q] 
	reply=() 
	if [[ $zsyh_user_options[rcquotes] == on ]]
	then
		while [[ $arg[i+1] == "'" ]]
		do
			reply+=($(( start_pos + i - 1 )) $(( start_pos + i + 1 )) rc-quote) 
			(( i++ ))
			i=$arg[(ib:i+1:)$q] 
		done
	fi
	if [[ $arg[i] == "'" ]]
	then
		style=single-quoted-argument 
	else
		(( i-- ))
		style=single-quoted-argument-unclosed 
	fi
	reply=($(( start_pos + arg1 - 1 )) $(( start_pos + i )) $style $reply) 
	REPLY=$i 
}
_zsh_highlight_pattern_highlighter_loop () {
	local buf="$1" pat="$2" 
	local -a match mbegin mend
	local MATCH
	integer MBEGIN MEND
	if [[ "$buf" == (#b)(*)(${~pat})* ]]
	then
		region_highlight+=("$((mbegin[2] - 1)) $mend[2] $ZSH_HIGHLIGHT_PATTERNS[$pat], memo=zsh-syntax-highlighting") 
		"$0" "$match[1]" "$pat"
		return $?
	fi
}
_zsh_highlight_preexec_hook () {
	typeset -g _ZSH_HIGHLIGHT_PRIOR_BUFFER= 
	typeset -gi _ZSH_HIGHLIGHT_PRIOR_CURSOR= 
}
_zsh_highlight_regexp_highlighter_loop () {
	local buf="$1" pat="$2" 
	integer OFFSET=0 
	local MATCH
	integer MBEGIN MEND
	local -a match mbegin mend
	while true
	do
		[[ "$buf" =~ "$pat" ]] || return
		region_highlight+=("$((MBEGIN - 1 + OFFSET)) $((MEND + OFFSET)) $ZSH_HIGHLIGHT_REGEXP[$pat], memo=zsh-syntax-highlighting") 
		buf="$buf[$(($MEND+1)),-1]" 
		OFFSET=$((MEND+OFFSET)) 
	done
}
_zsocket () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zstyle () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_ztodo () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
_zypper () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
add-zle-hook-widget () {
	# undefined
	builtin autoload -XU
}
add-zsh-hook () {
	emulate -L zsh
	local -a hooktypes
	hooktypes=(chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name) 
	local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	if (( list ))
	then
		typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local hook="${1}_functions" 
	local fn="$2" 
	if (( del ))
	then
		if (( ${(P)+hook} ))
		then
			if (( del == 2 ))
			then
				set -A $hook ${(P)hook:#${~fn}}
			else
				set -A $hook ${(P)hook:#$fn}
			fi
			if (( ! ${(P)#hook} ))
			then
				unset $hook
			fi
		fi
	else
		if (( ${(P)+hook} ))
		then
			if (( ${${(P)hook}[(I)$fn]} == 0 ))
			then
				typeset -ga $hook
				set -A $hook ${(P)hook} $fn
			fi
		else
			typeset -ga $hook
			set -A $hook $fn
		fi
		autoload $autoopts -- $fn
	fi
}
alias_value () {
	(( $+aliases[$1] )) && echo $aliases[$1]
}
azure_prompt_info () {
	return 1
}
bashcompinit () {
	# undefined
	builtin autoload -XUz
}
bracketed-paste-magic () {
	# undefined
	builtin autoload -XUz
}
build-fzf-tab-module () {
	{
		pushd -q $FZF_TAB_HOME/modules
		if -ftb-build-module $@
		then
			print -P "%F{green}%BThe module has been built successfully. Please restart zsh to apply it.%f%b"
		else
			print -P -u2 "%F{red}%BThe module building has failed. See the output above for details.%f%b"
			return 1
		fi
	} always {
		popd -q
	}
}
bzr_prompt_info () {
	local bzr_branch
	bzr_branch=$(bzr nick 2>/dev/null)  || return
	if [[ -n "$bzr_branch" ]]
	then
		local bzr_dirty="" 
		if [[ -n $(bzr status 2>/dev/null) ]]
		then
			bzr_dirty=" %{$fg[red]%}*%{$reset_color%}" 
		fi
		printf "%s%s%s%s" "$ZSH_THEME_SCM_PROMPT_PREFIX" "bzr::${bzr_branch##*:}" "$bzr_dirty" "$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}
chruby_prompt_info () {
	return 1
}
clipcopy () {
	unfunction clipcopy clippaste
	detect-clipboard || true
	"$0" "$@"
}
clippaste () {
	unfunction clipcopy clippaste
	detect-clipboard || true
	"$0" "$@"
}
colors () {
	emulate -L zsh
	typeset -Ag color colour
	color=(00 none 01 bold 02 faint 22 normal 03 italic 23 no-italic 04 underline 24 no-underline 05 blink 25 no-blink 07 reverse 27 no-reverse 08 conceal 28 no-conceal 30 black 40 bg-black 31 red 41 bg-red 32 green 42 bg-green 33 yellow 43 bg-yellow 34 blue 44 bg-blue 35 magenta 45 bg-magenta 36 cyan 46 bg-cyan 37 white 47 bg-white 39 default 49 bg-default) 
	local k
	for k in ${(k)color}
	do
		color[${color[$k]}]=$k 
	done
	for k in ${color[(I)3?]}
	do
		color[fg-${color[$k]}]=$k 
	done
	for k in grey gray
	do
		color[$k]=${color[black]} 
		color[fg-$k]=${color[$k]} 
		color[bg-$k]=${color[bg-black]} 
	done
	colour=(${(kv)color}) 
	local lc=$'\e[' rc=m 
	typeset -Hg reset_color bold_color
	reset_color="$lc${color[none]}$rc" 
	bold_color="$lc${color[bold]}$rc" 
	typeset -AHg fg fg_bold fg_no_bold
	for k in ${(k)color[(I)fg-*]}
	do
		fg[${k#fg-}]="$lc${color[$k]}$rc" 
		fg_bold[${k#fg-}]="$lc${color[bold]};${color[$k]}$rc" 
		fg_no_bold[${k#fg-}]="$lc${color[normal]};${color[$k]}$rc" 
	done
	typeset -AHg bg bg_bold bg_no_bold
	for k in ${(k)color[(I)bg-*]}
	do
		bg[${k#bg-}]="$lc${color[$k]}$rc" 
		bg_bold[${k#bg-}]="$lc${color[bold]};${color[$k]}$rc" 
		bg_no_bold[${k#bg-}]="$lc${color[normal]};${color[$k]}$rc" 
	done
}
command_not_found_handler () {
	if [[ "$1" != "mise" && "$1" != "mise-"* ]] && /Users/steve.briggs/.local/bin/mise hook-not-found -s zsh -- "$1"
	then
		_mise_hook
		"$@"
	elif [ -n "$(declare -f _command_not_found_handler)" ]
	then
		_command_not_found_handler "$@"
	else
		echo "zsh: command not found: $1" >&2
		return 127
	fi
}
compadd () {
	local -A apre hpre dscrs _oad _mesg
	local -a isfile _opts __ expl
	zparseopts -a _opts P:=apre p:=hpre d:=dscrs X+:=expl O:=_oad A:=_oad D:=_oad f=isfile i: S: s: I: x:=_mesg r: R: W: F: M+: E: q e Q n U C J:=__ V:=__ a=__ l=__ k=__ o::=__ 1=__ 2=__
	_ftb_curcontext=${curcontext#:} 
	if (( $#_oad != 0 || ! IN_FZF_TAB )) || {
			-ftb-zstyle -m disabled-on "any"
		} || (
			{
				-ftb-zstyle -m disabled-on "files"
			} && [[ -n $isfile ]]
		)
	then
		builtin compadd "$@"
		return
	fi
	local -a __hits __dscr
	if (( $#dscrs == 1 ))
	then
		__dscr=("${(@P)${(v)dscrs}}") 
	fi
	builtin compadd -A __hits -D __dscr "$@"
	local ret=$? 
	if (( $#__hits == 0 ))
	then
		if is-at-least 5.9 && (( $#_mesg != 0 ))
		then
			builtin compadd -x $_mesg
		fi
		return $ret
	fi
	expl=$expl[2] 
	[[ -n $expl ]] && _ftb_groups+=$expl 
	local -a keys=(apre hpre PREFIX SUFFIX IPREFIX ISUFFIX) 
	local key expanded __tmp_value=$'<\0>' 
	for key in $keys
	do
		expanded=${(P)key} 
		if [[ -n $expanded ]]
		then
			__tmp_value+=$'\0'$key$'\0'$expanded 
		fi
	done
	if [[ -n $expl ]]
	then
		__tmp_value+=$'\0group\0'$_ftb_groups[(ie)$expl] 
	fi
	if [[ -n $isfile ]]
	then
		__tmp_value+=$'\0realdir\0'${${(Qe)~${:-$IPREFIX$hpre}}} 
	fi
	_opts+=("${(@kv)apre}" "${(@kv)hpre}" $isfile) 
	__tmp_value+=$'\0args\0'${(pj:\1:)_opts} 
	if (( $+builtins[fzf-tab-compcap-generate] ))
	then
		fzf-tab-compcap-generate __hits __dscr __tmp_value
	else
		local dscr word i
		for i in {1..$#__hits}
		do
			word=$__hits[i] dscr=$__dscr[i] 
			if [[ -n $dscr ]]
			then
				dscr=${dscr//$'\n'} 
			elif [[ -n $word ]]
			then
				dscr=$word 
			fi
			_ftb_compcap+=$dscr$'\2'$__tmp_value$'\0word\0'$word 
		done
	fi
	builtin compadd "$@"
}
compaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz
}
compgen () {
	local opts prefix suffix job OPTARG OPTIND ret=1 
	local -a name res results jids
	local -A shortopts
	emulate -L sh
	setopt kshglob noshglob braceexpand nokshautoload
	shortopts=(a alias b builtin c command d directory e export f file g group j job k keyword u user v variable) 
	while getopts "o:A:G:C:F:P:S:W:X:abcdefgjkuv" name
	do
		case $name in
			([abcdefgjkuv]) OPTARG="${shortopts[$name]}"  ;&
			(A) case $OPTARG in
					(alias) results+=("${(k)aliases[@]}")  ;;
					(arrayvar) results+=("${(k@)parameters[(R)array*]}")  ;;
					(binding) results+=("${(k)widgets[@]}")  ;;
					(builtin) results+=("${(k)builtins[@]}" "${(k)dis_builtins[@]}")  ;;
					(command) results+=("${(k)commands[@]}" "${(k)aliases[@]}" "${(k)builtins[@]}" "${(k)functions[@]}" "${(k)reswords[@]}")  ;;
					(directory) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N-/)) 
						setopt nobareglobqual ;;
					(disabled) results+=("${(k)dis_builtins[@]}")  ;;
					(enabled) results+=("${(k)builtins[@]}")  ;;
					(export) results+=("${(k)parameters[(R)*export*]}")  ;;
					(file) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N)) 
						setopt nobareglobqual ;;
					(function) results+=("${(k)functions[@]}")  ;;
					(group) emulate zsh
						_groups -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(hostname) emulate zsh
						_hosts -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(job) results+=("${savejobtexts[@]%% *}")  ;;
					(keyword) results+=("${(k)reswords[@]}")  ;;
					(running) jids=("${(@k)savejobstates[(R)running*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(stopped) jids=("${(@k)savejobstates[(R)suspended*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(setopt | shopt) results+=("${(k)options[@]}")  ;;
					(signal) results+=("SIG${^signals[@]}")  ;;
					(user) results+=("${(k)userdirs[@]}")  ;;
					(variable) results+=("${(k)parameters[@]}")  ;;
					(helptopic)  ;;
				esac ;;
			(F) COMPREPLY=() 
				local -a args
				args=("${words[0]}" "${@[-1]}" "${words[CURRENT-2]}") 
				() {
					typeset -h words
					$OPTARG "${args[@]}"
				}
				results+=("${COMPREPLY[@]}")  ;;
			(G) setopt nullglob
				results+=(${~OPTARG}) 
				unsetopt nullglob ;;
			(W) results+=(${(Q)~=OPTARG})  ;;
			(C) results+=($(eval $OPTARG))  ;;
			(P) prefix="$OPTARG"  ;;
			(S) suffix="$OPTARG"  ;;
			(X) if [[ ${OPTARG[0]} = '!' ]]
				then
					results=("${(M)results[@]:#${OPTARG#?}}") 
				else
					results=("${results[@]:#$OPTARG}") 
				fi ;;
		esac
	done
	print -l -r -- "$prefix${^results[@]}$suffix"
}
compinit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
complete () {
	emulate -L zsh
	local args void cmd print remove
	args=("$@") 
	zparseopts -D -a void o: A: G: W: C: F: P: S: X: a b c d e f g j k u v p=print r=remove
	if [[ -n $print ]]
	then
		printf 'complete %2$s %1$s\n' "${(@kv)_comps[(R)_bash*]#* }"
	elif [[ -n $remove ]]
	then
		for cmd
		do
			unset "_comps[$cmd]"
		done
	else
		compdef _bash_complete\ ${(j. .)${(q)args[1,-1-$#]}} "$@"
	fi
}
conda_prompt_info () {
	return 1
}
d () {
	if [[ -n $1 ]]
	then
		dirs "$@"
	else
		dirs -v | head -n 10
	fi
}
default () {
	(( $+parameters[$1] )) && return 0
	typeset -g "$1"="$2" && return 3
}
detect-clipboard () {
	emulate -L zsh
	if [[ "${OSTYPE}" == darwin* ]] && (( ${+commands[pbcopy]} )) && (( ${+commands[pbpaste]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | pbcopy
		}
		clippaste () {
			pbpaste
		}
	elif [[ "${OSTYPE}" == (cygwin|msys)* ]]
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" > /dev/clipboard
		}
		clippaste () {
			cat /dev/clipboard
		}
	elif (( $+commands[clip.exe] )) && (( $+commands[powershell.exe] ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | clip.exe
		}
		clippaste () {
			powershell.exe -noprofile -command Get-Clipboard
		}
	elif [ -n "${WAYLAND_DISPLAY:-}" ] && (( ${+commands[wl-copy]} )) && (( ${+commands[wl-paste]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | wl-copy &> /dev/null &|
		}
		clippaste () {
			wl-paste --no-newline
		}
	elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xsel]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | xsel --clipboard --input
		}
		clippaste () {
			xsel --clipboard --output
		}
	elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xclip]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | xclip -selection clipboard -in &> /dev/null &|
		}
		clippaste () {
			xclip -out -selection clipboard
		}
	elif (( ${+commands[lemonade]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | lemonade copy
		}
		clippaste () {
			lemonade paste
		}
	elif (( ${+commands[doitclient]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | doitclient wclip
		}
		clippaste () {
			doitclient wclip -r
		}
	elif (( ${+commands[win32yank]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | win32yank -i
		}
		clippaste () {
			win32yank -o
		}
	elif [[ $OSTYPE == linux-android* ]] && (( $+commands[termux-clipboard-set] ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | termux-clipboard-set
		}
		clippaste () {
			termux-clipboard-get
		}
	elif [ -n "${TMUX:-}" ] && (( ${+commands[tmux]} ))
	then
		clipcopy () {
			tmux load-buffer -w "${1:--}"
		}
		clippaste () {
			tmux save-buffer -
		}
	else
		_retry_clipboard_detection_or_fail () {
			local clipcmd="${1}" 
			shift
			if detect-clipboard
			then
				"${clipcmd}" "$@"
			else
				print "${clipcmd}: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
				return 1
			fi
		}
		clipcopy () {
			_retry_clipboard_detection_or_fail clipcopy "$@"
		}
		clippaste () {
			_retry_clipboard_detection_or_fail clippaste "$@"
		}
		return 1
	fi
}
diff () {
	command diff --color "$@"
}
disable-fzf-tab () {
	emulate -L zsh -o extended_glob
	(( $+_ftb_orig_widget )) || return 0
	bindkey '^I' $_ftb_orig_widget
	case $_ftb_orig_list_grouped in
		(0) zstyle ':completion:*' list-grouped false ;;
		(1) zstyle ':completion:*' list-grouped true ;;
		(2) zstyle -d ':completion:*' list-grouped ;;
	esac
	unset _ftb_orig_widget _ftb_orig_list_groupded
	unfunction compadd 2> /dev/null
	functions[_main_complete]=$functions[_ftb__main_complete] 
	functions[_approximate]=$functions[_ftb__approximate] 
}
down-line-or-beginning-search () {
	# undefined
	builtin autoload -XU
}
edit-command-line () {
	# undefined
	builtin autoload -XU
}
enable-fzf-tab () {
	emulate -L zsh -o extended_glob
	(( ! $+_ftb_orig_widget )) || disable-fzf-tab
	typeset -g _ftb_orig_widget="${${$(builtin bindkey '^I')##* }:-expand-or-complete}" 
	if (( ! $+widgets[.fzf-tab-orig-$_ftb_orig_widget] ))
	then
		local compinit_widgets=(complete-word delete-char-or-list expand-or-complete expand-or-complete-prefix list-choices menu-complete menu-expand-or-complete reverse-menu-complete) 
		if [[ $widgets[$_ftb_orig_widget] == builtin && $compinit_widgets[(Ie)$_ftb_orig_widget] != 0 ]]
		then
			zle -C .fzf-tab-orig-$_ftb_orig_widget .$_ftb_orig_widget _main_complete
		else
			zle -A $_ftb_orig_widget .fzf-tab-orig-$_ftb_orig_widget
		fi
	fi
	zstyle -t ':completion:*' list-grouped false
	typeset -g _ftb_orig_list_grouped=$? 
	zstyle ':completion:*' list-grouped false
	bindkey -M emacs '^I' fzf-tab-complete
	bindkey -M viins '^I' fzf-tab-complete
	bindkey -M emacs '^X.' fzf-tab-debug
	bindkey -M viins '^X.' fzf-tab-debug
	autoload +X -Uz _main_complete _approximate
	functions[compadd]=$functions[-ftb-compadd] 
	functions[_ftb__main_complete]=$functions[_main_complete] 
	_main_complete () {
		-ftb-complete "$@"
	}
	functions[_ftb__approximate]=$functions[_approximate] 
	_approximate () {
		(( ! IN_FZF_TAB )) || unfunction compadd
		_ftb__approximate
		(( ! IN_FZF_TAB )) || functions[compadd]=$functions[-ftb-compadd] 
	}
}
env_default () {
	[[ ${parameters[$1]} = *-export* ]] && return 0
	export "$1=$2" && return 3
}
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
			grep --color=auto --color -l "$FIND" | xargs sed -i "s/${FIND}/${REPLACE}/g"
		else
			grep --color=auto --color -l "$FIND" | grep --color=auto --color -i "$FILTER" | xargs sed -i "s/${FIND}/${REPLACE}/g"
		fi
	fi
}
ftb-switch-group () {
	# undefined
	builtin autoload -XUz
}
ftb-tmux-popup () {
	# undefined
	builtin autoload -XUz
}
fzf-tab-complete () {
	local -i _ftb_continue=1 _ftb_continue_last=0 _ftb_accept=0 ret=0 
	echoti civis > /dev/tty 2> /dev/null
	while (( _ftb_continue ))
	do
		local _ftb_choices=() _ftb_compcap=() _ftb_finish=0 
		_ftb_continue=0 
		local IN_FZF_TAB=1 
		{
			zle .fzf-tab-orig-$_ftb_orig_widget || ret=$? 
			if (( ! ret && ! _ftb_finish ))
			then
				zle _fzf-tab-apply || ret=$? 
			fi
		} always {
			IN_FZF_TAB=0 
		}
		if (( _ftb_continue ))
		then
			zle .split-undo
			zle .reset-prompt
			zle -R
			zle fzf-tab-dummy
		fi
	done
	echoti cnorm > /dev/tty 2> /dev/null
	zle .redisplay
	(( _ftb_accept )) && zle .accept-line
	return $ret
}
fzf-tab-debug () {
	(( $+_ftb_debug_cnt )) || typeset -gi _ftb_debug_cnt
	local tmp=${TMPPREFIX:-/tmp/zsh}-$$-fzf-tab-$(( ++_ftb_debug_cnt )).log 
	local -i debug_fd=-1 IN_FZF_TAB=1 
	{
		exec {debug_fd}>&2 2>| $tmp
		local -a debug_indent
		debug_indent=('%'{3..20}'(e. .)') 
		local PROMPT4 PS4="${(j::)debug_indent}+%N:%i> " 
		functions -t -- -ftb-complete _fzf-tab-apply fzf-tab-complete
		{
			echo $ZSH_NAME $ZSH_VERSION
			echo fzf-tab: $(-ftb-version)
			typeset -p FZF_DEFAULT_OPTS
			echo $commands[fzf] $(fzf --version)
		} >&2
		zle fzf-tab-complete
		if (( debug_fd != -1 ))
		then
			zle -M "fzf-tab-debug: Trace output left in $tmp"
		fi
	} always {
		functions +t -- -ftb-complete _fzf-tab-apply fzf-tab-complete
		(( debug_fd != -1 )) && exec 2>&$debug_fd {debug_fd}>&-
	}
}
fzf-tab-dummy () {
	
}
fzf-tab-lscolors::from-mode () {
	emulate -L zsh
	setopt cbases octalzeroes extendedglob
	[[ -z $2 ]] && return 1
	local -i reg=0 
	local -a codes
	local -i st_mode=$(($2)) 
	case $(( st_mode & 0170000 )) in
		($(( 0140000 ))) codes=($modecolors[so])  ;;
		($(( 0120000 ))) if ! (($+3))
			then
				REPLY=$modecolors[or] 
			elif [[ $modecolors[ln] = target ]]
			then
				"$0" "$1" "${@:3}"
			else
				REPLY=$modecolors[ln] 
			fi
			return ;;
		($(( 0100000 ))) codes=() 
			reg=1  ;;
		($(( 0060000 ))) codes=($modecolors[bd])  ;;
		($(( 0040000 ))) codes=($modecolors[di])  ;;
		($(( 0020000 ))) codes=($modecolors[cd])  ;;
		($(( 0010000 ))) codes=($modecolors[pi])  ;;
	esac
	(( st_mode & 04000 )) && codes+=($modecolors[su]) 
	(( st_mode & 02000 )) && codes+=($modecolors[sg]) 
	(( ! reg )) && case $(( st_mode & 01002 )) in
		($(( 01000 ))) codes+=($modecolors[st])  ;;
		($(( 00002 ))) codes+=($modecolors[ow])  ;;
		($(( 01002 ))) codes+=($modecolors[tw])  ;;
	esac
	if (( ! $#codes ))
	then
		(( st_mode &  0111 )) && codes+=($modecolors[ex]) 
	fi
	[[ -n ${REPLY::=${(j:;:)codes}} ]]
}
fzf-tab-lscolors::from-name () {
	emulate -L zsh
	setopt extendedglob
	[[ -n ${REPLY::=$namecolors[(k)$1]} ]]
}
fzf-tab-lscolors::init () {
	emulate -L zsh
	local LS_COLORS=${1:-${LS_COLORS:-$LSCOLORS}} 
	typeset -gA namecolors=(${(@s:=:)${(@s.:.)LS_COLORS}:#[[:alpha:]][[:alpha:]]=*}) 
	typeset -gA modecolors=(${(@Ms:=:)${(@s.:.)LS_COLORS}:#[[:alpha:]][[:alpha:]]=*}) 
}
fzf-tab-lscolors::match-by () {
	emulate -L zsh
	setopt extendedglob cbases octalzeroes
	local arg REPLY name=$1 pfx=${0%::match-by} 
	shift
	if ! [[ -v namecolors && -v modecolors ]]
	then
		local -A namecolors modecolors
		${pfx}::init
	fi
	if [[ ${1:l} = (g|global) ]]
	then
		shift
	else
		local -a stat lstat
		declare -ga reply=() 
	fi
	zmodload -F zsh/stat b:zstat
	for arg
	do
		case ${arg[1]:l} in
			(n | name) ${pfx}::from-name $name
				reply+=("$REPLY")  ;;
			(l | lstat) (($#lstat)) || zstat -A lstat -L $name || return 1
				if ((lstat[3] & 0170000 ))
				then
					(($#stat)) || zstat -A stat $name 2> /dev/null
				fi
				${pfx}::from-mode "$name" "$lstat[3]" $stat[3]
				if [[ -n $REPLY || ${2[1]} = L ]]
				then
					reply+=("$REPLY") 
				else
					"$0" "$name" g n
				fi ;;
			(s | stat) (($#stat)) || zstat -A stat $name || return 1
				${pfx}::from-mode $name $stat[3]
				reply+=("$REPLY") 
				if [[ -n $REPLY || ${arg[1]} = S ]]
				then
					reply+=("$REPLY") 
				else
					"$0" "$name" g n
				fi ;;
			(f | follow) (($#lstat)) || zstat -A lstat -L $name || return 1
				reply+=("$lstat[14]")  ;;
			(a | all) "$0" "$name" g ${${${arg[1]%a}:+L}:-l}
				reply+=($lstat[14]) 
				if [[ -n $lstat[14] ]]
				then
					if [[ -e $name ]]
					then
						"$0" "$name" g ${${${arg[1]%a}:+S}:-s}
					else
						reply+=($reply[-2]) 
					fi
				fi ;;
			(*) return 2 ;;
		esac
	done
}
gbda () {
	git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2> /dev/null
}
gbds () {
	local default_branch=$(git_main_branch) 
	(( ! $? )) || default_branch=$(git_develop_branch) 
	git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch
	do
		local merge_base=$(git merge-base $default_branch $branch) 
		if [[ $(git cherry $default_branch $(git commit-tree $(git rev-parse $branch\^{tree}) -p $merge_base -m _)) = -* ]]
		then
			git branch -D $branch
		fi
	done
}
gccd () {
	setopt localoptions extendedglob
	local repo="${${@[(r)(ssh://*|git://*|ftp(s)#://*|http(s)#://*|*@*)(.git/#)#]}:-$_}" 
	command git clone --recurse-submodules "$@" || return
	[[ -d "$_" ]] && cd "$_" || cd "${${repo:t}%.git/#}"
}
gdnolock () {
	git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}
gdv () {
	git diff -w "$@" | view -
}
getent () {
	if [[ $1 = hosts ]]
	then
		sed 's/#.*//' /etc/$1 | grep -w $2
	elif [[ $2 = <-> ]]
	then
		grep ":$2:[^:]*$" /etc/$1
	else
		grep "^$2:" /etc/$1
	fi
}
ggf () {
	local b
	[[ $# != 1 ]] && b="$(git_current_branch)" 
	git push --force origin "${b:-$1}"
}
ggfl () {
	local b
	[[ $# != 1 ]] && b="$(git_current_branch)" 
	git push --force-with-lease origin "${b:-$1}"
}
ggl () {
	if [[ $# != 0 ]] && [[ $# != 1 ]]
	then
		git pull origin "${*}"
	else
		local b
		[[ $# == 0 ]] && b="$(git_current_branch)" 
		git pull origin "${b:-$1}"
	fi
}
ggp () {
	if [[ $# != 0 ]] && [[ $# != 1 ]]
	then
		git push origin "${*}"
	else
		local b
		[[ $# == 0 ]] && b="$(git_current_branch)" 
		git push origin "${b:-$1}"
	fi
}
ggpnp () {
	if [[ $# == 0 ]]
	then
		ggl && ggp
	else
		ggl "${*}" && ggp "${*}"
	fi
}
ggu () {
	local b
	[[ $# != 1 ]] && b="$(git_current_branch)" 
	git pull --rebase origin "${b:-$1}"
}
git_commits_ahead () {
	if __git_prompt_git rev-parse --git-dir &> /dev/null
	then
		local commits="$(__git_prompt_git rev-list --count @{upstream}..HEAD 2>/dev/null)" 
		if [[ -n "$commits" && "$commits" != 0 ]]
		then
			echo "$ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX$commits$ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
		fi
	fi
}
git_commits_behind () {
	if __git_prompt_git rev-parse --git-dir &> /dev/null
	then
		local commits="$(__git_prompt_git rev-list --count HEAD..@{upstream} 2>/dev/null)" 
		if [[ -n "$commits" && "$commits" != 0 ]]
		then
			echo "$ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX$commits$ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX"
		fi
	fi
}
git_current_branch () {
	local ref
	ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null) 
	local ret=$? 
	if [[ $ret != 0 ]]
	then
		[[ $ret == 128 ]] && return
		ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  || return
	fi
	echo ${ref#refs/heads/}
}
git_current_user_email () {
	__git_prompt_git config user.email 2> /dev/null
}
git_current_user_name () {
	__git_prompt_git config user.name 2> /dev/null
}
git_develop_branch () {
	command git rev-parse --git-dir &> /dev/null || return
	local branch
	for branch in dev devel develop development
	do
		if command git show-ref -q --verify refs/heads/$branch
		then
			echo $branch
			return 0
		fi
	done
	echo develop
	return 1
}
git_main_branch () {
	command git rev-parse --git-dir &> /dev/null || return
	local remote ref
	for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}
	do
		if command git show-ref -q --verify $ref
		then
			echo ${ref:t}
			return 0
		fi
	done
	for remote in origin upstream
	do
		ref=$(command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null) 
		if [[ $ref == $remote/* ]]
		then
			echo ${ref#"$remote/"}
			return 0
		fi
	done
	echo master
	return 1
}
git_previous_branch () {
	local ref
	ref=$(__git_prompt_git rev-parse --quiet --symbolic-full-name @{-1} 2> /dev/null) 
	local ret=$? 
	if [[ $ret != 0 ]] || [[ -z $ref ]]
	then
		return
	fi
	echo ${ref#refs/heads/}
}
git_prompt_ahead () {
	if [[ -n "$(__git_prompt_git rev-list origin/$(git_current_branch)..HEAD 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
	fi
}
git_prompt_behind () {
	if [[ -n "$(__git_prompt_git rev-list HEAD..origin/$(git_current_branch) 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_BEHIND"
	fi
}
git_prompt_info () {
	if [[ -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_info]}" ]]
	then
		echo -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_info]}"
	fi
}
git_prompt_long_sha () {
	local SHA
	SHA=$(__git_prompt_git rev-parse HEAD 2> /dev/null)  && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}
git_prompt_remote () {
	if [[ -n "$(__git_prompt_git show-ref origin/$(git_current_branch) 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS"
	else
		echo "$ZSH_THEME_GIT_PROMPT_REMOTE_MISSING"
	fi
}
git_prompt_short_sha () {
	local SHA
	SHA=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}
git_prompt_status () {
	if [[ -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_status]}" ]]
	then
		echo -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_status]}"
	fi
}
git_remote_status () {
	local remote ahead behind git_remote_status git_remote_status_detailed
	remote=${$(__git_prompt_git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/} 
	if [[ -n ${remote} ]]
	then
		ahead=$(__git_prompt_git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l) 
		behind=$(__git_prompt_git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l) 
		if [[ $ahead -eq 0 ]] && [[ $behind -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE" 
		elif [[ $ahead -gt 0 ]] && [[ $behind -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}" 
		elif [[ $behind -gt 0 ]] && [[ $ahead -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}" 
		elif [[ $ahead -gt 0 ]] && [[ $behind -gt 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}" 
		fi
		if [[ -n $ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX${remote//\%/%%}$git_remote_status_detailed$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX" 
		fi
		echo $git_remote_status
	fi
}
git_repo_name () {
	local repo_path
	if repo_path="$(__git_prompt_git rev-parse --show-toplevel 2>/dev/null)"  && [[ -n "$repo_path" ]]
	then
		echo ${repo_path:t}
	fi
}
google () {
	open "https://www.google.com/search?q=`echo "${@}" | urlencode`"
}
grename () {
	if [[ -z "$1" || -z "$2" ]]
	then
		echo "Usage: $0 old_branch new_branch"
		return 1
	fi
	git branch -m "$1" "$2"
	if git push origin :"$1"
	then
		git push --set-upstream origin "$2"
	fi
}
gunwipall () {
	local _commit=$(git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H) 
	if [[ "$_commit" != "$(git rev-parse HEAD)" ]]
	then
		git reset $_commit || return 1
	fi
}
handle_completion_insecurities () {
	local -aU insecure_dirs
	insecure_dirs=(${(f@):-"$(compaudit 2>/dev/null)"}) 
	[[ -z "${insecure_dirs}" ]] && return
	print "[oh-my-zsh] Insecure completion-dependent directories detected:"
	ls -ld "${(@)insecure_dirs}"
	cat <<EOD

[oh-my-zsh] For safety, we will not load completions from these directories until
[oh-my-zsh] you fix their permissions and ownership and restart zsh.
[oh-my-zsh] See the above list for directories with group or other writability.

[oh-my-zsh] To fix your permissions you can do so by disabling
[oh-my-zsh] the write permission of "group" and "others" and making sure that the
[oh-my-zsh] owner of these directories is either root or your current user.
[oh-my-zsh] The following command may help:
[oh-my-zsh]     compaudit | xargs chmod g-w,o-w

[oh-my-zsh] If the above didn't help or you want to skip the verification of
[oh-my-zsh] insecure directories you can set the variable ZSH_DISABLE_COMPFIX to
[oh-my-zsh] "true" before oh-my-zsh is sourced in your zshrc file.

EOD
}
hg_prompt_info () {
	return 1
}
hred () {
	[ $# -ge 1 -a -f "$1" ] && input="$1"  || input="-" 
	cat $input | grep --color=auto -E -v '^\s*$|^\s*#.*$'
}
is-at-least () {
	emulate -L zsh
	local IFS=".-" min_cnt=0 ver_cnt=0 part min_ver version order 
	min_ver=(${=1}) 
	version=(${=2:-$ZSH_VERSION} 0) 
	while (( $min_cnt <= ${#min_ver} ))
	do
		while [[ "$part" != <-> ]]
		do
			(( ++ver_cnt > ${#version} )) && return 0
			if [[ ${version[ver_cnt]} = *[0-9][^0-9]* ]]
			then
				order=(${version[ver_cnt]} ${min_ver[ver_cnt]}) 
				if [[ ${version[ver_cnt]} = <->* ]]
				then
					[[ $order != ${${(On)order}} ]] && return 1
				else
					[[ $order != ${${(O)order}} ]] && return 1
				fi
				[[ $order[1] != $order[2] ]] && return 0
			fi
			part=${version[ver_cnt]##*[^0-9]} 
		done
		while true
		do
			(( ++min_cnt > ${#min_ver} )) && return 0
			[[ ${min_ver[min_cnt]} = <-> ]] && break
		done
		(( part > min_ver[min_cnt] )) && return 0
		(( part < min_ver[min_cnt] )) && return 1
		part='' 
	done
}
is_plugin () {
	local base_dir=$1 
	local name=$2 
	builtin test -f $base_dir/plugins/$name/$name.plugin.zsh || builtin test -f $base_dir/plugins/$name/_$name
}
is_theme () {
	local base_dir=$1 
	local name=$2 
	builtin test -f $base_dir/$name.zsh-theme
}
jenv_prompt_info () {
	return 1
}
kj () {
	kubectl "$@" -o json | jq
}
kjx () {
	kubectl "$@" -o json | fx
}
kres () {
	kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}
kutil () {
	for host in $(kubectl get nodes --no-headers | cut -d' ' -f1)
	do
		echo "$host - $(kubectl get nodes -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}' $host)"
		kubecolor describe node "$host" | grep --color=auto --color Allocated -A 5 | grep --color=auto --color -ve Event -ve Allocated -ve percent -ve --
		echo
	done
}
ky () {
	kubectl "$@" -o yaml | yh
}
mise () {
	local command
	command="${1:-}" 
	if [ "$#" = 0 ]
	then
		command /Users/steve.briggs/.local/bin/mise
		return
	fi
	shift
	case "$command" in
		(deactivate | shell | sh) if [[ ! " $@ " =~ " --help " ]] && [[ ! " $@ " =~ " -h " ]]
			then
				eval "$(command /Users/steve.briggs/.local/bin/mise "$command" "$@")"
				return $?
			fi ;;
	esac
	command /Users/steve.briggs/.local/bin/mise "$command" "$@"
}
mkcd () {
	mkdir -p $@ && cd ${@:$#}
}
nvm_prompt_info () {
	which nvm &> /dev/null || return
	local nvm_prompt=${$(nvm current)#v} 
	echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt:gs/%/%%}${ZSH_THEME_NVM_PROMPT_SUFFIX}"
}
omz () {
	setopt localoptions noksharrays
	[[ $# -gt 0 ]] || {
		_omz::help
		return 1
	}
	local command="$1" 
	shift
	(( ${+functions[_omz::$command]} )) || {
		_omz::help
		return 1
	}
	_omz::$command "$@"
}
omz_diagnostic_dump () {
	emulate -L zsh
	builtin echo "Generating diagnostic dump; please be patient..."
	local thisfcn=omz_diagnostic_dump 
	local -A opts
	local opt_verbose opt_noverbose opt_outfile
	local timestamp=$(date +%Y%m%d-%H%M%S) 
	local outfile=omz_diagdump_$timestamp.txt 
	builtin zparseopts -A opts -D -- "v+=opt_verbose" "V+=opt_noverbose"
	local verbose n_verbose=${#opt_verbose} n_noverbose=${#opt_noverbose} 
	(( verbose = 1 + n_verbose - n_noverbose ))
	if [[ ${#*} > 0 ]]
	then
		opt_outfile=$1 
	fi
	if [[ ${#*} > 1 ]]
	then
		builtin echo "$thisfcn: error: too many arguments" >&2
		return 1
	fi
	if [[ -n "$opt_outfile" ]]
	then
		outfile="$opt_outfile" 
	fi
	_omz_diag_dump_one_big_text &> "$outfile"
	if [[ $? != 0 ]]
	then
		builtin echo "$thisfcn: error while creating diagnostic dump; see $outfile for details"
	fi
	builtin echo
	builtin echo Diagnostic dump file created at: "$outfile"
	builtin echo
	builtin echo To share this with OMZ developers, post it as a gist on GitHub
	builtin echo at "https://gist.github.com" and share the link to the gist.
	builtin echo
	builtin echo "WARNING: This dump file contains all your zsh and omz configuration files,"
	builtin echo "so don't share it publicly if there's sensitive information in them."
	builtin echo
}
omz_history () {
	local clear list stamp REPLY
	zparseopts -E -D c=clear l=list f=stamp E=stamp i=stamp t:=stamp
	if [[ -n "$clear" ]]
	then
		print -nu2 "This action will irreversibly delete your command history. Are you sure? [y/N] "
		builtin read -E
		[[ "$REPLY" = [yY] ]] || return 0
		print -nu2 >| "$HISTFILE"
		fc -p "$HISTFILE"
		print -u2 History file deleted.
	elif [[ $# -eq 0 ]]
	then
		builtin fc "${stamp[@]}" -l 1
	else
		builtin fc "${stamp[@]}" -l "$@"
	fi
}
omz_termsupport_cwd () {
	setopt localoptions unset
	local URL_HOST URL_PATH
	URL_HOST="$(omz_urlencode -P $HOST)"  || return 1
	URL_PATH="$(omz_urlencode -P $PWD)"  || return 1
	[[ -z "$KONSOLE_PROFILE_NAME" && -z "$KONSOLE_DBUS_SESSION" ]] || URL_HOST="" 
	printf "\e]7;file://%s%s\e\\" "${URL_HOST}" "${URL_PATH}"
}
omz_termsupport_precmd () {
	[[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return 0
	title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"
}
omz_termsupport_preexec () {
	[[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return 0
	emulate -L zsh
	setopt extended_glob
	local -a cmdargs
	cmdargs=("${(z)2}") 
	if [[ "${cmdargs[1]}" = fg ]]
	then
		local job_id jobspec="${cmdargs[2]#%}" 
		case "$jobspec" in
			(<->) job_id=${jobspec}  ;;
			("" | % | +) job_id=${(k)jobstates[(r)*:+:*]}  ;;
			(-) job_id=${(k)jobstates[(r)*:-:*]}  ;;
			([?]*) job_id=${(k)jobtexts[(r)*${(Q)jobspec}*]}  ;;
			(*) job_id=${(k)jobtexts[(r)${(Q)jobspec}*]}  ;;
		esac
		if [[ -n "${jobtexts[$job_id]}" ]]
		then
			1="${jobtexts[$job_id]}" 
			2="${jobtexts[$job_id]}" 
		fi
	fi
	local CMD="${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}" 
	local LINE="${2:gs/%/%%}" 
	title "$CMD" "%100>...>${LINE}%<<"
}
omz_urldecode () {
	emulate -L zsh
	local encoded_url=$1 
	local caller_encoding=$langinfo[CODESET] 
	local LC_ALL=C 
	export LC_ALL
	local tmp=${encoded_url:gs/+/ /} 
	tmp=${tmp:gs/\\/\\\\/} 
	tmp=${tmp:gs/%/\\x/} 
	local decoded="$(printf -- "$tmp")" 
	local -a safe_encodings
	safe_encodings=(UTF-8 utf8 US-ASCII) 
	if [[ -z ${safe_encodings[(r)$caller_encoding]} ]]
	then
		decoded=$(echo -E "$decoded" | iconv -f UTF-8 -t $caller_encoding) 
		if [[ $? != 0 ]]
		then
			echo "Error converting string from UTF-8 to $caller_encoding" >&2
			return 1
		fi
	fi
	echo -E "$decoded"
}
omz_urlencode () {
	emulate -L zsh
	setopt norematchpcre
	local -a opts
	zparseopts -D -E -a opts r m P
	local in_str="$@" 
	local url_str="" 
	local spaces_as_plus
	if [[ -z $opts[(r)-P] ]]
	then
		spaces_as_plus=1 
	fi
	local str="$in_str" 
	local encoding=$langinfo[CODESET] 
	local safe_encodings
	safe_encodings=(UTF-8 utf8 US-ASCII) 
	if [[ -z ${safe_encodings[(r)$encoding]} ]]
	then
		str=$(echo -E "$str" | iconv -f $encoding -t UTF-8) 
		if [[ $? != 0 ]]
		then
			echo "Error converting string from $encoding to UTF-8" >&2
			return 1
		fi
	fi
	local i byte ord LC_ALL=C 
	export LC_ALL
	local reserved=';/?:@&=+$,' 
	local mark='_.!~*''()-' 
	local dont_escape="[A-Za-z0-9" 
	if [[ -z $opts[(r)-r] ]]
	then
		dont_escape+=$reserved 
	fi
	if [[ -z $opts[(r)-m] ]]
	then
		dont_escape+=$mark 
	fi
	dont_escape+="]" 
	local url_str="" 
	for ((i = 1; i <= ${#str}; ++i )) do
		byte="$str[i]" 
		if [[ "$byte" =~ "$dont_escape" ]]
		then
			url_str+="$byte" 
		else
			if [[ "$byte" == " " && -n $spaces_as_plus ]]
			then
				url_str+="+" 
			elif [[ "$PREFIX" = *com.termux* ]]
			then
				url_str+="$byte" 
			else
				ord=$(( [##16] #byte )) 
				url_str+="%$ord" 
			fi
		fi
	done
	echo -E "$url_str"
}
open_command () {
	local open_cmd
	case "$OSTYPE" in
		(darwin*) open_cmd='open'  ;;
		(cygwin*) open_cmd='cygstart'  ;;
		(linux*) [[ "$(uname -r)" != *icrosoft* ]] && open_cmd='nohup xdg-open'  || {
				open_cmd='cmd.exe /c start ""' 
				[[ -e "$1" ]] && {
					1="$(wslpath -w "${1:a}")"  || return 1
				}
				[[ "$1" = (http|https)://* ]] && {
					1="$(echo "$1" | sed -E 's/([&|()<>^])/^\1/g')"  || return 1
				}
			} ;;
		(msys*) open_cmd='start ""'  ;;
		(*) echo "Platform $OSTYPE not supported"
			return 1 ;;
	esac
	if [[ -n "$BROWSER" && "$1" = (http|https)://* ]]
	then
		"$BROWSER" "$@"
		return
	fi
	${=open_cmd} "$@" &> /dev/null
}
parse_git_dirty () {
	local STATUS
	local -a FLAGS
	FLAGS=('--porcelain') 
	if [[ "$(__git_prompt_git config --get oh-my-zsh.hide-dirty)" != "1" ]]
	then
		if [[ "${DISABLE_UNTRACKED_FILES_DIRTY:-}" == "true" ]]
		then
			FLAGS+='--untracked-files=no' 
		fi
		case "${GIT_STATUS_IGNORE_SUBMODULES:-}" in
			(git)  ;;
			(*) FLAGS+="--ignore-submodules=${GIT_STATUS_IGNORE_SUBMODULES:-dirty}"  ;;
		esac
		STATUS=$(__git_prompt_git status ${FLAGS} 2> /dev/null | tail -n 1) 
	fi
	if [[ -n $STATUS ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
	else
		echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
	fi
}
prompt_starship_precmd () {
	STARSHIP_CMD_STATUS=$? STARSHIP_PIPE_STATUS=(${pipestatus[@]}) 
	if (( ${+STARSHIP_START_TIME} ))
	then
		__starship_get_time && (( STARSHIP_DURATION = STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
		unset STARSHIP_START_TIME
	else
		unset STARSHIP_DURATION STARSHIP_CMD_STATUS STARSHIP_PIPE_STATUS
	fi
	STARSHIP_JOBS_COUNT=${#jobstates} 
}
prompt_starship_preexec () {
	__starship_get_time && STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME 
}
pyenv_prompt_info () {
	return 1
}
rbenv_prompt_info () {
	return 1
}
regexp-replace () {
	argv=("$1" "$2" "$3") 
	4=0 
	[[ -o re_match_pcre ]] && 4=1 
	emulate -L zsh
	local MATCH MBEGIN MEND
	local -a match mbegin mend
	if (( $4 ))
	then
		zmodload zsh/pcre || return 2
		pcre_compile -- "$2" && pcre_study || return 2
		4=0 6= 
		local ZPCRE_OP
		while pcre_match -b -n $4 -- "${(P)1}"
		do
			5=${(e)3} 
			argv+=(${(s: :)ZPCRE_OP} "$5") 
			4=$((argv[-2] + (argv[-3] == argv[-2]))) 
		done
		(($# > 6)) || return
		set +o multibyte
		5= 6=1 
		for 2 3 4 in "$@[7,-1]"
		do
			5+=${(P)1[$6,$2]}$4 
			6=$(($3 + 1)) 
		done
		5+=${(P)1[$6,-1]} 
	else
		4=${(P)1} 
		while [[ -n $4 ]]
		do
			if [[ $4 =~ $2 ]]
			then
				5+=${4[1,MBEGIN-1]}${(e)3} 
				if ((MEND < MBEGIN))
				then
					((MEND++))
					5+=${4[1]} 
				fi
				4=${4[MEND+1,-1]} 
				6=1 
			else
				break
			fi
		done
		[[ -n $6 ]] || return
		5+=$4 
	fi
	eval $1=\$5
}
ruby_prompt_info () {
	echo "$(rvm_prompt_info || rbenv_prompt_info || chruby_prompt_info)"
}
rvm_prompt_info () {
	[ -f $HOME/.rvm/bin/rvm-prompt ] || return 1
	local rvm_prompt
	rvm_prompt=$($HOME/.rvm/bin/rvm-prompt ${=ZSH_THEME_RVM_PROMPT_OPTIONS} 2>/dev/null) 
	[[ -z "${rvm_prompt}" ]] && return 1
	echo "${ZSH_THEME_RUBY_PROMPT_PREFIX}${rvm_prompt:gs/%/%%}${ZSH_THEME_RUBY_PROMPT_SUFFIX}"
}
spectrum_bls () {
	setopt localoptions nopromptsubst
	local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris} 
	for code in {000..255}
	do
		print -P -- "$code: ${BG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
	done
}
spectrum_ls () {
	setopt localoptions nopromptsubst
	local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris} 
	for code in {000..255}
	do
		print -P -- "$code: ${FG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
	done
}
starship_zle-keymap-select () {
	zle reset-prompt
}
svn_prompt_info () {
	return 1
}
take () {
	if [[ $1 =~ ^(https?|ftp).*\.(tar\.(gz|bz2|xz)|tgz)$ ]]
	then
		takeurl "$1"
	elif [[ $1 =~ ^(https?|ftp).*\.(zip)$ ]]
	then
		takezip "$1"
	elif [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]
	then
		takegit "$1"
	else
		takedir "$@"
	fi
}
takedir () {
	mkdir -p $@ && cd ${@:$#}
}
takegit () {
	git clone "$1"
	cd "$(basename ${1%%.git})"
}
takeurl () {
	local data thedir
	data="$(mktemp)" 
	curl -L "$1" > "$data"
	tar xf "$data"
	thedir="$(tar tf "$data" | head -n 1)" 
	rm "$data"
	cd "$thedir"
}
takezip () {
	local data thedir
	data="$(mktemp)" 
	curl -L "$1" > "$data"
	unzip "$data" -d "./"
	thedir="$(unzip -l "$data" | awk 'NR==4 {print $4}' | sed 's/\/.*//')" 
	rm "$data"
	cd "$thedir"
}
tf_prompt_info () {
	return 1
}
tfdocs () {
	open "https://registry.terraform.io/search/providers?q=`echo "${@}" | urlencode`"
}
title () {
	setopt localoptions nopromptsubst
	[[ -n "${INSIDE_EMACS:-}" && "$INSIDE_EMACS" != vterm ]] && return
	: ${2=$1}
	case "$TERM" in
		(cygwin | xterm* | putty* | rxvt* | konsole* | ansi | mlterm* | alacritty* | st* | foot* | contour* | wezterm*) print -Pn "\e]2;${2:q}\a"
			print -Pn "\e]1;${1:q}\a" ;;
		(screen* | tmux*) print -Pn "\ek${1:q}\e\\" ;;
		(*) if [[ "$TERM_PROGRAM" == "iTerm.app" ]]
			then
				print -Pn "\e]2;${2:q}\a"
				print -Pn "\e]1;${1:q}\a"
			else
				if (( ${+terminfo[fsl]} && ${+terminfo[tsl]} ))
				then
					print -Pn "${terminfo[tsl]}$1${terminfo[fsl]}"
				fi
			fi ;;
	esac
}
toggle-fzf-tab () {
	emulate -L zsh -o extended_glob
	if (( $+_ftb_orig_widget ))
	then
		disable-fzf-tab
	else
		enable-fzf-tab
	fi
}
try_alias_value () {
	alias_value "$1" || echo "$1"
}
uninstall_oh_my_zsh () {
	command env ZSH="$ZSH" sh "$ZSH/tools/uninstall.sh"
}
up-line-or-beginning-search () {
	# undefined
	builtin autoload -XU
}
upgrade_oh_my_zsh () {
	echo "${fg[yellow]}Note: \`$0\` is deprecated. Use \`omz update\` instead.$reset_color" >&2
	omz update
}
url-quote-magic () {
	# undefined
	builtin autoload -XUz
}
urldecode () {
	python -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()), end='')"
}
urlencode () {
	python -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.stdin.read()))"
}
vi_mode_prompt_info () {
	return 1
}
virtualenv_prompt_info () {
	return 1
}
work_in_progress () {
	command git -c log.showSignature=false log -n 1 2> /dev/null | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} -q -- "--wip--" && echo "WIP!!"
}
zle-line-finish () {
	echoti rmkx
}
zle-line-init () {
	echoti smkx
}
zrecompile () {
	setopt localoptions extendedglob noshwordsplit noksharrays
	local opt check quiet zwc files re file pre ret map tmp mesg pats
	tmp=() 
	while getopts ":tqp" opt
	do
		case $opt in
			(t) check=yes  ;;
			(q) quiet=yes  ;;
			(p) pats=yes  ;;
			(*) if [[ -n $pats ]]
				then
					tmp=($tmp $OPTARG) 
				else
					print -u2 zrecompile: bad option: -$OPTARG
					return 1
				fi ;;
		esac
	done
	shift OPTIND-${#tmp}-1
	if [[ -n $check ]]
	then
		ret=1 
	else
		ret=0 
	fi
	if [[ -n $pats ]]
	then
		local end num
		while (( $# ))
		do
			end=$argv[(i)--] 
			if [[ end -le $# ]]
			then
				files=($argv[1,end-1]) 
				shift end
			else
				files=($argv) 
				argv=() 
			fi
			tmp=() 
			map=() 
			OPTIND=1 
			while getopts :MR opt $files
			do
				case $opt in
					([MR]) map=(-$opt)  ;;
					(*) tmp=($tmp $files[OPTIND])  ;;
				esac
			done
			shift OPTIND-1 files
			(( $#files )) || continue
			files=($files[1] ${files[2,-1]:#*(.zwc|~)}) 
			(( $#files )) || continue
			zwc=${files[1]%.zwc}.zwc 
			shift 1 files
			(( $#files )) || files=(${zwc%.zwc}) 
			if [[ -f $zwc ]]
			then
				num=$(zcompile -t $zwc | wc -l) 
				if [[ num-1 -ne $#files ]]
				then
					re=yes 
				else
					re= 
					for file in $files
					do
						if [[ $file -nt $zwc ]]
						then
							re=yes 
							break
						fi
					done
				fi
			else
				re=yes 
			fi
			if [[ -n $re ]]
			then
				if [[ -n $check ]]
				then
					[[ -z $quiet ]] && print $zwc needs re-compilation
					ret=0 
				else
					[[ -z $quiet ]] && print -n "re-compiling ${zwc}: "
					if [[ -z "$quiet" ]] && {
							[[ ! -f $zwc ]] || mv -f $zwc ${zwc}.old
						} && zcompile $map $tmp $zwc $files
					then
						print succeeded
					elif ! {
							{
								[[ ! -f $zwc ]] || mv -f $zwc ${zwc}.old
							} && zcompile $map $tmp $zwc $files 2> /dev/null
						}
					then
						[[ -z $quiet ]] && print "re-compiling ${zwc}: failed"
						ret=1 
					fi
				fi
			fi
		done
		return ret
	fi
	if (( $# ))
	then
		argv=(${^argv}/*.zwc(ND) ${^argv}.zwc(ND) ${(M)argv:#*.zwc}) 
	else
		argv=(${^fpath}/*.zwc(ND) ${^fpath}.zwc(ND) ${(M)fpath:#*.zwc}) 
	fi
	argv=(${^argv%.zwc}.zwc) 
	for zwc
	do
		files=(${(f)"$(zcompile -t $zwc)"}) 
		if [[ $files[1] = *\(mapped\)* ]]
		then
			map=-M 
			mesg='succeeded (old saved)' 
		else
			map=-R 
			mesg=succeeded 
		fi
		if [[ $zwc = */* ]]
		then
			pre=${zwc%/*}/ 
		else
			pre= 
		fi
		if [[ $files[1] != *$ZSH_VERSION ]]
		then
			re=yes 
		else
			re= 
		fi
		files=(${pre}${^files[2,-1]:#/*} ${(M)files[2,-1]:#/*}) 
		[[ -z $re ]] && for file in $files
		do
			if [[ $file -nt $zwc ]]
			then
				re=yes 
				break
			fi
		done
		if [[ -n $re ]]
		then
			if [[ -n $check ]]
			then
				[[ -z $quiet ]] && print $zwc needs re-compilation
				ret=0 
			else
				[[ -z $quiet ]] && print -n "re-compiling ${zwc}: "
				tmp=(${^files}(N)) 
				if [[ $#tmp -ne $#files ]]
				then
					[[ -z $quiet ]] && print 'failed (missing files)'
					ret=1 
				else
					if [[ -z "$quiet" ]] && mv -f $zwc ${zwc}.old && zcompile $map $zwc $files
					then
						print $mesg
					elif ! {
							mv -f $zwc ${zwc}.old && zcompile $map $zwc $files 2> /dev/null
						}
					then
						[[ -z $quiet ]] && print "re-compiling ${zwc}: failed"
						ret=1 
					fi
				fi
			fi
		fi
	done
	return ret
}
zsh_stats () {
	fc -l 1 | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' | grep -v "./" | sort -nr | head -n 20 | column -c3 -s " " -t | nl
}
VCS_INFO_formats () {
	setopt localoptions noksharrays NO_shwordsplit
	local msg tmp
	local -i i
	local -A hook_com
	hook_com=(action "$1" action_orig "$1" branch "$2" branch_orig "$2" base "$3" base_orig "$3" staged "$4" staged_orig "$4" unstaged "$5" unstaged_orig "$5" revision "$6" revision_orig "$6" misc "$7" misc_orig "$7" vcs "${vcs}" vcs_orig "${vcs}") 
	hook_com[base-name]="${${hook_com[base]}:t}" 
	hook_com[base-name_orig]="${hook_com[base-name]}" 
	hook_com[subdir]="$(VCS_INFO_reposub ${hook_com[base]})" 
	hook_com[subdir_orig]="${hook_com[subdir]}" 
	: vcs_info-patch-9b9840f2-91e5-4471-af84-9e9a0dc68c1b
	for tmp in base base-name branch misc revision subdir
	do
		hook_com[$tmp]="${hook_com[$tmp]//\%/%%}" 
	done
	VCS_INFO_hook 'post-backend'
	if [[ -n ${hook_com[action]} ]]
	then
		zstyle -a ":vcs_info:${vcs}:${usercontext}:${rrn}" actionformats msgs
		(( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b|%a]%u%c-' 
	else
		zstyle -a ":vcs_info:${vcs}:${usercontext}:${rrn}" formats msgs
		(( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b]%u%c-' 
	fi
	if [[ -n ${hook_com[staged]} ]]
	then
		zstyle -s ":vcs_info:${vcs}:${usercontext}:${rrn}" stagedstr tmp
		[[ -z ${tmp} ]] && hook_com[staged]='S'  || hook_com[staged]=${tmp} 
	fi
	if [[ -n ${hook_com[unstaged]} ]]
	then
		zstyle -s ":vcs_info:${vcs}:${usercontext}:${rrn}" unstagedstr tmp
		[[ -z ${tmp} ]] && hook_com[unstaged]='U'  || hook_com[unstaged]=${tmp} 
	fi
	if [[ ${quiltmode} != 'standalone' ]] && VCS_INFO_hook "pre-addon-quilt"
	then
		local REPLY
		VCS_INFO_quilt addon
		hook_com[quilt]="${REPLY}" 
		unset REPLY
	elif [[ ${quiltmode} == 'standalone' ]]
	then
		hook_com[quilt]=${hook_com[misc]} 
	fi
	(( ${#msgs} > maxexports )) && msgs[$(( maxexports + 1 )),-1]=() 
	for i in {1..${#msgs}}
	do
		if VCS_INFO_hook "set-message" $(( $i - 1 )) "${msgs[$i]}"
		then
			zformat -f msg ${msgs[$i]} a:${hook_com[action]} b:${hook_com[branch]} c:${hook_com[staged]} i:${hook_com[revision]} m:${hook_com[misc]} r:${hook_com[base-name]} s:${hook_com[vcs]} u:${hook_com[unstaged]} Q:${hook_com[quilt]} R:${hook_com[base]} S:${hook_com[subdir]}
			msgs[$i]=${msg} 
		else
			msgs[$i]=${hook_com[message]} 
		fi
	done
	hook_com=() 
	backend_misc=() 
	return 0
}
__arguments () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
__git_prompt_git () {
	GIT_OPTIONAL_LOCKS=0 command git "$@"
}
__starship_get_time () {
	(( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) ))
}
add-zle-hook-widget () {
	# undefined
	builtin autoload -XU
}
add-zsh-hook () {
	emulate -L zsh
	local -a hooktypes
	hooktypes=(chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name) 
	local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	if (( list ))
	then
		typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local hook="${1}_functions" 
	local fn="$2" 
	if (( del ))
	then
		if (( ${(P)+hook} ))
		then
			if (( del == 2 ))
			then
				set -A $hook ${(P)hook:#${~fn}}
			else
				set -A $hook ${(P)hook:#$fn}
			fi
			if (( ! ${(P)#hook} ))
			then
				unset $hook
			fi
		fi
	else
		if (( ${(P)+hook} ))
		then
			if (( ${${(P)hook}[(I)$fn]} == 0 ))
			then
				typeset -ga $hook
				set -A $hook ${(P)hook} $fn
			fi
		else
			typeset -ga $hook
			set -A $hook $fn
		fi
		autoload $autoopts -- $fn
	fi
}
alias_value () {
	(( $+aliases[$1] )) && echo $aliases[$1]
}
azure_prompt_info () {
	return 1
}
bashcompinit () {
	# undefined
	builtin autoload -XUz
}
bracketed-paste-magic () {
	# undefined
	builtin autoload -XUz
}
build-fzf-tab-module () {
	{
		pushd -q $FZF_TAB_HOME/modules
		if -ftb-build-module $@
		then
			print -P "%F{green}%BThe module has been built successfully. Please restart zsh to apply it.%f%b"
		else
			print -P -u2 "%F{red}%BThe module building has failed. See the output above for details.%f%b"
			return 1
		fi
	} always {
		popd -q
	}
}
bzr_prompt_info () {
	local bzr_branch
	bzr_branch=$(bzr nick 2>/dev/null)  || return
	if [[ -n "$bzr_branch" ]]
	then
		local bzr_dirty="" 
		if [[ -n $(bzr status 2>/dev/null) ]]
		then
			bzr_dirty=" %{$fg[red]%}*%{$reset_color%}" 
		fi
		printf "%s%s%s%s" "$ZSH_THEME_SCM_PROMPT_PREFIX" "bzr::${bzr_branch##*:}" "$bzr_dirty" "$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}
chruby_prompt_info () {
	return 1
}
clipcopy () {
	unfunction clipcopy clippaste
	detect-clipboard || true
	"$0" "$@"
}
clippaste () {
	unfunction clipcopy clippaste
	detect-clipboard || true
	"$0" "$@"
}
colors () {
	emulate -L zsh
	typeset -Ag color colour
	color=(00 none 01 bold 02 faint 22 normal 03 italic 23 no-italic 04 underline 24 no-underline 05 blink 25 no-blink 07 reverse 27 no-reverse 08 conceal 28 no-conceal 30 black 40 bg-black 31 red 41 bg-red 32 green 42 bg-green 33 yellow 43 bg-yellow 34 blue 44 bg-blue 35 magenta 45 bg-magenta 36 cyan 46 bg-cyan 37 white 47 bg-white 39 default 49 bg-default) 
	local k
	for k in ${(k)color}
	do
		color[${color[$k]}]=$k 
	done
	for k in ${color[(I)3?]}
	do
		color[fg-${color[$k]}]=$k 
	done
	for k in grey gray
	do
		color[$k]=${color[black]} 
		color[fg-$k]=${color[$k]} 
		color[bg-$k]=${color[bg-black]} 
	done
	colour=(${(kv)color}) 
	local lc=$'\e[' rc=m 
	typeset -Hg reset_color bold_color
	reset_color="$lc${color[none]}$rc" 
	bold_color="$lc${color[bold]}$rc" 
	typeset -AHg fg fg_bold fg_no_bold
	for k in ${(k)color[(I)fg-*]}
	do
		fg[${k#fg-}]="$lc${color[$k]}$rc" 
		fg_bold[${k#fg-}]="$lc${color[bold]};${color[$k]}$rc" 
		fg_no_bold[${k#fg-}]="$lc${color[normal]};${color[$k]}$rc" 
	done
	typeset -AHg bg bg_bold bg_no_bold
	for k in ${(k)color[(I)bg-*]}
	do
		bg[${k#bg-}]="$lc${color[$k]}$rc" 
		bg_bold[${k#bg-}]="$lc${color[bold]};${color[$k]}$rc" 
		bg_no_bold[${k#bg-}]="$lc${color[normal]};${color[$k]}$rc" 
	done
}
command_not_found_handler () {
	if [[ "$1" != "mise" && "$1" != "mise-"* ]] && /Users/steve.briggs/.local/bin/mise hook-not-found -s zsh -- "$1"
	then
		_mise_hook
		"$@"
	elif [ -n "$(declare -f _command_not_found_handler)" ]
	then
		_command_not_found_handler "$@"
	else
		echo "zsh: command not found: $1" >&2
		return 127
	fi
}
compadd () {
	local -A apre hpre dscrs _oad _mesg
	local -a isfile _opts __ expl
	zparseopts -a _opts P:=apre p:=hpre d:=dscrs X+:=expl O:=_oad A:=_oad D:=_oad f=isfile i: S: s: I: x:=_mesg r: R: W: F: M+: E: q e Q n U C J:=__ V:=__ a=__ l=__ k=__ o::=__ 1=__ 2=__
	_ftb_curcontext=${curcontext#:} 
	if (( $#_oad != 0 || ! IN_FZF_TAB )) || {
			-ftb-zstyle -m disabled-on "any"
		} || (
			{
				-ftb-zstyle -m disabled-on "files"
			} && [[ -n $isfile ]]
		)
	then
		builtin compadd "$@"
		return
	fi
	local -a __hits __dscr
	if (( $#dscrs == 1 ))
	then
		__dscr=("${(@P)${(v)dscrs}}") 
	fi
	builtin compadd -A __hits -D __dscr "$@"
	local ret=$? 
	if (( $#__hits == 0 ))
	then
		if is-at-least 5.9 && (( $#_mesg != 0 ))
		then
			builtin compadd -x $_mesg
		fi
		return $ret
	fi
	expl=$expl[2] 
	[[ -n $expl ]] && _ftb_groups+=$expl 
	local -a keys=(apre hpre PREFIX SUFFIX IPREFIX ISUFFIX) 
	local key expanded __tmp_value=$'<\0>' 
	for key in $keys
	do
		expanded=${(P)key} 
		if [[ -n $expanded ]]
		then
			__tmp_value+=$'\0'$key$'\0'$expanded 
		fi
	done
	if [[ -n $expl ]]
	then
		__tmp_value+=$'\0group\0'$_ftb_groups[(ie)$expl] 
	fi
	if [[ -n $isfile ]]
	then
		__tmp_value+=$'\0realdir\0'${${(Qe)~${:-$IPREFIX$hpre}}} 
	fi
	_opts+=("${(@kv)apre}" "${(@kv)hpre}" $isfile) 
	__tmp_value+=$'\0args\0'${(pj:\1:)_opts} 
	if (( $+builtins[fzf-tab-compcap-generate] ))
	then
		fzf-tab-compcap-generate __hits __dscr __tmp_value
	else
		local dscr word i
		for i in {1..$#__hits}
		do
			word=$__hits[i] dscr=$__dscr[i] 
			if [[ -n $dscr ]]
			then
				dscr=${dscr//$'\n'} 
			elif [[ -n $word ]]
			then
				dscr=$word 
			fi
			_ftb_compcap+=$dscr$'\2'$__tmp_value$'\0word\0'$word 
		done
	fi
	builtin compadd "$@"
}
compaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz
}
compgen () {
	local opts prefix suffix job OPTARG OPTIND ret=1 
	local -a name res results jids
	local -A shortopts
	emulate -L sh
	setopt kshglob noshglob braceexpand nokshautoload
	shortopts=(a alias b builtin c command d directory e export f file g group j job k keyword u user v variable) 
	while getopts "o:A:G:C:F:P:S:W:X:abcdefgjkuv" name
	do
		case $name in
			([abcdefgjkuv]) OPTARG="${shortopts[$name]}"  ;&
			(A) case $OPTARG in
					(alias) results+=("${(k)aliases[@]}")  ;;
					(arrayvar) results+=("${(k@)parameters[(R)array*]}")  ;;
					(binding) results+=("${(k)widgets[@]}")  ;;
					(builtin) results+=("${(k)builtins[@]}" "${(k)dis_builtins[@]}")  ;;
					(command) results+=("${(k)commands[@]}" "${(k)aliases[@]}" "${(k)builtins[@]}" "${(k)functions[@]}" "${(k)reswords[@]}")  ;;
					(directory) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N-/)) 
						setopt nobareglobqual ;;
					(disabled) results+=("${(k)dis_builtins[@]}")  ;;
					(enabled) results+=("${(k)builtins[@]}")  ;;
					(export) results+=("${(k)parameters[(R)*export*]}")  ;;
					(file) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N)) 
						setopt nobareglobqual ;;
					(function) results+=("${(k)functions[@]}")  ;;
					(group) emulate zsh
						_groups -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(hostname) emulate zsh
						_hosts -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(job) results+=("${savejobtexts[@]%% *}")  ;;
					(keyword) results+=("${(k)reswords[@]}")  ;;
					(running) jids=("${(@k)savejobstates[(R)running*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(stopped) jids=("${(@k)savejobstates[(R)suspended*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(setopt | shopt) results+=("${(k)options[@]}")  ;;
					(signal) results+=("SIG${^signals[@]}")  ;;
					(user) results+=("${(k)userdirs[@]}")  ;;
					(variable) results+=("${(k)parameters[@]}")  ;;
					(helptopic)  ;;
				esac ;;
			(F) COMPREPLY=() 
				local -a args
				args=("${words[0]}" "${@[-1]}" "${words[CURRENT-2]}") 
				() {
					typeset -h words
					$OPTARG "${args[@]}"
				}
				results+=("${COMPREPLY[@]}")  ;;
			(G) setopt nullglob
				results+=(${~OPTARG}) 
				unsetopt nullglob ;;
			(W) results+=(${(Q)~=OPTARG})  ;;
			(C) results+=($(eval $OPTARG))  ;;
			(P) prefix="$OPTARG"  ;;
			(S) suffix="$OPTARG"  ;;
			(X) if [[ ${OPTARG[0]} = '!' ]]
				then
					results=("${(M)results[@]:#${OPTARG#?}}") 
				else
					results=("${results[@]:#$OPTARG}") 
				fi ;;
		esac
	done
	print -l -r -- "$prefix${^results[@]}$suffix"
}
compinit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
complete () {
	emulate -L zsh
	local args void cmd print remove
	args=("$@") 
	zparseopts -D -a void o: A: G: W: C: F: P: S: X: a b c d e f g j k u v p=print r=remove
	if [[ -n $print ]]
	then
		printf 'complete %2$s %1$s\n' "${(@kv)_comps[(R)_bash*]#* }"
	elif [[ -n $remove ]]
	then
		for cmd
		do
			unset "_comps[$cmd]"
		done
	else
		compdef _bash_complete\ ${(j. .)${(q)args[1,-1-$#]}} "$@"
	fi
}
conda_prompt_info () {
	return 1
}
d () {
	if [[ -n $1 ]]
	then
		dirs "$@"
	else
		dirs -v | head -n 10
	fi
}
default () {
	(( $+parameters[$1] )) && return 0
	typeset -g "$1"="$2" && return 3
}
detect-clipboard () {
	emulate -L zsh
	if [[ "${OSTYPE}" == darwin* ]] && (( ${+commands[pbcopy]} )) && (( ${+commands[pbpaste]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | pbcopy
		}
		clippaste () {
			pbpaste
		}
	elif [[ "${OSTYPE}" == (cygwin|msys)* ]]
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" > /dev/clipboard
		}
		clippaste () {
			cat /dev/clipboard
		}
	elif (( $+commands[clip.exe] )) && (( $+commands[powershell.exe] ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | clip.exe
		}
		clippaste () {
			powershell.exe -noprofile -command Get-Clipboard
		}
	elif [ -n "${WAYLAND_DISPLAY:-}" ] && (( ${+commands[wl-copy]} )) && (( ${+commands[wl-paste]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | wl-copy &> /dev/null &|
		}
		clippaste () {
			wl-paste --no-newline
		}
	elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xsel]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | xsel --clipboard --input
		}
		clippaste () {
			xsel --clipboard --output
		}
	elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xclip]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | xclip -selection clipboard -in &> /dev/null &|
		}
		clippaste () {
			xclip -out -selection clipboard
		}
	elif (( ${+commands[lemonade]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | lemonade copy
		}
		clippaste () {
			lemonade paste
		}
	elif (( ${+commands[doitclient]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | doitclient wclip
		}
		clippaste () {
			doitclient wclip -r
		}
	elif (( ${+commands[win32yank]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | win32yank -i
		}
		clippaste () {
			win32yank -o
		}
	elif [[ $OSTYPE == linux-android* ]] && (( $+commands[termux-clipboard-set] ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | termux-clipboard-set
		}
		clippaste () {
			termux-clipboard-get
		}
	elif [ -n "${TMUX:-}" ] && (( ${+commands[tmux]} ))
	then
		clipcopy () {
			tmux load-buffer -w "${1:--}"
		}
		clippaste () {
			tmux save-buffer -
		}
	else
		_retry_clipboard_detection_or_fail () {
			local clipcmd="${1}" 
			shift
			if detect-clipboard
			then
				"${clipcmd}" "$@"
			else
				print "${clipcmd}: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
				return 1
			fi
		}
		clipcopy () {
			_retry_clipboard_detection_or_fail clipcopy "$@"
		}
		clippaste () {
			_retry_clipboard_detection_or_fail clippaste "$@"
		}
		return 1
	fi
}
diff () {
	command diff --color "$@"
}
disable-fzf-tab () {
	emulate -L zsh -o extended_glob
	(( $+_ftb_orig_widget )) || return 0
	bindkey '^I' $_ftb_orig_widget
	case $_ftb_orig_list_grouped in
		(0) zstyle ':completion:*' list-grouped false ;;
		(1) zstyle ':completion:*' list-grouped true ;;
		(2) zstyle -d ':completion:*' list-grouped ;;
	esac
	unset _ftb_orig_widget _ftb_orig_list_groupded
	unfunction compadd 2> /dev/null
	functions[_main_complete]=$functions[_ftb__main_complete] 
	functions[_approximate]=$functions[_ftb__approximate] 
}
down-line-or-beginning-search () {
	# undefined
	builtin autoload -XU
}
edit-command-line () {
	# undefined
	builtin autoload -XU
}
enable-fzf-tab () {
	emulate -L zsh -o extended_glob
	(( ! $+_ftb_orig_widget )) || disable-fzf-tab
	typeset -g _ftb_orig_widget="${${$(builtin bindkey '^I')##* }:-expand-or-complete}" 
	if (( ! $+widgets[.fzf-tab-orig-$_ftb_orig_widget] ))
	then
		local compinit_widgets=(complete-word delete-char-or-list expand-or-complete expand-or-complete-prefix list-choices menu-complete menu-expand-or-complete reverse-menu-complete) 
		if [[ $widgets[$_ftb_orig_widget] == builtin && $compinit_widgets[(Ie)$_ftb_orig_widget] != 0 ]]
		then
			zle -C .fzf-tab-orig-$_ftb_orig_widget .$_ftb_orig_widget _main_complete
		else
			zle -A $_ftb_orig_widget .fzf-tab-orig-$_ftb_orig_widget
		fi
	fi
	zstyle -t ':completion:*' list-grouped false
	typeset -g _ftb_orig_list_grouped=$? 
	zstyle ':completion:*' list-grouped false
	bindkey -M emacs '^I' fzf-tab-complete
	bindkey -M viins '^I' fzf-tab-complete
	bindkey -M emacs '^X.' fzf-tab-debug
	bindkey -M viins '^X.' fzf-tab-debug
	autoload +X -Uz _main_complete _approximate
	functions[compadd]=$functions[-ftb-compadd] 
	functions[_ftb__main_complete]=$functions[_main_complete] 
	_main_complete () {
		-ftb-complete "$@"
	}
	functions[_ftb__approximate]=$functions[_approximate] 
	_approximate () {
		(( ! IN_FZF_TAB )) || unfunction compadd
		_ftb__approximate
		(( ! IN_FZF_TAB )) || functions[compadd]=$functions[-ftb-compadd] 
	}
}
env_default () {
	[[ ${parameters[$1]} = *-export* ]] && return 0
	export "$1=$2" && return 3
}
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
			grep --color=auto --color -l "$FIND" | xargs sed -i "s/${FIND}/${REPLACE}/g"
		else
			grep --color=auto --color -l "$FIND" | grep --color=auto --color -i "$FILTER" | xargs sed -i "s/${FIND}/${REPLACE}/g"
		fi
	fi
}
ftb-switch-group () {
	# undefined
	builtin autoload -XUz
}
ftb-tmux-popup () {
	# undefined
	builtin autoload -XUz
}
fzf-tab-complete () {
	local -i _ftb_continue=1 _ftb_continue_last=0 _ftb_accept=0 ret=0 
	echoti civis > /dev/tty 2> /dev/null
	while (( _ftb_continue ))
	do
		local _ftb_choices=() _ftb_compcap=() _ftb_finish=0 
		_ftb_continue=0 
		local IN_FZF_TAB=1 
		{
			zle .fzf-tab-orig-$_ftb_orig_widget || ret=$? 
			if (( ! ret && ! _ftb_finish ))
			then
				zle _fzf-tab-apply || ret=$? 
			fi
		} always {
			IN_FZF_TAB=0 
		}
		if (( _ftb_continue ))
		then
			zle .split-undo
			zle .reset-prompt
			zle -R
			zle fzf-tab-dummy
		fi
	done
	echoti cnorm > /dev/tty 2> /dev/null
	zle .redisplay
	(( _ftb_accept )) && zle .accept-line
	return $ret
}
fzf-tab-debug () {
	(( $+_ftb_debug_cnt )) || typeset -gi _ftb_debug_cnt
	local tmp=${TMPPREFIX:-/tmp/zsh}-$$-fzf-tab-$(( ++_ftb_debug_cnt )).log 
	local -i debug_fd=-1 IN_FZF_TAB=1 
	{
		exec {debug_fd}>&2 2>| $tmp
		local -a debug_indent
		debug_indent=('%'{3..20}'(e. .)') 
		local PROMPT4 PS4="${(j::)debug_indent}+%N:%i> " 
		functions -t -- -ftb-complete _fzf-tab-apply fzf-tab-complete
		{
			echo $ZSH_NAME $ZSH_VERSION
			echo fzf-tab: $(-ftb-version)
			typeset -p FZF_DEFAULT_OPTS
			echo $commands[fzf] $(fzf --version)
		} >&2
		zle fzf-tab-complete
		if (( debug_fd != -1 ))
		then
			zle -M "fzf-tab-debug: Trace output left in $tmp"
		fi
	} always {
		functions +t -- -ftb-complete _fzf-tab-apply fzf-tab-complete
		(( debug_fd != -1 )) && exec 2>&$debug_fd {debug_fd}>&-
	}
}
fzf-tab-dummy () {
	
}
fzf-tab-lscolors::from-mode () {
	emulate -L zsh
	setopt cbases octalzeroes extendedglob
	[[ -z $2 ]] && return 1
	local -i reg=0 
	local -a codes
	local -i st_mode=$(($2)) 
	case $(( st_mode & 0170000 )) in
		($(( 0140000 ))) codes=($modecolors[so])  ;;
		($(( 0120000 ))) if ! (($+3))
			then
				REPLY=$modecolors[or] 
			elif [[ $modecolors[ln] = target ]]
			then
				"$0" "$1" "${@:3}"
			else
				REPLY=$modecolors[ln] 
			fi
			return ;;
		($(( 0100000 ))) codes=() 
			reg=1  ;;
		($(( 0060000 ))) codes=($modecolors[bd])  ;;
		($(( 0040000 ))) codes=($modecolors[di])  ;;
		($(( 0020000 ))) codes=($modecolors[cd])  ;;
		($(( 0010000 ))) codes=($modecolors[pi])  ;;
	esac
	(( st_mode & 04000 )) && codes+=($modecolors[su]) 
	(( st_mode & 02000 )) && codes+=($modecolors[sg]) 
	(( ! reg )) && case $(( st_mode & 01002 )) in
		($(( 01000 ))) codes+=($modecolors[st])  ;;
		($(( 00002 ))) codes+=($modecolors[ow])  ;;
		($(( 01002 ))) codes+=($modecolors[tw])  ;;
	esac
	if (( ! $#codes ))
	then
		(( st_mode &  0111 )) && codes+=($modecolors[ex]) 
	fi
	[[ -n ${REPLY::=${(j:;:)codes}} ]]
}
fzf-tab-lscolors::from-name () {
	emulate -L zsh
	setopt extendedglob
	[[ -n ${REPLY::=$namecolors[(k)$1]} ]]
}
fzf-tab-lscolors::init () {
	emulate -L zsh
	local LS_COLORS=${1:-${LS_COLORS:-$LSCOLORS}} 
	typeset -gA namecolors=(${(@s:=:)${(@s.:.)LS_COLORS}:#[[:alpha:]][[:alpha:]]=*}) 
	typeset -gA modecolors=(${(@Ms:=:)${(@s.:.)LS_COLORS}:#[[:alpha:]][[:alpha:]]=*}) 
}
fzf-tab-lscolors::match-by () {
	emulate -L zsh
	setopt extendedglob cbases octalzeroes
	local arg REPLY name=$1 pfx=${0%::match-by} 
	shift
	if ! [[ -v namecolors && -v modecolors ]]
	then
		local -A namecolors modecolors
		${pfx}::init
	fi
	if [[ ${1:l} = (g|global) ]]
	then
		shift
	else
		local -a stat lstat
		declare -ga reply=() 
	fi
	zmodload -F zsh/stat b:zstat
	for arg
	do
		case ${arg[1]:l} in
			(n | name) ${pfx}::from-name $name
				reply+=("$REPLY")  ;;
			(l | lstat) (($#lstat)) || zstat -A lstat -L $name || return 1
				if ((lstat[3] & 0170000 ))
				then
					(($#stat)) || zstat -A stat $name 2> /dev/null
				fi
				${pfx}::from-mode "$name" "$lstat[3]" $stat[3]
				if [[ -n $REPLY || ${2[1]} = L ]]
				then
					reply+=("$REPLY") 
				else
					"$0" "$name" g n
				fi ;;
			(s | stat) (($#stat)) || zstat -A stat $name || return 1
				${pfx}::from-mode $name $stat[3]
				reply+=("$REPLY") 
				if [[ -n $REPLY || ${arg[1]} = S ]]
				then
					reply+=("$REPLY") 
				else
					"$0" "$name" g n
				fi ;;
			(f | follow) (($#lstat)) || zstat -A lstat -L $name || return 1
				reply+=("$lstat[14]")  ;;
			(a | all) "$0" "$name" g ${${${arg[1]%a}:+L}:-l}
				reply+=($lstat[14]) 
				if [[ -n $lstat[14] ]]
				then
					if [[ -e $name ]]
					then
						"$0" "$name" g ${${${arg[1]%a}:+S}:-s}
					else
						reply+=($reply[-2]) 
					fi
				fi ;;
			(*) return 2 ;;
		esac
	done
}
gbda () {
	git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2> /dev/null
}
gbds () {
	local default_branch=$(git_main_branch) 
	(( ! $? )) || default_branch=$(git_develop_branch) 
	git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch
	do
		local merge_base=$(git merge-base $default_branch $branch) 
		if [[ $(git cherry $default_branch $(git commit-tree $(git rev-parse $branch\^{tree}) -p $merge_base -m _)) = -* ]]
		then
			git branch -D $branch
		fi
	done
}
gccd () {
	setopt localoptions extendedglob
	local repo="${${@[(r)(ssh://*|git://*|ftp(s)#://*|http(s)#://*|*@*)(.git/#)#]}:-$_}" 
	command git clone --recurse-submodules "$@" || return
	[[ -d "$_" ]] && cd "$_" || cd "${${repo:t}%.git/#}"
}
gdnolock () {
	git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}
gdv () {
	git diff -w "$@" | view -
}
getent () {
	if [[ $1 = hosts ]]
	then
		sed 's/#.*//' /etc/$1 | grep -w $2
	elif [[ $2 = <-> ]]
	then
		grep ":$2:[^:]*$" /etc/$1
	else
		grep "^$2:" /etc/$1
	fi
}
ggf () {
	local b
	[[ $# != 1 ]] && b="$(git_current_branch)" 
	git push --force origin "${b:-$1}"
}
ggfl () {
	local b
	[[ $# != 1 ]] && b="$(git_current_branch)" 
	git push --force-with-lease origin "${b:-$1}"
}
ggl () {
	if [[ $# != 0 ]] && [[ $# != 1 ]]
	then
		git pull origin "${*}"
	else
		local b
		[[ $# == 0 ]] && b="$(git_current_branch)" 
		git pull origin "${b:-$1}"
	fi
}
ggp () {
	if [[ $# != 0 ]] && [[ $# != 1 ]]
	then
		git push origin "${*}"
	else
		local b
		[[ $# == 0 ]] && b="$(git_current_branch)" 
		git push origin "${b:-$1}"
	fi
}
ggpnp () {
	if [[ $# == 0 ]]
	then
		ggl && ggp
	else
		ggl "${*}" && ggp "${*}"
	fi
}
ggu () {
	local b
	[[ $# != 1 ]] && b="$(git_current_branch)" 
	git pull --rebase origin "${b:-$1}"
}
git_commits_ahead () {
	if __git_prompt_git rev-parse --git-dir &> /dev/null
	then
		local commits="$(__git_prompt_git rev-list --count @{upstream}..HEAD 2>/dev/null)" 
		if [[ -n "$commits" && "$commits" != 0 ]]
		then
			echo "$ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX$commits$ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
		fi
	fi
}
git_commits_behind () {
	if __git_prompt_git rev-parse --git-dir &> /dev/null
	then
		local commits="$(__git_prompt_git rev-list --count HEAD..@{upstream} 2>/dev/null)" 
		if [[ -n "$commits" && "$commits" != 0 ]]
		then
			echo "$ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX$commits$ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX"
		fi
	fi
}
git_current_branch () {
	local ref
	ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null) 
	local ret=$? 
	if [[ $ret != 0 ]]
	then
		[[ $ret == 128 ]] && return
		ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  || return
	fi
	echo ${ref#refs/heads/}
}
git_current_user_email () {
	__git_prompt_git config user.email 2> /dev/null
}
git_current_user_name () {
	__git_prompt_git config user.name 2> /dev/null
}
git_develop_branch () {
	command git rev-parse --git-dir &> /dev/null || return
	local branch
	for branch in dev devel develop development
	do
		if command git show-ref -q --verify refs/heads/$branch
		then
			echo $branch
			return 0
		fi
	done
	echo develop
	return 1
}
git_main_branch () {
	command git rev-parse --git-dir &> /dev/null || return
	local remote ref
	for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}
	do
		if command git show-ref -q --verify $ref
		then
			echo ${ref:t}
			return 0
		fi
	done
	for remote in origin upstream
	do
		ref=$(command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null) 
		if [[ $ref == $remote/* ]]
		then
			echo ${ref#"$remote/"}
			return 0
		fi
	done
	echo master
	return 1
}
git_previous_branch () {
	local ref
	ref=$(__git_prompt_git rev-parse --quiet --symbolic-full-name @{-1} 2> /dev/null) 
	local ret=$? 
	if [[ $ret != 0 ]] || [[ -z $ref ]]
	then
		return
	fi
	echo ${ref#refs/heads/}
}
git_prompt_ahead () {
	if [[ -n "$(__git_prompt_git rev-list origin/$(git_current_branch)..HEAD 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
	fi
}
git_prompt_behind () {
	if [[ -n "$(__git_prompt_git rev-list HEAD..origin/$(git_current_branch) 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_BEHIND"
	fi
}
git_prompt_info () {
	if [[ -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_info]}" ]]
	then
		echo -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_info]}"
	fi
}
git_prompt_long_sha () {
	local SHA
	SHA=$(__git_prompt_git rev-parse HEAD 2> /dev/null)  && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}
git_prompt_remote () {
	if [[ -n "$(__git_prompt_git show-ref origin/$(git_current_branch) 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS"
	else
		echo "$ZSH_THEME_GIT_PROMPT_REMOTE_MISSING"
	fi
}
git_prompt_short_sha () {
	local SHA
	SHA=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}
git_prompt_status () {
	if [[ -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_status]}" ]]
	then
		echo -n "${_OMZ_ASYNC_OUTPUT[_omz_git_prompt_status]}"
	fi
}
git_remote_status () {
	local remote ahead behind git_remote_status git_remote_status_detailed
	remote=${$(__git_prompt_git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/} 
	if [[ -n ${remote} ]]
	then
		ahead=$(__git_prompt_git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l) 
		behind=$(__git_prompt_git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l) 
		if [[ $ahead -eq 0 ]] && [[ $behind -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE" 
		elif [[ $ahead -gt 0 ]] && [[ $behind -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}" 
		elif [[ $behind -gt 0 ]] && [[ $ahead -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}" 
		elif [[ $ahead -gt 0 ]] && [[ $behind -gt 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}" 
		fi
		if [[ -n $ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX${remote//\%/%%}$git_remote_status_detailed$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX" 
		fi
		echo $git_remote_status
	fi
}
git_repo_name () {
	local repo_path
	if repo_path="$(__git_prompt_git rev-parse --show-toplevel 2>/dev/null)"  && [[ -n "$repo_path" ]]
	then
		echo ${repo_path:t}
	fi
}
google () {
	open "https://www.google.com/search?q=`echo "${@}" | urlencode`"
}
grename () {
	if [[ -z "$1" || -z "$2" ]]
	then
		echo "Usage: $0 old_branch new_branch"
		return 1
	fi
	git branch -m "$1" "$2"
	if git push origin :"$1"
	then
		git push --set-upstream origin "$2"
	fi
}
gunwipall () {
	local _commit=$(git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H) 
	if [[ "$_commit" != "$(git rev-parse HEAD)" ]]
	then
		git reset $_commit || return 1
	fi
}
handle_completion_insecurities () {
	local -aU insecure_dirs
	insecure_dirs=(${(f@):-"$(compaudit 2>/dev/null)"}) 
	[[ -z "${insecure_dirs}" ]] && return
	print "[oh-my-zsh] Insecure completion-dependent directories detected:"
	ls -ld "${(@)insecure_dirs}"
	cat <<EOD

[oh-my-zsh] For safety, we will not load completions from these directories until
[oh-my-zsh] you fix their permissions and ownership and restart zsh.
[oh-my-zsh] See the above list for directories with group or other writability.

[oh-my-zsh] To fix your permissions you can do so by disabling
[oh-my-zsh] the write permission of "group" and "others" and making sure that the
[oh-my-zsh] owner of these directories is either root or your current user.
[oh-my-zsh] The following command may help:
[oh-my-zsh]     compaudit | xargs chmod g-w,o-w

[oh-my-zsh] If the above didn't help or you want to skip the verification of
[oh-my-zsh] insecure directories you can set the variable ZSH_DISABLE_COMPFIX to
[oh-my-zsh] "true" before oh-my-zsh is sourced in your zshrc file.

EOD
}
hg_prompt_info () {
	return 1
}
hred () {
	[ $# -ge 1 -a -f "$1" ] && input="$1"  || input="-" 
	cat $input | grep --color=auto -E -v '^\s*$|^\s*#.*$'
}
is-at-least () {
	emulate -L zsh
	local IFS=".-" min_cnt=0 ver_cnt=0 part min_ver version order 
	min_ver=(${=1}) 
	version=(${=2:-$ZSH_VERSION} 0) 
	while (( $min_cnt <= ${#min_ver} ))
	do
		while [[ "$part" != <-> ]]
		do
			(( ++ver_cnt > ${#version} )) && return 0
			if [[ ${version[ver_cnt]} = *[0-9][^0-9]* ]]
			then
				order=(${version[ver_cnt]} ${min_ver[ver_cnt]}) 
				if [[ ${version[ver_cnt]} = <->* ]]
				then
					[[ $order != ${${(On)order}} ]] && return 1
				else
					[[ $order != ${${(O)order}} ]] && return 1
				fi
				[[ $order[1] != $order[2] ]] && return 0
			fi
			part=${version[ver_cnt]##*[^0-9]} 
		done
		while true
		do
			(( ++min_cnt > ${#min_ver} )) && return 0
			[[ ${min_ver[min_cnt]} = <-> ]] && break
		done
		(( part > min_ver[min_cnt] )) && return 0
		(( part < min_ver[min_cnt] )) && return 1
		part='' 
	done
}
is_plugin () {
	local base_dir=$1 
	local name=$2 
	builtin test -f $base_dir/plugins/$name/$name.plugin.zsh || builtin test -f $base_dir/plugins/$name/_$name
}
is_theme () {
	local base_dir=$1 
	local name=$2 
	builtin test -f $base_dir/$name.zsh-theme
}
jenv_prompt_info () {
	return 1
}
kj () {
	kubectl "$@" -o json | jq
}
kjx () {
	kubectl "$@" -o json | fx
}
kres () {
	kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}
kutil () {
	for host in $(kubectl get nodes --no-headers | cut -d' ' -f1)
	do
		echo "$host - $(kubectl get nodes -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}' $host)"
		kubecolor describe node "$host" | grep --color=auto --color Allocated -A 5 | grep --color=auto --color -ve Event -ve Allocated -ve percent -ve --
		echo
	done
}
ky () {
	kubectl "$@" -o yaml | yh
}
mise () {
	local command
	command="${1:-}" 
	if [ "$#" = 0 ]
	then
		command /Users/steve.briggs/.local/bin/mise
		return
	fi
	shift
	case "$command" in
		(deactivate | shell | sh) if [[ ! " $@ " =~ " --help " ]] && [[ ! " $@ " =~ " -h " ]]
			then
				eval "$(command /Users/steve.briggs/.local/bin/mise "$command" "$@")"
				return $?
			fi ;;
	esac
	command /Users/steve.briggs/.local/bin/mise "$command" "$@"
}
mkcd () {
	mkdir -p $@ && cd ${@:$#}
}
nvm_prompt_info () {
	which nvm &> /dev/null || return
	local nvm_prompt=${$(nvm current)#v} 
	echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt:gs/%/%%}${ZSH_THEME_NVM_PROMPT_SUFFIX}"
}
omz () {
	setopt localoptions noksharrays
	[[ $# -gt 0 ]] || {
		_omz::help
		return 1
	}
	local command="$1" 
	shift
	(( ${+functions[_omz::$command]} )) || {
		_omz::help
		return 1
	}
	_omz::$command "$@"
}
omz_diagnostic_dump () {
	emulate -L zsh
	builtin echo "Generating diagnostic dump; please be patient..."
	local thisfcn=omz_diagnostic_dump 
	local -A opts
	local opt_verbose opt_noverbose opt_outfile
	local timestamp=$(date +%Y%m%d-%H%M%S) 
	local outfile=omz_diagdump_$timestamp.txt 
	builtin zparseopts -A opts -D -- "v+=opt_verbose" "V+=opt_noverbose"
	local verbose n_verbose=${#opt_verbose} n_noverbose=${#opt_noverbose} 
	(( verbose = 1 + n_verbose - n_noverbose ))
	if [[ ${#*} > 0 ]]
	then
		opt_outfile=$1 
	fi
	if [[ ${#*} > 1 ]]
	then
		builtin echo "$thisfcn: error: too many arguments" >&2
		return 1
	fi
	if [[ -n "$opt_outfile" ]]
	then
		outfile="$opt_outfile" 
	fi
	_omz_diag_dump_one_big_text &> "$outfile"
	if [[ $? != 0 ]]
	then
		builtin echo "$thisfcn: error while creating diagnostic dump; see $outfile for details"
	fi
	builtin echo
	builtin echo Diagnostic dump file created at: "$outfile"
	builtin echo
	builtin echo To share this with OMZ developers, post it as a gist on GitHub
	builtin echo at "https://gist.github.com" and share the link to the gist.
	builtin echo
	builtin echo "WARNING: This dump file contains all your zsh and omz configuration files,"
	builtin echo "so don't share it publicly if there's sensitive information in them."
	builtin echo
}
omz_history () {
	local clear list stamp REPLY
	zparseopts -E -D c=clear l=list f=stamp E=stamp i=stamp t:=stamp
	if [[ -n "$clear" ]]
	then
		print -nu2 "This action will irreversibly delete your command history. Are you sure? [y/N] "
		builtin read -E
		[[ "$REPLY" = [yY] ]] || return 0
		print -nu2 >| "$HISTFILE"
		fc -p "$HISTFILE"
		print -u2 History file deleted.
	elif [[ $# -eq 0 ]]
	then
		builtin fc "${stamp[@]}" -l 1
	else
		builtin fc "${stamp[@]}" -l "$@"
	fi
}
omz_termsupport_cwd () {
	setopt localoptions unset
	local URL_HOST URL_PATH
	URL_HOST="$(omz_urlencode -P $HOST)"  || return 1
	URL_PATH="$(omz_urlencode -P $PWD)"  || return 1
	[[ -z "$KONSOLE_PROFILE_NAME" && -z "$KONSOLE_DBUS_SESSION" ]] || URL_HOST="" 
	printf "\e]7;file://%s%s\e\\" "${URL_HOST}" "${URL_PATH}"
}
omz_termsupport_precmd () {
	[[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return 0
	title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"
}
omz_termsupport_preexec () {
	[[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return 0
	emulate -L zsh
	setopt extended_glob
	local -a cmdargs
	cmdargs=("${(z)2}") 
	if [[ "${cmdargs[1]}" = fg ]]
	then
		local job_id jobspec="${cmdargs[2]#%}" 
		case "$jobspec" in
			(<->) job_id=${jobspec}  ;;
			("" | % | +) job_id=${(k)jobstates[(r)*:+:*]}  ;;
			(-) job_id=${(k)jobstates[(r)*:-:*]}  ;;
			([?]*) job_id=${(k)jobtexts[(r)*${(Q)jobspec}*]}  ;;
			(*) job_id=${(k)jobtexts[(r)${(Q)jobspec}*]}  ;;
		esac
		if [[ -n "${jobtexts[$job_id]}" ]]
		then
			1="${jobtexts[$job_id]}" 
			2="${jobtexts[$job_id]}" 
		fi
	fi
	local CMD="${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}" 
	local LINE="${2:gs/%/%%}" 
	title "$CMD" "%100>...>${LINE}%<<"
}
omz_urldecode () {
	emulate -L zsh
	local encoded_url=$1 
	local caller_encoding=$langinfo[CODESET] 
	local LC_ALL=C 
	export LC_ALL
	local tmp=${encoded_url:gs/+/ /} 
	tmp=${tmp:gs/\\/\\\\/} 
	tmp=${tmp:gs/%/\\x/} 
	local decoded="$(printf -- "$tmp")" 
	local -a safe_encodings
	safe_encodings=(UTF-8 utf8 US-ASCII) 
	if [[ -z ${safe_encodings[(r)$caller_encoding]} ]]
	then
		decoded=$(echo -E "$decoded" | iconv -f UTF-8 -t $caller_encoding) 
		if [[ $? != 0 ]]
		then
			echo "Error converting string from UTF-8 to $caller_encoding" >&2
			return 1
		fi
	fi
	echo -E "$decoded"
}
omz_urlencode () {
	emulate -L zsh
	setopt norematchpcre
	local -a opts
	zparseopts -D -E -a opts r m P
	local in_str="$@" 
	local url_str="" 
	local spaces_as_plus
	if [[ -z $opts[(r)-P] ]]
	then
		spaces_as_plus=1 
	fi
	local str="$in_str" 
	local encoding=$langinfo[CODESET] 
	local safe_encodings
	safe_encodings=(UTF-8 utf8 US-ASCII) 
	if [[ -z ${safe_encodings[(r)$encoding]} ]]
	then
		str=$(echo -E "$str" | iconv -f $encoding -t UTF-8) 
		if [[ $? != 0 ]]
		then
			echo "Error converting string from $encoding to UTF-8" >&2
			return 1
		fi
	fi
	local i byte ord LC_ALL=C 
	export LC_ALL
	local reserved=';/?:@&=+$,' 
	local mark='_.!~*''()-' 
	local dont_escape="[A-Za-z0-9" 
	if [[ -z $opts[(r)-r] ]]
	then
		dont_escape+=$reserved 
	fi
	if [[ -z $opts[(r)-m] ]]
	then
		dont_escape+=$mark 
	fi
	dont_escape+="]" 
	local url_str="" 
	for ((i = 1; i <= ${#str}; ++i )) do
		byte="$str[i]" 
		if [[ "$byte" =~ "$dont_escape" ]]
		then
			url_str+="$byte" 
		else
			if [[ "$byte" == " " && -n $spaces_as_plus ]]
			then
				url_str+="+" 
			elif [[ "$PREFIX" = *com.termux* ]]
			then
				url_str+="$byte" 
			else
				ord=$(( [##16] #byte )) 
				url_str+="%$ord" 
			fi
		fi
	done
	echo -E "$url_str"
}
open_command () {
	local open_cmd
	case "$OSTYPE" in
		(darwin*) open_cmd='open'  ;;
		(cygwin*) open_cmd='cygstart'  ;;
		(linux*) [[ "$(uname -r)" != *icrosoft* ]] && open_cmd='nohup xdg-open'  || {
				open_cmd='cmd.exe /c start ""' 
				[[ -e "$1" ]] && {
					1="$(wslpath -w "${1:a}")"  || return 1
				}
				[[ "$1" = (http|https)://* ]] && {
					1="$(echo "$1" | sed -E 's/([&|()<>^])/^\1/g')"  || return 1
				}
			} ;;
		(msys*) open_cmd='start ""'  ;;
		(*) echo "Platform $OSTYPE not supported"
			return 1 ;;
	esac
	if [[ -n "$BROWSER" && "$1" = (http|https)://* ]]
	then
		"$BROWSER" "$@"
		return
	fi
	${=open_cmd} "$@" &> /dev/null
}
parse_git_dirty () {
	local STATUS
	local -a FLAGS
	FLAGS=('--porcelain') 
	if [[ "$(__git_prompt_git config --get oh-my-zsh.hide-dirty)" != "1" ]]
	then
		if [[ "${DISABLE_UNTRACKED_FILES_DIRTY:-}" == "true" ]]
		then
			FLAGS+='--untracked-files=no' 
		fi
		case "${GIT_STATUS_IGNORE_SUBMODULES:-}" in
			(git)  ;;
			(*) FLAGS+="--ignore-submodules=${GIT_STATUS_IGNORE_SUBMODULES:-dirty}"  ;;
		esac
		STATUS=$(__git_prompt_git status ${FLAGS} 2> /dev/null | tail -n 1) 
	fi
	if [[ -n $STATUS ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
	else
		echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
	fi
}
prompt_starship_precmd () {
	STARSHIP_CMD_STATUS=$? STARSHIP_PIPE_STATUS=(${pipestatus[@]}) 
	if (( ${+STARSHIP_START_TIME} ))
	then
		__starship_get_time && (( STARSHIP_DURATION = STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
		unset STARSHIP_START_TIME
	else
		unset STARSHIP_DURATION STARSHIP_CMD_STATUS STARSHIP_PIPE_STATUS
	fi
	STARSHIP_JOBS_COUNT=${#jobstates} 
}
prompt_starship_preexec () {
	__starship_get_time && STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME 
}
pyenv_prompt_info () {
	return 1
}
rbenv_prompt_info () {
	return 1
}
regexp-replace () {
	argv=("$1" "$2" "$3") 
	4=0 
	[[ -o re_match_pcre ]] && 4=1 
	emulate -L zsh
	local MATCH MBEGIN MEND
	local -a match mbegin mend
	if (( $4 ))
	then
		zmodload zsh/pcre || return 2
		pcre_compile -- "$2" && pcre_study || return 2
		4=0 6= 
		local ZPCRE_OP
		while pcre_match -b -n $4 -- "${(P)1}"
		do
			5=${(e)3} 
			argv+=(${(s: :)ZPCRE_OP} "$5") 
			4=$((argv[-2] + (argv[-3] == argv[-2]))) 
		done
		(($# > 6)) || return
		set +o multibyte
		5= 6=1 
		for 2 3 4 in "$@[7,-1]"
		do
			5+=${(P)1[$6,$2]}$4 
			6=$(($3 + 1)) 
		done
		5+=${(P)1[$6,-1]} 
	else
		4=${(P)1} 
		while [[ -n $4 ]]
		do
			if [[ $4 =~ $2 ]]
			then
				5+=${4[1,MBEGIN-1]}${(e)3} 
				if ((MEND < MBEGIN))
				then
					((MEND++))
					5+=${4[1]} 
				fi
				4=${4[MEND+1,-1]} 
				6=1 
			else
				break
			fi
		done
		[[ -n $6 ]] || return
		5+=$4 
	fi
	eval $1=\$5
}
ruby_prompt_info () {
	echo "$(rvm_prompt_info || rbenv_prompt_info || chruby_prompt_info)"
}
rvm_prompt_info () {
	[ -f $HOME/.rvm/bin/rvm-prompt ] || return 1
	local rvm_prompt
	rvm_prompt=$($HOME/.rvm/bin/rvm-prompt ${=ZSH_THEME_RVM_PROMPT_OPTIONS} 2>/dev/null) 
	[[ -z "${rvm_prompt}" ]] && return 1
	echo "${ZSH_THEME_RUBY_PROMPT_PREFIX}${rvm_prompt:gs/%/%%}${ZSH_THEME_RUBY_PROMPT_SUFFIX}"
}
spectrum_bls () {
	setopt localoptions nopromptsubst
	local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris} 
	for code in {000..255}
	do
		print -P -- "$code: ${BG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
	done
}
spectrum_ls () {
	setopt localoptions nopromptsubst
	local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris} 
	for code in {000..255}
	do
		print -P -- "$code: ${FG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
	done
}
starship_zle-keymap-select () {
	zle reset-prompt
}
svn_prompt_info () {
	return 1
}
take () {
	if [[ $1 =~ ^(https?|ftp).*\.(tar\.(gz|bz2|xz)|tgz)$ ]]
	then
		takeurl "$1"
	elif [[ $1 =~ ^(https?|ftp).*\.(zip)$ ]]
	then
		takezip "$1"
	elif [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]
	then
		takegit "$1"
	else
		takedir "$@"
	fi
}
takedir () {
	mkdir -p $@ && cd ${@:$#}
}
takegit () {
	git clone "$1"
	cd "$(basename ${1%%.git})"
}
takeurl () {
	local data thedir
	data="$(mktemp)" 
	curl -L "$1" > "$data"
	tar xf "$data"
	thedir="$(tar tf "$data" | head -n 1)" 
	rm "$data"
	cd "$thedir"
}
takezip () {
	local data thedir
	data="$(mktemp)" 
	curl -L "$1" > "$data"
	unzip "$data" -d "./"
	thedir="$(unzip -l "$data" | awk 'NR==4 {print $4}' | sed 's/\/.*//')" 
	rm "$data"
	cd "$thedir"
}
tf_prompt_info () {
	return 1
}
tfdocs () {
	open "https://registry.terraform.io/search/providers?q=`echo "${@}" | urlencode`"
}
title () {
	setopt localoptions nopromptsubst
	[[ -n "${INSIDE_EMACS:-}" && "$INSIDE_EMACS" != vterm ]] && return
	: ${2=$1}
	case "$TERM" in
		(cygwin | xterm* | putty* | rxvt* | konsole* | ansi | mlterm* | alacritty* | st* | foot* | contour* | wezterm*) print -Pn "\e]2;${2:q}\a"
			print -Pn "\e]1;${1:q}\a" ;;
		(screen* | tmux*) print -Pn "\ek${1:q}\e\\" ;;
		(*) if [[ "$TERM_PROGRAM" == "iTerm.app" ]]
			then
				print -Pn "\e]2;${2:q}\a"
				print -Pn "\e]1;${1:q}\a"
			else
				if (( ${+terminfo[fsl]} && ${+terminfo[tsl]} ))
				then
					print -Pn "${terminfo[tsl]}$1${terminfo[fsl]}"
				fi
			fi ;;
	esac
}
toggle-fzf-tab () {
	emulate -L zsh -o extended_glob
	if (( $+_ftb_orig_widget ))
	then
		disable-fzf-tab
	else
		enable-fzf-tab
	fi
}
try_alias_value () {
	alias_value "$1" || echo "$1"
}
uninstall_oh_my_zsh () {
	command env ZSH="$ZSH" sh "$ZSH/tools/uninstall.sh"
}
up-line-or-beginning-search () {
	# undefined
	builtin autoload -XU
}
upgrade_oh_my_zsh () {
	echo "${fg[yellow]}Note: \`$0\` is deprecated. Use \`omz update\` instead.$reset_color" >&2
	omz update
}
url-quote-magic () {
	# undefined
	builtin autoload -XUz
}
urldecode () {
	python -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()), end='')"
}
urlencode () {
	python -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.stdin.read()))"
}
vi_mode_prompt_info () {
	return 1
}
virtualenv_prompt_info () {
	return 1
}
work_in_progress () {
	command git -c log.showSignature=false log -n 1 2> /dev/null | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} -q -- "--wip--" && echo "WIP!!"
}
zle-line-finish () {
	echoti rmkx
}
zle-line-init () {
	echoti smkx
}
zrecompile () {
	setopt localoptions extendedglob noshwordsplit noksharrays
	local opt check quiet zwc files re file pre ret map tmp mesg pats
	tmp=() 
	while getopts ":tqp" opt
	do
		case $opt in
			(t) check=yes  ;;
			(q) quiet=yes  ;;
			(p) pats=yes  ;;
			(*) if [[ -n $pats ]]
				then
					tmp=($tmp $OPTARG) 
				else
					print -u2 zrecompile: bad option: -$OPTARG
					return 1
				fi ;;
		esac
	done
	shift OPTIND-${#tmp}-1
	if [[ -n $check ]]
	then
		ret=1 
	else
		ret=0 
	fi
	if [[ -n $pats ]]
	then
		local end num
		while (( $# ))
		do
			end=$argv[(i)--] 
			if [[ end -le $# ]]
			then
				files=($argv[1,end-1]) 
				shift end
			else
				files=($argv) 
				argv=() 
			fi
			tmp=() 
			map=() 
			OPTIND=1 
			while getopts :MR opt $files
			do
				case $opt in
					([MR]) map=(-$opt)  ;;
					(*) tmp=($tmp $files[OPTIND])  ;;
				esac
			done
			shift OPTIND-1 files
			(( $#files )) || continue
			files=($files[1] ${files[2,-1]:#*(.zwc|~)}) 
			(( $#files )) || continue
			zwc=${files[1]%.zwc}.zwc 
			shift 1 files
			(( $#files )) || files=(${zwc%.zwc}) 
			if [[ -f $zwc ]]
			then
				num=$(zcompile -t $zwc | wc -l) 
				if [[ num-1 -ne $#files ]]
				then
					re=yes 
				else
					re= 
					for file in $files
					do
						if [[ $file -nt $zwc ]]
						then
							re=yes 
							break
						fi
					done
				fi
			else
				re=yes 
			fi
			if [[ -n $re ]]
			then
				if [[ -n $check ]]
				then
					[[ -z $quiet ]] && print $zwc needs re-compilation
					ret=0 
				else
					[[ -z $quiet ]] && print -n "re-compiling ${zwc}: "
					if [[ -z "$quiet" ]] && {
							[[ ! -f $zwc ]] || mv -f $zwc ${zwc}.old
						} && zcompile $map $tmp $zwc $files
					then
						print succeeded
					elif ! {
							{
								[[ ! -f $zwc ]] || mv -f $zwc ${zwc}.old
							} && zcompile $map $tmp $zwc $files 2> /dev/null
						}
					then
						[[ -z $quiet ]] && print "re-compiling ${zwc}: failed"
						ret=1 
					fi
				fi
			fi
		done
		return ret
	fi
	if (( $# ))
	then
		argv=(${^argv}/*.zwc(ND) ${^argv}.zwc(ND) ${(M)argv:#*.zwc}) 
	else
		argv=(${^fpath}/*.zwc(ND) ${^fpath}.zwc(ND) ${(M)fpath:#*.zwc}) 
	fi
	argv=(${^argv%.zwc}.zwc) 
	for zwc
	do
		files=(${(f)"$(zcompile -t $zwc)"}) 
		if [[ $files[1] = *\(mapped\)* ]]
		then
			map=-M 
			mesg='succeeded (old saved)' 
		else
			map=-R 
			mesg=succeeded 
		fi
		if [[ $zwc = */* ]]
		then
			pre=${zwc%/*}/ 
		else
			pre= 
		fi
		if [[ $files[1] != *$ZSH_VERSION ]]
		then
			re=yes 
		else
			re= 
		fi
		files=(${pre}${^files[2,-1]:#/*} ${(M)files[2,-1]:#/*}) 
		[[ -z $re ]] && for file in $files
		do
			if [[ $file -nt $zwc ]]
			then
				re=yes 
				break
			fi
		done
		if [[ -n $re ]]
		then
			if [[ -n $check ]]
			then
				[[ -z $quiet ]] && print $zwc needs re-compilation
				ret=0 
			else
				[[ -z $quiet ]] && print -n "re-compiling ${zwc}: "
				tmp=(${^files}(N)) 
				if [[ $#tmp -ne $#files ]]
				then
					[[ -z $quiet ]] && print 'failed (missing files)'
					ret=1 
				else
					if [[ -z "$quiet" ]] && mv -f $zwc ${zwc}.old && zcompile $map $zwc $files
					then
						print $mesg
					elif ! {
							mv -f $zwc ${zwc}.old && zcompile $map $zwc $files 2> /dev/null
						}
					then
						[[ -z $quiet ]] && print "re-compiling ${zwc}: failed"
						ret=1 
					fi
				fi
			fi
		fi
	done
	return ret
}
zsh_stats () {
	fc -l 1 | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' | grep -v "./" | sort -nr | head -n 20 | column -c3 -s " " -t | nl
}
# Shell Options
setopt alwaystoend
setopt autocd
setopt autopushd
setopt completeinword
setopt extendedhistory
setopt noflowcontrol
setopt nohashdirs
setopt histexpiredupsfirst
setopt histignoredups
setopt histignorespace
setopt histverify
setopt interactivecomments
setopt login
setopt longlistjobs
setopt promptsubst
setopt pushdignoredups
setopt pushdminus
setopt sharehistory
# Aliases
alias -- -='cd -'
alias -- ..='cd ..'
alias -- ...=../..
alias -- ....=../../..
alias -- .....=../../../..
alias -- ......=../../../../..
alias -- .1='cd ..'
alias -- .2='cd ../../'
alias -- .3='cd ../../../'
alias -- .4=../../../../
alias -- .5='cd ../../../../../'
alias -- 1='cd -1'
alias -- 2='cd -2'
alias -- 3='cd -3'
alias -- 4='cd -4'
alias -- 5='cd -5'
alias -- 6='cd -6'
alias -- 7='cd -7'
alias -- 8='cd -8'
alias -- 9='cd -9'
alias -- APPS='cd ${HOME}/GIT_REPOS/APPLICATION-DEPLOYMENTS'
alias -- EKS-BASE='cd ${HOME}/GIT_REPOS/EKS-BASE-DEPLOY'
alias -- Gerp=grep
alias -- Grep=grep
alias -- INFRA='cd ${HOME}/GIT_REPOS/CLOUD-INFRASTRUCTURE-TERRAFORM'
alias -- K8S-BASE='cd ${HOME}/GIT_REPOS/K8S-BASE-DEPLOY'
alias -- _='sudo '
alias -- ac=aws-cred
alias -- av=aws-vault
alias -- config='/usr/bin/git --git-dir=$HOME/.cfg/.git/ --work-tree=$HOME'
alias -- cp='cp -i'
alias -- current_branch=$'\n    print -Pu2 "%F{yellow}[oh-my-zsh] \'%F{red}current_branch%F{yellow}\' is deprecated, using \'%F{green}git_current_branch%F{yellow}\' instead.%f"\n    git_current_branch'
alias -- diff='colordiff --side-by-side --suppress-common-lines'
alias -- dog=cat
alias -- egrep='egrep --color=auto'
alias -- emacs=nvim
alias -- fgrep='fgrep --color=auto'
alias -- fqdn='kubectl get ingress -o json | jq '\''.items[] | .metadata.namespace + ": " + .metadata.annotations."external-dns.alpha.kubernetes.io/hostname"'\'
alias -- fqdna='kubectl get ingress --all-namespaces -o json | jq '\''.items[] | .metadata.namespace + ": " + .metadata.annotations."external-dns.alpha.kubernetes.io/hostname"'\'
alias -- fudns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias -- g=git
alias -- ga='git add'
alias -- gaa='git add --all'
alias -- gam='git am'
alias -- gama='git am --abort'
alias -- gamc='git am --continue'
alias -- gams='git am --skip'
alias -- gamscp='git am --show-current-patch'
alias -- gap='git apply'
alias -- gapa='git add --patch'
alias -- gapt='git apply --3way'
alias -- gau='git add --update'
alias -- gav='git add --verbose'
alias -- gb='git branch'
alias -- gbD='git branch --delete --force'
alias -- gba='git branch --all'
alias -- gbd='git branch --delete'
alias -- gbg='LANG=C git branch -vv | grep ": gone\]"'
alias -- gbgD='LANG=C git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '\''{print $1}'\'' | xargs git branch -D'
alias -- gbgd='LANG=C git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '\''{print $1}'\'' | xargs git branch -d'
alias -- gbl='git blame -w'
alias -- gbm='git branch --move'
alias -- gbnm='git branch --no-merged'
alias -- gbr='git branch --remote'
alias -- gbs='git bisect'
alias -- gbsb='git bisect bad'
alias -- gbsg='git bisect good'
alias -- gbsn='git bisect new'
alias -- gbso='git bisect old'
alias -- gbsr='git bisect reset'
alias -- gbss='git bisect start'
alias -- gc='git commit --verbose'
alias -- gc!='git commit --verbose --amend'
alias -- gcB='git checkout -B'
alias -- gca='git commit --verbose --all'
alias -- gca!='git commit --verbose --all --amend'
alias -- gcam='git commit --all --message'
alias -- gcan!='git commit --verbose --all --no-edit --amend'
alias -- gcann!='git commit --verbose --all --date=now --no-edit --amend'
alias -- gcans!='git commit --verbose --all --signoff --no-edit --amend'
alias -- gcas='git commit --all --signoff'
alias -- gcasm='git commit --all --signoff --message'
alias -- gcb='git checkout -b'
alias -- gcd='git checkout $(git_develop_branch)'
alias -- gcf='git config --list'
alias -- gcfu='git commit --fixup'
alias -- gcl='git clone --recurse-submodules'
alias -- gclean='git clean --interactive -d'
alias -- gclf='git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules'
alias -- gcm='git checkout $(git_main_branch)'
alias -- gcmsg='git commit --message'
alias -- gcn='git commit --verbose --no-edit'
alias -- gcn!='git commit --verbose --no-edit --amend'
alias -- gco='git checkout'
alias -- gcor='git checkout --recurse-submodules'
alias -- gcount='git shortlog --summary --numbered'
alias -- gcp='git cherry-pick'
alias -- gcpa='git cherry-pick --abort'
alias -- gcpc='git cherry-pick --continue'
alias -- gcs='git commit --gpg-sign'
alias -- gcsm='git commit --signoff --message'
alias -- gcss='git commit --gpg-sign --signoff'
alias -- gcssm='git commit --gpg-sign --signoff --message'
alias -- gd='git diff'
alias -- gdca='git diff --cached'
alias -- gdct='git describe --tags $(git rev-list --tags --max-count=1)'
alias -- gdcw='git diff --cached --word-diff'
alias -- gds='git diff --staged'
alias -- gdt='git diff-tree --no-commit-id --name-only -r'
alias -- gdup='git diff @{upstream}'
alias -- gdw='git diff --word-diff'
alias -- gerp=grep
alias -- gf='git fetch'
alias -- gfa='git fetch --all --tags --prune --jobs=10'
alias -- gfg='git ls-files | grep'
alias -- gfo='git fetch origin'
alias -- gg='git gui citool'
alias -- gga='git gui citool --amend'
alias -- ggpull='git pull origin "$(git_current_branch)"'
alias -- ggpur=ggu
alias -- ggpush='git push origin "$(git_current_branch)"'
alias -- ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias -- ghh='git help'
alias -- gignore='git update-index --assume-unchanged'
alias -- gignored='git ls-files -v | grep "^[[:lower:]]"'
alias -- git-svn-dcommit-push='git svn dcommit && git push github $(git_main_branch):svntrunk'
alias -- gk='\gitk --all --branches &!'
alias -- gke='\gitk --all $(git log --walk-reflogs --pretty=%h) &!'
alias -- gl='git pull'
alias -- glg='git log --stat'
alias -- glgg='git log --graph'
alias -- glgga='git log --graph --decorate --all'
alias -- glgm='git log --graph --max-count=10'
alias -- glgp='git log --stat --patch'
alias -- glo='git log --oneline --decorate'
alias -- glod='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
alias -- glods='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
alias -- glog='git log --oneline --decorate --graph'
alias -- gloga='git log --oneline --decorate --graph --all'
alias -- glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias -- glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias -- glols='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
alias -- glp=_git_log_prettily
alias -- gluc='git pull upstream $(git_current_branch)'
alias -- glum='git pull upstream $(git_main_branch)'
alias -- gm='git merge'
alias -- gma='git merge --abort'
alias -- gmc='git merge --continue'
alias -- gmff='git merge --ff-only'
alias -- gmom='git merge origin/$(git_main_branch)'
alias -- gms='git merge --squash'
alias -- gmtl='git mergetool --no-prompt'
alias -- gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias -- gmum='git merge upstream/$(git_main_branch)'
alias -- gp='git push'
alias -- gpd='git push --dry-run'
alias -- gpf='git push --force-with-lease --force-if-includes'
alias -- gpf!='git push --force'
alias -- gpoat='git push origin --all && git push origin --tags'
alias -- gpod='git push origin --delete'
alias -- gpr='git pull --rebase'
alias -- gpra='git pull --rebase --autostash'
alias -- gprav='git pull --rebase --autostash -v'
alias -- gpristine='git reset --hard && git clean --force -dfx'
alias -- gprom='git pull --rebase origin $(git_main_branch)'
alias -- gpromi='git pull --rebase=interactive origin $(git_main_branch)'
alias -- gprum='git pull --rebase upstream $(git_main_branch)'
alias -- gprumi='git pull --rebase=interactive upstream $(git_main_branch)'
alias -- gprv='git pull --rebase -v'
alias -- gpsup='git push --set-upstream origin $(git_current_branch)'
alias -- gpsupf='git push --set-upstream origin $(git_current_branch) --force-with-lease --force-if-includes'
alias -- gpu='git push upstream'
alias -- gpv='git push --verbose'
alias -- gr='git remote'
alias -- gra='git remote add'
alias -- grb='git rebase'
alias -- grba='git rebase --abort'
alias -- grbc='git rebase --continue'
alias -- grbd='git rebase $(git_develop_branch)'
alias -- grbi='git rebase --interactive'
alias -- grbm='git rebase $(git_main_branch)'
alias -- grbo='git rebase --onto'
alias -- grbom='git rebase origin/$(git_main_branch)'
alias -- grbs='git rebase --skip'
alias -- grbum='git rebase upstream/$(git_main_branch)'
alias -- grep='grep --color=auto'
alias -- grev='git revert'
alias -- greva='git revert --abort'
alias -- grevc='git revert --continue'
alias -- grf='git reflog'
alias -- grh='git reset'
alias -- grhh='git reset --hard'
alias -- grhk='git reset --keep'
alias -- grhs='git reset --soft'
alias -- grm='git rm'
alias -- grmc='git rm --cached'
alias -- grmv='git remote rename'
alias -- groh='git reset origin/$(git_current_branch) --hard'
alias -- grrm='git remote remove'
alias -- grs='git restore'
alias -- grset='git remote set-url'
alias -- grss='git restore --source'
alias -- grst='git restore --staged'
alias -- grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias -- gru='git reset --'
alias -- grup='git remote update'
alias -- grv='git remote --verbose'
alias -- gsb='git status --short --branch'
alias -- gsd='git svn dcommit'
alias -- gsh='git show'
alias -- gsi='git submodule init'
alias -- gsps='git show --pretty=short --show-signature'
alias -- gsr='git svn rebase'
alias -- gss='git status --short'
alias -- gst='git status'
alias -- gsta='git stash push'
alias -- gstaa='git stash apply'
alias -- gstall='git stash --all'
alias -- gstc='git stash clear'
alias -- gstd='git stash drop'
alias -- gstl='git stash list'
alias -- gstp='git stash pop'
alias -- gsts='git stash show --patch'
alias -- gstu='gsta --include-untracked'
alias -- gsu='git submodule update'
alias -- gsw='git switch'
alias -- gswc='git switch --create'
alias -- gswd='git switch $(git_develop_branch)'
alias -- gswm='git switch $(git_main_branch)'
alias -- gta='git tag --annotate'
alias -- gtl='gtl(){ git tag --sort=-v:refname -n --list "${1}*" }; noglob gtl'
alias -- gts='git tag --sign'
alias -- gtv='git tag | sort -V'
alias -- gunignore='git update-index --no-assume-unchanged'
alias -- gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
alias -- gwch='git log --patch --abbrev-commit --pretty=medium --raw'
alias -- gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
alias -- gwipe='git reset --hard && git clean --force -df'
alias -- gwt='git worktree'
alias -- gwta='git worktree add'
alias -- gwtls='git worktree list'
alias -- gwtmv='git worktree move'
alias -- gwtrm='git worktree remove'
alias -- header='curl -I'
alias -- headerc='curl -I --compress'
alias -- history=omz_history
alias -- hr='printf $(printf "\e[$(shuf -i 91-97 -n 1);1m%%%ds\e[0m\n" $(tput cols)) | tr " " ='
alias -- iac='cd $HOME/projects/IAC'
alias -- k=kubectl
alias -- kaf='kubectl apply -f'
alias -- kapk='kubectl apply -k'
alias -- kbug='kubectl run -i --tty --rm debug --image=ubuntu --restart=Never -- /bin/bash'
alias -- kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'
alias -- kccc='kubectl config current-context'
alias -- kcdc='kubectl config delete-context'
alias -- kcgc='kubectl config get-contexts'
alias -- kcn='kubectl config set-context --current --namespace'
alias -- kcp='kubectl cp'
alias -- kcsc='kubectl config set-context'
alias -- kcuc='kubectl config use-context'
alias -- kd='kubectl describe'
alias -- kdcj='kubectl describe cronjob'
alias -- kdcm='kubectl describe configmap'
alias -- kdd='kubectl describe deployment'
alias -- kdds='kubectl describe daemonset'
alias -- kdel='kubectl delete'
alias -- kdelcj='kubectl delete cronjob'
alias -- kdelcm='kubectl delete configmap'
alias -- kdeld='kubectl delete deployment'
alias -- kdelds='kubectl delete daemonset'
alias -- kdelf='kubectl delete -f'
alias -- kdeli='kubectl delete ingress'
alias -- kdelj='kubectl delete job'
alias -- kdelk='kubectl delete -k'
alias -- kdelno='kubectl delete node'
alias -- kdelns='kubectl delete namespace'
alias -- kdelp='kubectl delete pods'
alias -- kdelpvc='kubectl delete pvc'
alias -- kdels='kubectl delete svc'
alias -- kdelsa='kubectl delete sa'
alias -- kdelsec='kubectl delete secret'
alias -- kdelss='kubectl delete statefulset'
alias -- kdi='kubectl describe ingress'
alias -- kdic='kubectl describe ingressclass'
alias -- kdj='kubectl describe job'
alias -- kdno='kubectl describe node'
alias -- kdns='kubectl describe namespace'
alias -- kdp='kubectl describe pods'
alias -- kdpv='kubectl describe pv'
alias -- kdpvc='kubectl describe pvc'
alias -- kdrs='kubectl describe replicaset'
alias -- kds='kubectl describe svc'
alias -- kdsa='kubectl describe sa'
alias -- kdsec='kubectl describe secret'
alias -- kdss='kubectl describe statefulset'
alias -- kecj='kubectl edit cronjob'
alias -- kecm='kubectl edit configmap'
alias -- ked='kubectl edit deployment'
alias -- keds='kubectl edit daemonset'
alias -- kei='kubectl edit ingress'
alias -- kej='kubectl edit job'
alias -- keno='kubectl edit node'
alias -- kens='kubectl edit namespace'
alias -- kep='kubectl edit pods'
alias -- kepvc='kubectl edit pvc'
alias -- kers='kubectl edit replicaset'
alias -- kes='kubectl edit svc'
alias -- kess='kubectl edit statefulset'
alias -- keti='kubectl exec -t -i'
alias -- kg='kubectl get'
alias -- kga='kubectl get all'
alias -- kgaa='kubectl get all --all-namespaces'
alias -- kgcj='kubectl get cronjob'
alias -- kgcm='kubectl get configmaps'
alias -- kgcma='kubectl get configmaps --all-namespaces'
alias -- kgd='kubectl get deployment'
alias -- kgda='kubectl get deployment --all-namespaces'
alias -- kgds='kubectl get daemonset'
alias -- kgdsa='kubectl get daemonset --all-namespaces'
alias -- kgdsw='kgds --watch'
alias -- kgdw='kgd --watch'
alias -- kgdwide='kgd -o wide'
alias -- kge='kubectl get events'
alias -- kgew='kubectl get events --sort-by=".lastTimestamp" --watch'
alias -- kgi='kubectl get ingress'
alias -- kgia='kubectl get ingress --all-namespaces'
alias -- kgic='kubectl get ingressclass'
alias -- kgj='kubectl get job'
alias -- kgn='kubectl get nodes --sort-by=.metadata.creationTimestamp'
alias -- kgno='kubectl get nodes'
alias -- kgnosl='kubectl get nodes --show-labels'
alias -- kgns='kubectl get namespaces'
alias -- kgp='kubectl get pods'
alias -- kgpa='kubectl get pods --all-namespaces'
alias -- kgpall='kubectl get pods --all-namespaces -o wide'
alias -- kgpl='kgp -l'
alias -- kgpn='kgp -n'
alias -- kgprc='kubectl get pods --sort-by='\''.status.containerStatuses[0].restartCount'\'
alias -- kgprca='kubectl get pods --all-namespaces --sort-by='\''.status.containerStatuses[0].restartCount'\'
alias -- kgpsl='kubectl get pods --show-labels'
alias -- kgpv='kubectl get pv'
alias -- kgpvc='kubectl get pvc'
alias -- kgpvca='kubectl get pvc --all-namespaces'
alias -- kgpvcw='kgpvc --watch'
alias -- kgpw='kgp --watch'
alias -- kgpwide='kgp -o wide'
alias -- kgrs='kubectl get replicaset'
alias -- kgs='kubectl get svc'
alias -- kgsa='kubectl get svc --all-namespaces'
alias -- kgsec='kubectl get secret'
alias -- kgseca='kubectl get secret --all-namespaces'
alias -- kgss='kubectl get statefulset'
alias -- kgssa='kubectl get statefulset --all-namespaces'
alias -- kgssw='kgss --watch'
alias -- kgsswide='kgss -o wide'
alias -- kgsw='kgs --watch'
alias -- kgswide='kgs -o wide'
alias -- kl='kubectl logs'
alias -- kl1h='kubectl logs --since 1h'
alias -- kl1m='kubectl logs --since 1m'
alias -- kl1s='kubectl logs --since 1s'
alias -- klf='kubectl logs -f'
alias -- klf1h='kubectl logs --since 1h -f'
alias -- klf1m='kubectl logs --since 1m -f'
alias -- klf1s='kubectl logs --since 1s -f'
alias -- klt='kubectl logs -f'
alias -- kn=kubens
alias -- kpf='kubectl port-forward'
alias -- krh='kubectl rollout history'
alias -- krrd='kubectl rollout restart deployment'
alias -- krrss='kubectl rollout restart statefulset'
alias -- krsd='kubectl rollout status deployment'
alias -- krsss='kubectl rollout status statefulset'
alias -- kru='kubectl rollout undo'
alias -- ksd='kubectl scale deployment'
alias -- ksss='kubectl scale statefulset'
alias -- ku=kustomize
alias -- kub='kustomize build --enable-alpha-plugins --load-restrictor LoadRestrictionsNone'
alias -- kubectl=kubecolor
alias -- kx=kubectx
alias -- l=lsd
alias -- la='lsd -aF'
alias -- ll='ls -lh'
alias -- ln='ln -i'
alias -- ls='lsd -lahtr'
alias -- lsa='ls -lah'
alias -- lstar='tar -tvf'
alias -- md='mkdir -p'
alias -- mv='mv -i'
alias -- nano=nvim
alias -- notepad.exe=nvim
alias -- perms='stat -f "%A %Sp -> owner=%SHp group=%SMp other=%SLp"'
alias -- pydocs='open https://docs.python.org/3.13/py-modindex.html'
alias -- rd=rmdir
alias -- reboot='sudo reboot'
alias -- rm='rm -i'
alias -- run-help=man
alias -- tg=terragrunt
alias -- tga='terragrunt apply'
alias -- tgaA='terragrunt apply -auto-approve'
alias -- tgas='terragrunt apply --terragrunt-source-update'
alias -- tgasA='terragrunt apply --terragrunt-source-update -auto-approve'
alias -- tgi='terragrunt init'
alias -- tgis='terragrunt init --terragrunt-source-update'
alias -- tglo='terragrunt providers lock -platform=linux_arm64 -platform=linux_amd64 -platform=darwin_amd64 -platform=darwin_arm6'
alias -- tgo='terragrunt output'
alias -- tgp='terragrunt plan'
alias -- tgps='terragrunt plan --terragrunt-source-update'
alias -- tkl='tsh kube ls'
alias -- untar='tar -zxvf'
alias -- vi=nvim
alias -- which-command=whence
# Check for rg availability
if ! (unalias rg 2>/dev/null; command -v rg) >/dev/null 2>&1; then
  function rg {
  local _cc_bin="${CLAUDE_CODE_EXECPATH:-}"
  [[ -x $_cc_bin ]] || _cc_bin=/Users/steve.briggs/.local/bin/claude
  if [[ ! -x $_cc_bin ]]; then command rg "$@"; return; fi
  if [[ -n $ZSH_VERSION ]]; then
    ARGV0=rg "$_cc_bin" "$@"
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    ARGV0=rg "$_cc_bin" "$@"
  elif [[ $BASHPID != $$ ]]; then
    exec -a rg "$_cc_bin" "$@"
  else
    (exec -a rg "$_cc_bin" "$@")
  fi
}
fi
# Shadow find/grep with embedded bfs/ugrep
unalias find 2>/dev/null || true
unalias grep 2>/dev/null || true
function find {
  local _cc_bin="${CLAUDE_CODE_EXECPATH:-}"
  [[ -x $_cc_bin ]] || _cc_bin=/Users/steve.briggs/.local/bin/claude
  if [[ ! -x $_cc_bin ]]; then command find "$@"; return; fi
  if [[ -n $ZSH_VERSION ]]; then
    ARGV0=bfs "$_cc_bin" -S dfs -regextype findutils-default "$@"
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    ARGV0=bfs "$_cc_bin" -S dfs -regextype findutils-default "$@"
  elif [[ $BASHPID != $$ ]]; then
    exec -a bfs "$_cc_bin" -S dfs -regextype findutils-default "$@"
  else
    (exec -a bfs "$_cc_bin" -S dfs -regextype findutils-default "$@")
  fi
}
function grep {
  local _cc_bin="${CLAUDE_CODE_EXECPATH:-}"
  [[ -x $_cc_bin ]] || _cc_bin=/Users/steve.briggs/.local/bin/claude
  if [[ ! -x $_cc_bin ]]; then command grep "$@"; return; fi
  if [[ -n $ZSH_VERSION ]]; then
    ARGV0=ugrep "$_cc_bin" -G --ignore-files --hidden -I --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --exclude-dir=.bzr --exclude-dir=.jj --exclude-dir=.sl "$@"
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    ARGV0=ugrep "$_cc_bin" -G --ignore-files --hidden -I --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --exclude-dir=.bzr --exclude-dir=.jj --exclude-dir=.sl "$@"
  elif [[ $BASHPID != $$ ]]; then
    exec -a ugrep "$_cc_bin" -G --ignore-files --hidden -I --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --exclude-dir=.bzr --exclude-dir=.jj --exclude-dir=.sl "$@"
  else
    (exec -a ugrep "$_cc_bin" -G --ignore-files --hidden -I --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --exclude-dir=.bzr --exclude-dir=.jj --exclude-dir=.sl "$@")
  fi
}
export PATH='/opt/homebrew/opt/findutils/libexec/gnubin:/Users/steve.briggs/.local/share/mise/installs/go/1.26.2/bin:/Users/steve.briggs/.local/share/mise/installs/kubectl/1.33.0/bin:/Users/steve.briggs/.local/share/mise/installs/kustomize/5.6.0/bin:/Users/steve.briggs/.local/share/mise/installs/mockery/3.5.0:/Users/steve.briggs/.local/share/mise/installs/golangci-lint/2.11.4:/Users/steve.briggs/.local/share/mise/installs/helm/3.18.4/bin:/Users/steve.briggs/.local/share/mise/installs/gci/0.13.7/bin:/Users/steve.briggs/.local/share/mise/installs/shellcheck/0.10.0/shellcheck-v0.10.0:/Users/steve.briggs/.local/share/mise/installs/temporal/1.5.1:/Users/steve.briggs/.local/share/mise/installs/terraform/1.9.8/bin:/Users/steve.briggs/.local/share/mise/installs/terragrunt/0.99.1/bin:/Users/steve.briggs/.local/share/mise/installs/kubecolor/0.5.3/bin:/Users/steve.briggs/.local/share/mise/installs/terraform-docs/0.18.0/bin:/Users/steve.briggs/.local/share/mise/installs/cilium-cli/0.16.16/bin:/Users/steve.briggs/.local/share/mise/installs/vault/1.18.3/bin:/Users/steve.briggs/.local/share/mise/installs/awscli/2.25.13/bin:/Users/steve.briggs/.local/share/mise/installs/kubectx/0.9.5/bin:/Users/steve.briggs/.local/share/mise/installs/jq/1.7.1/bin:/Users/steve.briggs/.local/share/mise/installs/yq/4.44.2/bin:/Users/steve.briggs/.local/share/mise/installs/ghorg/1.9.12/bin:/Users/steve.briggs/.local/share/mise/installs/lsd/1.2.0/bin:/Users/steve.briggs/.local/share/mise/installs/direnv/2.34.0/bin:/Users/steve.briggs/.local/share/mise/installs/ripgrep/15.1.0/bin:/Users/steve.briggs/.local/share/mise/installs/aws-vault/7.2.0/bin:/Users/steve.briggs/.local/share/mise/installs/1password-cli/2.29.0/bin:/Users/steve.briggs/.local/share/mise/installs/python/3.12.4/bin:/Users/steve.briggs/.local/share/mise/installs/dagger/0.13.6/bin:/opt/homebrew/bin:/usr/local/bin:/Users/steve.briggs/.local/bin:/opt/homebrew/bin:/usr/local/bin:/Users/steve.briggs/.local/bin:/Users/steve.briggs/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/pmk/env/global/bin:/usr/local/munki:/Users/steve.briggs/.cargo/bin:/Applications/Ghostty.app/Contents/MacOS:/Users/steve.briggs/.cargo/bin:/Users/steve.briggs/.cargo/bin:/Users/steve.briggs/.local/bin/custom:/Users/steve.briggs/.pyenv/bin:/Users/steve.briggs/.config/cloud-ops/scripts:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/usr/local/opt/openssl/bin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/curl/bin:/opt/homebrew/opt/findutils/libexec/gnubin:/Users/steve.briggs/.local/bin/custom:/Users/steve.briggs/.pyenv/bin:/Users/steve.briggs/.config/cloud-ops/scripts:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/usr/local/opt/openssl/bin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/curl/bin:/Users/steve.briggs/.krew/bin:/Users/steve.briggs/.bin:/Users/steve.briggs/go/bin/:/private/var/folders/ky/m6p32md91_n2q6z94fdn8fsw0000gq/T/AppTranslocation/F252CD76-5A71-4D7F-8826-12175DB43E32/d/Visual Studio Code.app/Contents/Resources/app/bin:/Users/steve.briggs/.krew/bin:/Users/steve.briggs/.bin:/Users/steve.briggs/go/bin/:/private/var/folders/ky/m6p32md91_n2q6z94fdn8fsw0000gq/T/AppTranslocation/F252CD76-5A71-4D7F-8826-12175DB43E32/d/Visual Studio Code.app/Contents/Resources/app/bin:/Users/steve.briggs/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/bin:/Users/steve.briggs/claude-brain/bin'
