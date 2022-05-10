#!/bin/bash
if ! [ $(id -u) = 0 ]; then
   echo "I am not root!"
else
   echo "I am root!"
fi

