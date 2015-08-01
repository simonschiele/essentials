#!/bin/bash

# test if ssh agent is running, if not start + export one
if [ -z "${SSH_AGENT_PID}" ] || ! ( ps ${SSH_AGENT_PID} >/dev/null ) ; then
    es_msg "no ssh-agent detected - starting one"
    export SSH_AGENT_PID=$( eval `ssh-agent` | grep -o "[0-9]*" )
fi
