#!/bin/bash

qterminal_ini="$HOME/.config/qterminal.org/qterminal.ini"
sed -i 's/^ApplicationTransparency=.*/ApplicationTransparency=0/' "$qterminal_ini"
sed -i 's/^HistoryLimited=.*/HistoryLimited=false/' "$qterminal_ini"


