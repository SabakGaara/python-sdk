#!/bin/bash

num=$1
zero=0

for((integer=1; integer<=12; integer++))
do
{
	condition=`expr $integer % 1`
	if [ "$condition" == 0 ]
	
	then
		./console.py sendtx ExchangeV2 0xa72db07ffb5befe9c9e8264c2224a8b3b7d4e8f4 transfer ${integer} 0x692a70D2e424a56D2C6C27aA97D1a86395877b3A
	
	fi
}&
done
