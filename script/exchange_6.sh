#!/bin/bash

num=$1


maker=0xa8a5eb0b08a0e30d90532fc4b69f68660d6e3348
taker=0xbBF289D846208c16EDc8474705C748aff07732dB
fee=0xbBF289D846208c16EDc8474705C748aff07732dB
num_1=0
num_2=0
for((integer=0; integer<=num; integer++))
do
{
        if [ $integer -lt $2 ];then
          {
		        condition_2=`expr $integer % 3`
		        if [ "$condition_2" == 0 ];then
./console.py sendtx ExchangeV4 0x216396e5c0758bbdb38e45ed8ca331b6b79e92aa cancelOrder [0x95198b93705e394a916579e048c8a32ddfb900f7,0x0000000000000000000000000000000000000000,0x8216f2e15828a87dcd5ca98768f3b384caa60ca1,0x9d0c9447d60d3d036ee2a705117fcf98cf875ae0,0xc192453777f1209312eb550ac53c0e7ab4cb43a9] [100,100,0,0,17528848429058,0] 1
	          elif [ "$condition_2" == 1 ];then
./console.py sendtx ExchangeV4 0x216396e5c0758bbdb38e45ed8ca331b6b79e92aa fillOrder [0x95198b93705e394a916579e048c8a32ddfb900f7,0x0000000000000000000000000000000000000000,0x8216f2e15828a87dcd5ca98768f3b384caa60ca1,0x9d0c9447d60d3d036ee2a705117fcf98cf875ae0,0xc192453777f1209312eb550ac53c0e7ab4cb43a9] [100,100,0,0,17528848429058,0] 1 true 1 0x7465737400000000000000000000000000000000000000000000000000000000 0x7465737400000000000000000000000000000000000000000000000000000000
	          else
./console.py sendtx ExchangeV4 0x216396e5c0758bbdb38e45ed8ca331b6b79e92aa fillOrKillOrder [0x95198b93705e394a916579e048c8a32ddfb900f7,0x0000000000000000000000000000000000000000,0x8216f2e15828a87dcd5ca98768f3b384caa60ca1,0x9d0c9447d60d3d036ee2a705117fcf98cf875ae0,0xc192453777f1209312eb550ac53c0e7ab4cb43a9] [100,100,0,0,17528848429058,0] 1 1 0x7465737400000000000000000000000000000000000000000000000000000000 0x7465737400000000000000000000000000000000000000000000000000000000
		        fi
		        }

 	      else
 	        {
		        num_2=$[num_2+1]
            condition_3=`expr $integer % 3`
            if [ "$condition_3" == 1 ];then
./console.py sendtx ExchangeV7 0x54d2cda54b28f524d6b1e4f8037801c964b29b8e fillOrder 0x7465737400000000000000000000000000000000000000000000000000000000 0x692a70D2e424a56D2C6C27aA97D1a86395877b3A 0x95198b93705e394a916579e048c8a32ddfb900f7 [0x95198b93705e394a916579e048c8a32ddfb900f7,0x0000000000000000000000000000000000000000,0xb7e9e6b5a8e704123bbbe6dc5dcbcd4aef00440b,0xf888f6f48df91c8a1f9f0cc85bf5c0c4e111c5b4,0xc192453777f1209312eb550ac53c0e7ab4cb43a9] [100,100,0,0,17528848429058,0] 1 true 1 0x7465737400000000000000000000000000000000000000000000000000000000 0x7465737400000000000000000000000000000000000000000000000000000000
		        elif [ "$condition_3" == 2 ];then
./console.py sendtx ExchangeV7 0x54d2cda54b28f524d6b1e4f8037801c964b29b8e fillOrKillOrder 0x7465737400000000000000000000000000000000000000000000000000000000 0x692a70D2e424a56D2C6C27aA97D1a86395877b3A 0x95198b93705e394a916579e048c8a32ddfb900f7 [0x95198b93705e394a916579e048c8a32ddfb900f7,0x0000000000000000000000000000000000000000,0xb7e9e6b5a8e704123bbbe6dc5dcbcd4aef00440b,0xf888f6f48df91c8a1f9f0cc85bf5c0c4e111c5b4,0xc192453777f1209312eb550ac53c0e7ab4cb43a9] [100,100,0,0,17528848429058,0] 1 1 0x7465737400000000000000000000000000000000000000000000000000000000 0x7465737400000000000000000000000000000000000000000000000000000000
		        elif [ "$condition_3" == 0 ];then
./console.py sendtx ExchangeV7 0x54d2cda54b28f524d6b1e4f8037801c964b29b8e cancelOrder  0x7465737400000000000000000000000000000000000000000000000000000000 0x692a70D2e424a56D2C6C27aA97D1a86395877b3A 0x95198b93705e394a916579e048c8a32ddfb900f7 [0x95198b93705e394a916579e048c8a32ddfb900f7,0x0000000000000000000000000000000000000000,0xb7e9e6b5a8e704123bbbe6dc5dcbcd4aef00440b,0xf888f6f48df91c8a1f9f0cc85bf5c0c4e111c5b4,0xc192453777f1209312eb550ac53c0e7ab4cb43a9] [100,100,0,0,17528848429058,0] 1
		        fi
		        }
        fi
}&
done


