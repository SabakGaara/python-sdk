

pragma solidity 0.4.25;


contract ParallelConfigPrecompiled
{
    function registerParallelFunctionInternal(address, string, uint256) public returns (int);
    function unregisterParallelFunctionInternal(address, string) public returns (int);    
}



/// @title TokenTransferProxy - Transfers tokens on behalf of contracts that have been approved via decentralized governance.
/// @author Amir Bandeali - <amir@0xProject.com>, Will Warren - <will@0xProject.com>

contract SafeMath {
    function safeMul(uint a, uint b) internal constant returns (uint256) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal constant returns (uint256) {
        uint c = a / b;
        return c;
    }

    function safeSub(uint a, uint b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal constant returns (uint256) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }
}


contract ParallelContract is SafeMath
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

/// @title Exchange - Facilitates exchange of ERC20 tokens.
/// @author Amir Bandeali - <amir@0xProject.com>, Will Warren - <will@0xProject.com>
contract Exchange is ParallelContract {

    // Error Codes
    enum Errors {
        ORDER_EXPIRED,                    // Order has already expired
        ORDER_FULLY_FILLED_OR_CANCELLED,  // Order has already been fully filled or cancelled
        ROUNDING_ERROR_TOO_LARGE,         // Rounding error too large
        INSUFFICIENT_BALANCE_OR_ALLOWANCE // Insufficient balance or allowance for token transfer
    }

    string constant public VERSION = "1.0.0";
    uint16 constant public EXTERNAL_QUERY_GAS_LIMIT = 4999;    // Changes to state require at least 5000 gas

    address public ZRX_TOKEN_CONTRACT;
    address public TOKEN_TRANSFER_PROXY_CONTRACT;

    // Mappings of orderHash => amounts of takerTokenAmount filled or cancelled.
    mapping (bytes32 => uint) public filled;
    mapping (bytes32 => uint) public cancelled;
    mapping(address => uint256) balances;

    event LogFill(
        address indexed maker,
        address taker,
        address indexed feeRecipient,
        address makerToken,
        address takerToken,
        uint filledMakerTokenAmount,
        uint filledTakerTokenAmount,
        uint paidMakerFee,
        uint paidTakerFee,
        uint tokens, // keccak256(makerToken, takerToken), allows subscribing to a token pair
        bytes32 orderHash
    );

    event LogCancel(
        address indexed maker,
        address indexed feeRecipient,
        address makerToken,
        address takerToken,
        uint cancelledMakerTokenAmount,
        uint cancelledTakerTokenAmount,
        bytes32 indexed tokens,
        bytes32 orderHash
    );

    event LogError(uint8 indexed errorId, bytes32 indexed orderHash);

    struct Order {
        address maker;
        address taker;
        address feeRecipient;
        uint makerTokenAmount;
        uint takerTokenAmount;
        uint makerFee;
        uint takerFee;
        uint expirationTimestampInSec;
        bytes32 orderHash;
    }

function fillOrder(uint fillTakerTokenAmount,
          address maker, address taker, address feeRecipient, uint[5] orderValues , bytes32 orderHash)
          public
          returns (uint filledTakerTokenAmount)
    {
        Order memory order = Order({
            maker: maker,
            taker: msg.sender,
            feeRecipient: feeRecipient,
            makerTokenAmount: orderValues[0],
            takerTokenAmount: orderValues[1],
            makerFee: orderValues[2],
            takerFee: orderValues[3],
            expirationTimestampInSec: orderValues[4],
            orderHash: orderHash
        });

        require(order.taker == address(0) || order.taker == msg.sender);
        require(order.makerTokenAmount > 0 && order.takerTokenAmount > 0 && fillTakerTokenAmount > 0);


        if (block.timestamp >= order.expirationTimestampInSec) {
            LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);
            return 0;
        }
         address(0x1007).call.value(0)();
        uint remainingTakerTokenAmount = safeSub(order.takerTokenAmount, getUnavailableTakerTokenAmount(order.orderHash));
        filledTakerTokenAmount = min256(fillTakerTokenAmount, remainingTakerTokenAmount);
        //if (filledTakerTokenAmount == 0) {
        //     LogError(uint8(Errors.ORDER_FULLY_FILLED_OR_CANCELLED), order.orderHash);
        //     return 0;
        // }

        // if (isRoundingError(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount)) {
        //     LogError(uint8(Errors.ROUNDING_ERROR_TOO_LARGE), order.orderHash);
        //     return 0;
        // }

        // if (!shouldThrowOnInsufficientBalanceOrAllowance && !isTransferable(order, filledTakerTokenAmount)) {
        //     LogError(uint8(Errors.INSUFFICIENT_BALANCE_OR_ALLOWANCE), order.orderHash);
        //     return 0;
        // }

        uint filledMakerTokenAmount = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount);
        uint paidMakerFee;
        uint paidTakerFee;
        filled[order.orderHash] = safeAdd(filled[order.orderHash], filledTakerTokenAmount);
        // _xend()
        require(transferFrom(
            order.maker,
            msg.sender,
            filledMakerTokenAmount
        ));
        require(transferFrom(
            msg.sender,
            order.maker,
            filledTakerTokenAmount
        ));
        
        address(0x1008).call.value(0)();
        if (order.feeRecipient != address(0)) {
            if (order.makerFee > 0) {
                paidMakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerFee);
                require(transferFrom(
                    order.maker,
                    order.feeRecipient,
                    paidMakerFee
                ));
            }
            if (order.takerFee > 0) {
                paidTakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.takerFee);
                require(transferFrom(
                    msg.sender,
                    order.feeRecipient,
                    paidTakerFee
                ));
            }
        }
        

        LogFill(
            order.maker,
            msg.sender,
            order.feeRecipient,
            0x01,
            0x02,
            filledMakerTokenAmount,
            filledTakerTokenAmount,
            paidMakerFee,
            paidTakerFee,
            1000,
            order.orderHash
        );
        return filledTakerTokenAmount;
    }
    
    
    function fillOrder_2(uint fillTakerTokenAmount, address maker, address taker, address feeRecipient, uint[5] orderValues, bytes32 orderHash)
          public
          returns (uint filledTakerTokenAmount)
    {
        Order memory order = Order({
            maker: maker,
            taker: msg.sender,
            feeRecipient: feeRecipient,
            makerTokenAmount: orderValues[0],
            takerTokenAmount: orderValues[1],
            makerFee: orderValues[2],
            takerFee: orderValues[3],
            expirationTimestampInSec: orderValues[4],
            orderHash: orderHash
        });

        require(order.taker == address(0) || order.taker == msg.sender);
        require(order.makerTokenAmount > 0 && order.takerTokenAmount > 0 && fillTakerTokenAmount > 0);


        if (block.timestamp >= order.expirationTimestampInSec) {
            LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);
            return 0;
        }
        // _xbegin()
        uint remainingTakerTokenAmount = safeSub(order.takerTokenAmount, getUnavailableTakerTokenAmount(order.orderHash));
        filledTakerTokenAmount = min256(fillTakerTokenAmount, remainingTakerTokenAmount);
        //if (filledTakerTokenAmount == 0) {
        //     LogError(uint8(Errors.ORDER_FULLY_FILLED_OR_CANCELLED), order.orderHash);
        //     return 0;
        // }

        // if (isRoundingError(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount)) {
        //     LogError(uint8(Errors.ROUNDING_ERROR_TOO_LARGE), order.orderHash);
        //     return 0;
        // }

        // if (!shouldThrowOnInsufficientBalanceOrAllowance && !isTransferable(order, filledTakerTokenAmount)) {
        //     LogError(uint8(Errors.INSUFFICIENT_BALANCE_OR_ALLOWANCE), order.orderHash);
        //     return 0;
        // }

        uint filledMakerTokenAmount = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount);
        uint paidMakerFee;
        uint paidTakerFee;
        filled[order.orderHash] = safeAdd(filled[order.orderHash], filledTakerTokenAmount);
        // _xend()
        require(transferFrom(
            order.maker,
            msg.sender,
            filledMakerTokenAmount
        ));
        require(transferFrom(
            msg.sender,
            order.maker,
            filledTakerTokenAmount
        ));
        if (order.feeRecipient != address(0)) {
            if (order.makerFee > 0) {
                paidMakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerFee);
                require(transferFrom(
                    order.maker,
                    order.feeRecipient,
                    paidMakerFee
                ));
            }
            if (order.takerFee > 0) {
                paidTakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.takerFee);
                require(transferFrom(
                    msg.sender,
                    order.feeRecipient,
                    paidTakerFee
                ));
            }
        }

        LogFill(
            order.maker,
            msg.sender,
            order.feeRecipient,
            0x01,
            0x02,
            filledMakerTokenAmount,
            filledTakerTokenAmount,
            paidMakerFee,
            paidTakerFee,
            1000,
            order.orderHash
        );
        return filledTakerTokenAmount;
    }
    
    
    function fillOrder_1(
          address maker, address taker, address feeRecipient, uint[5] orderValues, uint fillTakerTokenAmount, bytes32 orderHash)
          public
          returns (uint filledTakerTokenAmount)
    {
        Order memory order = Order({
            maker: maker,
            taker: msg.sender,
            feeRecipient: feeRecipient,
            makerTokenAmount: orderValues[0],
            takerTokenAmount: orderValues[1],
            makerFee: orderValues[2],
            takerFee: orderValues[3],
            expirationTimestampInSec: orderValues[4],
            orderHash: orderHash
        });

        require(order.taker == address(0) || order.taker == msg.sender);
        require(order.makerTokenAmount > 0 && order.takerTokenAmount > 0 && fillTakerTokenAmount > 0);


        if (block.timestamp >= order.expirationTimestampInSec) {
            LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);
            return 0;
        }
        // _xbegin()
        uint remainingTakerTokenAmount = safeSub(order.takerTokenAmount, getUnavailableTakerTokenAmount(order.orderHash));
        filledTakerTokenAmount = min256(fillTakerTokenAmount, remainingTakerTokenAmount);
        //if (filledTakerTokenAmount == 0) {
        //     LogError(uint8(Errors.ORDER_FULLY_FILLED_OR_CANCELLED), order.orderHash);
        //     return 0;
        // }

        // if (isRoundingError(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount)) {
        //     LogError(uint8(Errors.ROUNDING_ERROR_TOO_LARGE), order.orderHash);
        //     return 0;
        // }

        // if (!shouldThrowOnInsufficientBalanceOrAllowance && !isTransferable(order, filledTakerTokenAmount)) {
        //     LogError(uint8(Errors.INSUFFICIENT_BALANCE_OR_ALLOWANCE), order.orderHash);
        //     return 0;
        // }

        uint filledMakerTokenAmount = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount);
        uint paidMakerFee;
        uint paidTakerFee;
        filled[order.orderHash] = safeAdd(filled[order.orderHash], filledTakerTokenAmount);
        // _xend()
        require(transferFrom(
            order.maker,
            msg.sender,
            filledMakerTokenAmount
        ));
        require(transferFrom(
            msg.sender,
            order.maker,
            filledTakerTokenAmount
        ));
        if (order.feeRecipient != address(0)) {
            if (order.makerFee > 0) {
                paidMakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerFee);
                require(transferFrom(
                    order.maker,
                    order.feeRecipient,
                    paidMakerFee
                ));
            }
            if (order.takerFee > 0) {
                paidTakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.takerFee);
                require(transferFrom(
                    msg.sender,
                    order.feeRecipient,
                    paidTakerFee
                ));
            }
        }

        LogFill(
            order.maker,
            msg.sender,
            order.feeRecipient,
            0x01,
            0x02,
            filledMakerTokenAmount,
            filledTakerTokenAmount,
            paidMakerFee,
            paidTakerFee,
            1000,
            order.orderHash
        );
        return filledTakerTokenAmount;
    }

  
    function isRoundingError(uint numerator, uint denominator, uint target)
        public
        constant
        returns (bool)
    {
        
        for(int i = 0; i <1000 ; i++)
        uint remainder = mulmod(target, numerator, denominator);
        if (remainder == 0) return false; // No rounding error.

        uint errPercentageTimes1000000 = safeDiv(
            safeMul(remainder, 1000000),
            safeMul(numerator, target)
        );
        return errPercentageTimes1000000 > 1000;
    }

    function getPartialAmount(uint numerator, uint denominator, uint target)
        public
        constant
        returns (uint)
    {
        return safeDiv(safeMul(numerator, target), denominator);
    }


    function getUnavailableTakerTokenAmount(bytes32 orderHash)
        public
        constant
        returns (uint)
    {
        return safeAdd(filled[orderHash], cancelled[orderHash]);
    }
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from],tokens);
        balances[to] = safeAdd(balances[to],tokens);
        return true;
    }
    
    function transfer(address to, uint token)
    {
        balances[to] = token;
    }
    
    function set(uint token)
    {
        balances[msg.sender] = 10000;
    }


    function enableParallel() public
    {
        // critical number is to define how many critical params from start
        registerParallelFunction("function fillOrder(uint,address,address,address,uint[5],bytes32)", 1); // critical: string string
        registerParallelFunction("isRoundingError(uint,uint,uint)", 0); // critical: string
        registerParallelFunction("function fillOrder_1(address,address,address,uint[5],uint,bytes32)", 2);
        registerParallelFunction("function fillOrder_2(uint,address,address,address,uint[5],bytes32)", 1); // critical: string string
    } 

    // Disable register parallel function
    function disableParallel() public
    {
        unregisterParallelFunction("function fillOrder(address, address, address, address, address, uint, uint, uint, uint,uint,uint,bool, bytes32)"); 
    } 

}



