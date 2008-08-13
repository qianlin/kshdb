# -*- shell-script -*-
# where.cmd - gdb-like "where" debugger command
#
#   Copyright (C) 2008 Rocky Bernstein rocky@gnu.org
#
#   kshdb is free software; you can redistribute it and/or modify it under
#   the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2, or (at your option) any later
#   version.
#
#   kshdb is distributed in the hope that it will be useful, but WITHOUT ANY
#   WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#   for more details.
#   
#   You should have received a copy of the GNU General Public License along
#   with kshdb; see the file COPYING.  If not, write to the Free Software
#   Foundation, 59 Temple Place, Suite 330, Boston, MA 02111 USA.

# This code assumes the version of ksh where functrace has file names
# and absolute line positions, not function names and offset.

_Dbg_add_help where \
"where [n] 	- Stack trace of calling functions or source'd files."

# Print a stack backtrace.  
# $1 is the maximum number of entries to include.
_Dbg_do_backtrace() {

  _Dbg_not_running && return 1

  typeset prefix='##'
  typeset -i n=${#_Dbg_frame_stack[@]}
  typeset -i count=${1:-$n}
  typeset -i i=1

  # Loop which dumps out stack trace.
  for (( i=0 ; (( i < n && count > 0 )) ; i++ )) ; do 
      typeset prefix='##'
      (( i == _Dbg_stack_pos)) && prefix='->'
      prefix+="$i in"
      _Dbg_print_frame "$i" "$prefix"
      ((count--))
  done
  return 0
}

_Dbg_add_alias bt where
_Dbg_add_alias T where
_Dbg_add_alias backtrace where
