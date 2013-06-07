#!/usr/bin/env bash

echo -n "Wraps to correct column boundary: "

cat test1.input | emacs --script ../format.el c++-mode > tmp 2>/dev/null
if [ "$(diff tmp test1.output)" = "" ];
then
    echo -e "\033[0;32mpass\033[0m"
else
    echo -e "\033[0;31mfail\033[0m"
fi
rm tmp
