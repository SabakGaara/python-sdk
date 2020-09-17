

contract ParallelConfigPrecompiled
{
    function registerParallelFunctionInternal(address, string, uint256) public returns (int);
     function registerParallelFunctionsInternal(address, string, uint256, string, uint256) public returns (int);
    function unregisterParallelFunctionInternal(address, string) public returns (int);    
}



contract ParallelContract
{
    ParallelConfigPrecompiled precompiled = ParallelConfigPrecompiled(0x1006);
    
    function registerParallelFunction(string functionName, uint256 criticalSize) public 
    {
        precompiled.registerParallelFunctionInternal(address(this), functionName, criticalSize);
    }
    
    function registerParallelFunctions(string firstFunctionName, uint256 firstCriticalSize, string secondFunctionName, uint256 secondCriticalSize) public 
    {
        precompiled.registerParallelFunctionsInternal(address(this), firstFunctionName, firstCriticalSize, secondFunctionName, secondCriticalSize);
    }
    
    function unregisterParallelFunction(string functionName) public
    {
        precompiled.unregisterParallelFunctionInternal(address(this), functionName);
    }
    
    function enableParallel() public;
}

// A parallel contract example
contract ParasV2 is ParallelContract
{
    mapping (string => uint256) _balance;
    address Owner;
    uint256 flag;
    uint one = 2000;
    uint two = 2000;
    
     // Just an example, overflow is ok, use 'SafeMath' if needed
    function transfer(string from, string to, uint256 num) public payable
    {
        msg.sender.transfer(1);
        _balance[from] -= num;
        _balance[to] += num;
        msg.sender.transfer(1);
    }


    function transfer_2(string from, string to, uint256 num) public payable
    {
        msg.sender.call.value(1)();
        _balance[from] -= num;
        _balance[to] += num;
        msg.sender.call.value(1)();
    }


    function test_3( uint256 num, string from, string to) public payable
    {
        for(int i = 0; i < 1000; i++){}
        _balance[from] -= num;
        for( i = 0; i < 1000; i++){}
        _balance[to] += num;
        for( i = 0; i < 1000; i++){}
        if ((_balance[from] + _balance[to]) != 4000)
        {
            flag = 23333;
        }
    }


    function test_2(uint256 num, string from, string to) public payable
    {
        for(int i = 0; i < 1000; i++){}
        address(0x1007).call.value(0)();
        _balance[from] -= num;
        for( i = 0; i < 1000; i++){}
        _balance[to] += num;

        for( i = 0; i < 1000; i++){}
        if ((_balance[from] + _balance[to]) != 4000)
        {
            flag = 23333;
        }
        address(0x1008).call.value(0)();
    }

    // Just for testing whether the parallel revert function is working well, no practical use
    function transferWithRevert(string from, string to, uint256 num) public
    {
	address(0x1007).call.value(0)();
        _balance[from] -= num;
        _balance[to] += num;
	address(0x1008).call.value(0)();
    }

    function set(string name) public payable
    {
        _balance[name] = msg.value;
    }

    function balanceOf(string name) public view returns (uint256)
    {
        return _balance[name];
    }
    
    // Register parallel function
    function enableParallel() public
    {
        // critical number is to define how many critical params from start
        registerParallelFunctions("transfer(string,string,uint256)",2,"set(string,uint256)",1); // critical: string string
   } 

}
