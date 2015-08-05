#!/bin/bash

# test if ssh agent is running, if not start + export one
if [[ -n "${SSH_AGENT_PID}" ]] && ( ps "${SSH_AGENT_PID}" >/dev/null ) ; then
    echo -n

# reuse already running agent for active user
elif ( ps -U "${ESSENTIALS_USER}" | grep -v grep | grep -q ssh-agent ) ; then
    export SSH_AGENT_PID=$( ps -U "${ESSENTIALS_USER}" | awk {'print $1'} | tail -n1 )

# start new agent
elif [ -z "${SSH_AGENT_PID}" ] || ! ( ps ${SSH_AGENT_PID} >/dev/null ) ; then
    es_msg "no ssh-agent detected - starting new one"
    export SSH_AGENT_PID=$( eval `ssh-agent` | grep -o "[0-9]*" )
fi
