
pragma solidity ^0.4.25;

contract ParallelConfigPrecompiled
{
    function registerParallelFunctionInternal(address, string, uint256) public returns (int);
    function unregisterParallelFunctionInternal(address, string) public returns (int);    
}

contract ParallelContract
{
    ParallelConfigPrecompiled precompiled = ParallelConfigPrecompiled(0x1006);
    
    function registerParallelFunction(string functionName, uint256 criticalSize) public 
    {
        precompiled.registerParallelFunctionInternal(address(this), functionName, criticalSize);
    }
    
    function unregisterParallelFunction(string functionName) public
    {
        precompiled.unregisterParallelFunctionInternal(address(this), functionName);
    }
    
    function enableParallel() public;
    function disableParallel() public;
}

// A parallel contract example
contract Test2 is ParallelContract
{
    mapping (string => uint256) _balance;
    address Owner;
    uint256 flag;
    uint one = 2000;
    uint two = 2000;
    
     // Just an example, overflow is ok, use 'SafeMath' if needed
    function transfer(uint256 num, string from, string to) public
    {
        _balance[from] -= num;
        for(int i = 0; i < 1000; i++){}
        _balance[to] += num;
    }

    function test_3( uint256 num, string from, string to) public
    {
        _balance[from] -= num;
        for(int i = 0; i < 1000; i++){}
        _balance[to] += num;
    }


    function test_1(uint256 count) public
    {
        one = one - 1;
        for(int i = 0; i < 1000; i++){}
        two = two - 1;
        if (one != two)
{
flag = 233;
}
        
        
    }


    function test_2(uint256 num, string from, string to) public
    {
        address(0x1007).call.value(0)();
        _balance[from] -= num;
        for( int i = 0; i < 1000; i++){}
        _balance[to] += num;

        address(0x1008).call.value(0)();
    }

    // Just for testing whether the parallel revert function is working well, no practical use
    function transferWithRevert(string from, string to, uint256 num) public
    {
        _balance[from] -= num;
        _balance[to] += num;
        require(num <= 100);
    }

    function set(string name, uint256 num) public
    {
        _balance[name] = num;
    }

    function balanceOf(string name) public view returns (uint256)
    {
        return _balance[name];
    }
    
    // Register parallel function
    function enableParallel() public
    {
        // critical number is to define how many critical params from start
        registerParallelFunction("transfer(string,string,uint256)", 2); // critical: string string
        registerParallelFunction("test_1(uint256)",1); // critical: string
        registerParallelFunction("test_2(uint256,string,string)", 1);
        registerParallelFunction("test_3(uint256,string,string)", 1);
    } 

    // Disable register parallel function
    function disableParallel() public
    {
        unregisterParallelFunction("transfer(string,string,uint256)");
        unregisterParallelFunction("test_1()");
    } 
}
