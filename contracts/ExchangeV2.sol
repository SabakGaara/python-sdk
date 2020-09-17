

pragma solidity 0.4.25;


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


/// @title Exchange - Facilitates exchange of ERC20 tokens.
/// @author Amir Bandeali - <amir@0xProject.com>, Will Warren - <will@0xProject.com>
contract ExchangeV2 is ParallelContract {

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
        uint tokens// keccak256(makerToken, takerToken), allows subscribing to a token pair
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
    
    
    function fillOrder(uint256 fillTakerTokenAmount, address maker, address taker, address feeRecipient, bytes32 orderHash)
          public
    {
        Order memory order = Order({
            maker: maker,
            taker: msg.sender,
            feeRecipient: feeRecipient,
            makerTokenAmount: 10000,
            takerTokenAmount: 10000,
            makerFee: 1,
            takerFee: 1,
            expirationTimestampInSec: 1,
            orderHash: orderHash
        });

        require(order.taker == address(0) || order.taker == msg.sender);
        require(order.makerTokenAmount > 0 && order.takerTokenAmount > 0 && fillTakerTokenAmount > 0);


        if (block.timestamp >= order.expirationTimestampInSec) {
            //LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);
            //return 0;
        }
         address(0x1007).call.value(0)();
        uint remainingTakerTokenAmount = order.takerTokenAmount - getUnavailableTakerTokenAmount(order.orderHash);
        uint filledTakerTokenAmount = fillTakerTokenAmount < remainingTakerTokenAmount ? fillTakerTokenAmount:remainingTakerTokenAmount;
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
        filled[order.orderHash] = filled[order.orderHash] + filledTakerTokenAmount;
        // _xend()
        transferFrom(
            order.maker,
            msg.sender,
            filledMakerTokenAmount
        );
        transferFrom(
            msg.sender,
            order.maker,
            filledTakerTokenAmount
        );
        address(0x1008).call.value(0)();
        if (order.feeRecipient != address(0)) {
            if (order.makerFee > 0) {
                paidMakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerFee);
                transferFrom(
                    order.maker,
                    order.feeRecipient,
                    paidMakerFee
                );
            }
            if (order.takerFee > 0) {
                paidTakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.takerFee);
                transferFrom(
                    msg.sender,
                    order.feeRecipient,
                    paidTakerFee
                );
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
            1000
        );
    }
    
    
    function fillOrder_2(uint256 fillTakerTokenAmount, address maker, address taker, address feeRecipient, bytes32 orderHash)
          public
    {
        Order memory order = Order({
            maker: maker,
            taker: msg.sender,
            feeRecipient: feeRecipient,
            makerTokenAmount: 10000,
            takerTokenAmount: 10000,
            makerFee: 1,
            takerFee: 1,
            expirationTimestampInSec: 1,
            orderHash: orderHash
        });

        require(order.taker == address(0) || order.taker == msg.sender);
        require(order.makerTokenAmount > 0 && order.takerTokenAmount > 0 && fillTakerTokenAmount > 0);


        if (block.timestamp >= order.expirationTimestampInSec) {
            //LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);
            //return 0;
        }
        // _xbegin()
        uint remainingTakerTokenAmount = order.takerTokenAmount - getUnavailableTakerTokenAmount(order.orderHash);
        uint filledTakerTokenAmount = fillTakerTokenAmount < remainingTakerTokenAmount ? fillTakerTokenAmount:remainingTakerTokenAmount;
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
        filled[order.orderHash] = filled[order.orderHash] + filledTakerTokenAmount;
        // _xend()
        transferFrom(
            order.maker,
            msg.sender,
            filledMakerTokenAmount
        );
        transferFrom(
            msg.sender,
            order.maker,
            filledTakerTokenAmount
        );
        if (order.feeRecipient != address(0)) {
            if (order.makerFee > 0) {
                paidMakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerFee);
                transferFrom(
                    order.maker,
                    order.feeRecipient,
                    paidMakerFee
                );
            }
            if (order.takerFee > 0) {
                paidTakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.takerFee);
                transferFrom(
                    msg.sender,
                    order.feeRecipient,
                    paidTakerFee
                );
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
            1000
        );
    }
    
    
    function fillOrder_1(address maker, address taker, address feeRecipient, uint256 fillTakerTokenAmount, bytes32 orderHash)
    public
    {
       Order memory order = Order({
            maker: maker,
            taker: msg.sender,
            feeRecipient: feeRecipient,
            makerTokenAmount: 10000,
            takerTokenAmount: 10000,
            makerFee: 1,
            takerFee: 1,
            expirationTimestampInSec: 1,
            orderHash: orderHash
        });

        require(order.taker == address(0) || order.taker == msg.sender);
        require(order.makerTokenAmount > 0 && order.takerTokenAmount > 0 && fillTakerTokenAmount > 0);


        if (block.timestamp >= order.expirationTimestampInSec) {
            //LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);
            //return 0;
        }
        // _xbegin()
        uint remainingTakerTokenAmount = order.takerTokenAmount - getUnavailableTakerTokenAmount(order.orderHash);
        uint filledTakerTokenAmount = fillTakerTokenAmount < remainingTakerTokenAmount ? fillTakerTokenAmount:remainingTakerTokenAmount;
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
        filled[order.orderHash] = filled[order.orderHash] + filledTakerTokenAmount;
        // _xend()
        transferFrom(
            order.maker,
            msg.sender,
            filledMakerTokenAmount
        );
        transferFrom(
            msg.sender,
            order.maker,
            filledTakerTokenAmount
        );
        if (order.feeRecipient != address(0)) {
            if (order.makerFee > 0) {
                paidMakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerFee);
                transferFrom(
                    order.maker,
                    order.feeRecipient,
                    paidMakerFee
                );
            }
            if (order.takerFee > 0) {
                paidTakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.takerFee);
                transferFrom(
                    msg.sender,
                    order.feeRecipient,
                    paidTakerFee
                );
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
            1000
        );
    }

  

    function getPartialAmount(uint numerator, uint denominator, uint target)
        public
        constant
        returns (uint)
    {
        return (numerator*target)/denominator;
    }


    function getUnavailableTakerTokenAmount(bytes32 orderHash)
        public
        constant
        returns (uint)
    {
        return filled[orderHash] + cancelled[orderHash];
    }
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    
    function transferFrom(address from, address to, uint256 tokens) public {
        balances[from] = balances[from] - tokens;
        balances[to] = balances[to] + tokens;
    }
    
    function transfer(uint256 token, address to)
    {
        for (int i=0; i<100; i++) {}
        balances[to] = token;
    }
    
    function set(uint token)
    {
        balances[msg.sender] = token;
    }


    function enableParallel() public
    {
        // critical number is to define how many critical params from start
        registerParallelFunction("fillOrder(uint256,address,address,address,bytes32)", 1); // critical: string string
        registerParallelFunction("transfer(uint256,address)", 1); // critical: string
        registerParallelFunction("fillOrder_1(address,address,address,uint256,bytes32)", 2);
        registerParallelFunction("fillOrder_2(uint256,address,address,address,bytes32)", 1); 
        // critical: string string
    } 

    // Disable register parallel function
    function disableParallel() public
    {
        unregisterParallelFunction("fillOrder(address, address, address, address, address, uint, uint, uint, uint,uint,uint,bool, bytes32)"); 
    } 

}




