
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
contract Test_1 is ParallelContract
{
    mapping (string => uint256) _balance;
    address Owner;
    
     // Just an example, overflow is ok, use 'SafeMath' if needed
    function transfer(string from, string to, uint256 num) public
    {
        for(int i = 0; i < 1000; i++){}
        _balance[from] -= num;
        for(i = 0; i < 1000; i++){}
        _balance[to] += num;
        for(i = 0; i < 1000; i++){}
    }

    function test_3(string from, string to, uint256 num) public
    {
        for(int i = 0; i < 1000; i++){}
        _balance[from] -= num;
        for( i = 0; i < 1000; i++){}
        _balance[to] += num;
        for( i = 0; i < 1000; i++){}
    }


    function test_1() public
    {
        for(int i = 0; i < 1000; i++){}
        Owner = msg.sender;
        for( i = 0; i < 1000; i++){}
    }


    function test_2(string from, string to, uint256 num) public
    {
        for(int i = 0; i < 1000; i++){}
        address(0x1007).call.value(0)();
        _balance[from] -= num;
        for( i = 0; i < 1000; i++){}
        _balance[to] += num;
        address(0x1008).call.value(0)();
        for( i = 0; i < 1000; i++){}
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
        registerParallelFunction("test_1()", 0); // critical: string
        registerParallelFunction("test_2(string, string, uint256)", 0);
        registerParallelFunction("test_3(string, string, uint256)", 0);
    } 

    // Disable register parallel function
    function disableParallel() public
    {
        unregisterParallelFunction("transfer(string,string,uint256)");
        unregisterParallelFunction("test_1()");
    } 
}
