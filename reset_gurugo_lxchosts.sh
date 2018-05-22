#####
#
# Data: 20180517
# Author: Daniel Roijals
# E-mail: daniel.roijals@atrapalo.com
#
# Aquest script es troba a jenkins-sys (/opt/local/sistemas) i el que fa és
# estalviar feina, des d'allà fa un ssh a cada lxc-host definit a la variable
# farm_hosts, i des de dins de cada lxc-host fa un ssh a cadascun dels diferents
# gurugo que tingui associat i restarteja el supervisor.
#
#####


#!/bin/bash

farm_hosts=(lxc-host07 lxc-host08 lxc-host09 lxc-host10 lxc-host11 lxc-host14 lxc-host15 lxc-host16 lxc-host17 lxc-host18)

for server in ${farm_hosts[@]}; do

  for container in `ssh root@$server.atr.bcn "lxc-ls --fancy" | grep gurugo | egrep -v template | awk '{print $1}'`; do
    ssh root@$server.atr.bcn "lxc-attach -n $container -- service supervisor restart"
    echo $server ":" $container
  done

done
