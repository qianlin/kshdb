# -*- shell-script -*-
#================ VARIABLE INITIALIZATIONS ====================#

# Where are we in stack? This can be changed by "up", "down" or "frame"
# commands.

typeset -i _Dbg_stack_pos=0

typeset -T Frame_t=(
	filename=''
	integer lineno=0
	fn=''
	to_file_line()
	{
	    print -r "file \`${_.filename}' at line ${_.lineno}"
	}
)

Frame_t -a _Dbg_frame_stack  #=() causes a problem
_Dbg_frame_stack=()
save_callstack() {
    integer start=${1:-0}
    integer .level=.sh.level-$start .max=.sh.level-$start
    typeset -a .files=()
    typeset -a .linenos=()
    typeset -a .fns=()
    # Frame_t -a ._Dbg_frame_stack gives segv
    while((--.level>=0)); do
	((.sh.level = .level))
	.files+=("${.sh.file}")
	.linenos+=(${.sh.lineno})
	.fns+=($0)
    done
    # Reorganize into an array of frame structures
    integer i
    for ((i=0; i<.max-start; i++)) ; do 
	_Dbg_frame_stack[i].filename=${.files[i]}
	_Dbg_frame_stack[i].lineno=${.linenos[i]}
	_Dbg_frame_stack[i].fn=${.fns[$i]}
    done
    for ((i=${#_Dbg_frame_stack[@]}-1; $i>=.max-start; i--)); do
	unset _Dbg_frame_stack[$i]
    done
 }

# # For debugging
# print_callstack() {
#     integer i
#     for ((i=0; i<${#_Dbg_frame_stack[@]}; i++)) ; do 
# 	print -r -- ${_Dbg_frame_stack[$i].to_file_line}
#     done
#     print ======
# }

_Dbg_adjust_frame() {
  typeset -i count=$1
  typeset -i signum=$2

  typeset -i retval
  _Dbg_stack_int_setup $count || return 

  typeset -i pos
  if (( signum==0 )) ; then
    if (( count < 0 )) ; then
      ((pos=${#_Dbg_frame_stack[@]}+count))
    else
      ((pos=count))
    fi
  else
    ((pos=_Dbg_stack_pos-1+(count*signum)))
  fi

  if (( $pos < 0 )) ; then 
    _Dbg_msg 'Would be beyond bottom-most (most recent) entry.'
    return 1
  elif (( $pos >= ${#_Dbg_frame_stack[@]} )) ; then 
    _Dbg_msg 'Would be beyond top-most (least recent) entry.'
    return 1
  fi

  ((_Dbg_stack_pos = pos+1))
# #   typeset -i j=_Dbg_stack_pos+2
# #   _Dbg_listline=${BASH_LINENO[$j]}
# #   ((j++))
# #   _cur_source_file=${BASH_SOURCE[$j]}
# #   _Dbg_print_source_line $_Dbg_listline
#   return 0
}

# Tests for a signed integer parameter and set global retval
# if everything is okay. Retval is set to 1 on error
_Dbg_stack_int_setup() {

  if (( ! _Dbg_running )) ; then
    _Dbg_errmsg "No stack."
    return 1
  else
#     setopt EXTENDED_GLOB
#     if [[ $1 != '' && $1 != ([-+]|)([0-9])## ]] ; then 
#       _Dbg_msg "Bad integer parameter: $1"
#       # Reset EXTENDED_GLOB
#       return 1
#     fi
#     # Reset EXTENDED_GLOB
    return 0
  fi
}
