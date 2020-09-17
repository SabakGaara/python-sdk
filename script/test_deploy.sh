#!/bin/bash

num=$1
zero=0

for((integer=1; integer<=10; integer++))
do
{
	condition=`expr $integer % 2`
	if [ "$condition" == 0 ]
	
	then
		./console.py deploy ExchangeV8
	else
		./console.py deploy ExchangeV8
	fi
}&
done
