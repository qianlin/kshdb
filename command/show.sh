# -*- shell-script -*-
# show.sh - Show debugger settings
#
#   Copyright (C) 2008, 2009, 2010, 2011 Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

# Sets whether or not to display command to be executed in debugger prompt.
# If yes, always show. If auto, show only if the same line is to be run
# but the command is different.
typeset _Dbg_show_command="auto"

typeset -A _Dbg_debugger_show_commands

typeset -A _Dbg_command_help_show

# subcommands whose current values are not shown in a "show" list . 
# These are things like alias, warranty, or copying.
# They are available if asked for explicitly, e.g. "show copying"
typeset -A _Dbg_show_nolist

_Dbg_help_add show '' 1 # Help routine is elsewhere

# Load in "show" subcommands
for _Dbg_file in ${_Dbg_libdir}/command/show_sub/*.sh ; do
    source $_Dbg_file
done

_Dbg_do_show() {
    typeset subcmd=$1
    (($# >= 1)) && shift
    typeset label=$1
    (($# >= 1)) && shift

    # Warranty, copying, directories, and aliases are omitted below.
    typeset subcmds='annotate args autoeval autolist basename debug different listsize prompt trace-commands width'

    if [[ -z $subcmd ]] ; then 
	typeset thing
	for thing in $subcmds ; do 
	    _Dbg_do_show $thing 1
	done
	return 0
    elif [[ -n ${_Dbg_debugger_show_commands[$subcmd]} ]] ; then
	${_Dbg_debugger_show_commands[$subcmd]} $label "$@"
	return 0
    fi
    
    case $subcmd in 
	lin | line | linet | linetr | linetra | linetrac | linetrace )
	    [[ -n $label ]] && label='line tracing: '
	    typeset onoff="off."
	    (( _Dbg_set_linetrace != 0 )) && onoff='on.'
	    _Dbg_msg \
		"${label}Show line tracing is" $onoff
	    _Dbg_msg \
		"${label}Show line trace delay is ${_Dbg_linetrace_delay}."
	    return 0
	    ;;
	
	lo | log | logg | loggi | loggin | logging )
	    shift
	    _Dbg_do_show_logging $*
	    ;;
	sho|show|showc|showco|showcom|showcomm|showcomma|showcomman|showcommand )
	    [[ -n $label ]] && label='showcommand: '
	    _Dbg_msg \
		"${label}Show commands in debugger prompt is" \
		"$_Dbg_show_command."
	    return 0
	    ;;
	t|tr|tra|trac|trace|trace-|tracec|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
	    [[ -n $label ]] && label='trace-commands: '
	    _Dbg_msg \
		"${label}State of command tracing is" \
		"$_Dbg_set_trace_commands."
	    return 0
	    ;;
	*)
	    _Dbg_errmsg "Unknown show subcommand: $subcmd"
	    _Dbg_errmsg "Show subcommands are:"
	    typeset -a do_list=(${subcmds[@]})
	    _Dbg_list_columns do_list '  ' errmsg
	    return 1
    esac
}
