#!/bin/bash

MODE=$1

python3 -m venv venv
source .profile
source venv/bin/activate
pip install prefect
tmux kill-session -t prefectserver
tmux kill-session -t flow
tmux new-session -d -s prefectserver "prefect server start"
sleep 5

if [ $MODE == "async" ]; then
    tmux new-session -d -s flow "python3 -m venv venv && source venv/bin/activate && source .profile && python3 flow.py"
else
    python3 flow.py
fi

