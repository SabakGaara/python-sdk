    pragma solidity ^0.4.2;
    contract Test3{
        uint256 x;
        uint256 y;
        function HelloWorld(){
           x = 0;
           y = 0;
        }
        function get()constant returns(address){
            return msg.sender;
        }
        function set(uint[2] a){
            x = x + a[0] + a[1];
            y = y + 2;
        }
    }
    
