#!/usr/bin/env sh
### Use: apljck file
### Defaults
T=1           # IMPORTANT: This is the timeout in seconds after every call
              # before disconnecting from the apl session. If you make this too
              # short, you will disconnect before you've gotten your results
              # back from apl.
P=1337        # TCP port
A=apl         # APL executable (path/)name. We assume it's on the exec path
F=$1          # File name
### Sanity checks, setup, and convenience things
H=$(hostname)
command -v ${A}>/dev/null||(echo GNU APL not found; check '$A' variable;exit 1)
[ ! -f ${F} ]&&echo 'File not found'&&exit 1
### Main program
## Start GNU APL as a TCP server. This will persist until the program is done.
${A} --tcp_port ${P}&
## Process lines (this is the main bit)
export codeflag=0
while read -r l;do
  if [ '$l' = '{{{' ];then 
    codeflag=1
    echo '.---Code cell start---.'
  elif [ '$l' = '}}}' ];then
    codeflag=0
    echo "'--- Code cell end ---'"
  else echo ${l}
  fi
  if [ $codeflag -eq 1 ];then echo '$l'|nc ${H} ${P};fi
done<${F}
## Disconnect
echo ')off'|nc ${H} ${P}

