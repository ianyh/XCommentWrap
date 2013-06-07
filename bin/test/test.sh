#!/usr/bin/env bash

echo -n "Wraps to correct column boundary: "

if [ "$(cat test1.input | emacs --script ../format.el c++-mode 2>/dev/null)" = "$(cat test1.output)" ];
then
    echo -e "\033[0;32mpass\033[0m"
else
    echo -e "\033[0;31mfail\033[0m"
fi
