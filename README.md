# Rare Skills Week 1 Assignment

## Question 1: What problems do ERC777 and ERC 1363 solve?
There are three issues with the ERC 20 Token standard:
- Tokens can be sent to a contract address that can't use them, effectively taking the tokens out of circulation.
- A third party contract is not notified when a token has been added to it's balance. Two transactions need to be sent to enable paying a third party with ERC20 tokens.
- Unintuitive consequences of the 'approve' workflow such as:
    - contracts that request large approve values by default, or 
    - successive access to balances in excess of the approval amount, to due transaction ordering in the mempool.

ERC 777 and ERC 1363 solve these issues in different ways.

An ERC 777 Token checks if the receiving address has code before transferring. If it does, it must implement a receiver function. The receiver function can be implemented directly in the contract. Alternatively the receiver function can be implemented in another contract that is associated with the receiver address via an ERC 820 Registry.

ERC 777 also implements callback hooks which can trigger actions in third party contracts. This simplifies the UX for things like payment. After a token has been transferred, the third party contract is cancelled to act on the transfer.

ERC 777 also rethinks the 'approve', workflow by implementing operators who can act on behalf of the token owner. This simplifies the interaction and removes the unintuitive aspects of the ERC 20 approval process.

#### What issues are there with ERC777?
The registry design is overly complicated and the callback hooks make the token vulnerable to reentrancy attacks. There are common protections against this but they also add to gas costs.

#### Why was ERC 1363 introduced?
The ERC 1363 Token standard similarly allows you to call functions when transfers are received or when approval is received. Compared to ERC 777 it does not require the registry of interfaces and it does not fallback to a conventional transfer in the event the receiver functions are not present.


## Question 2: Why does the SafeERC20 program exist and when should it be used?



## Token with Sanctions

## Token with God mode

## Token sale and buyback with bonding curve

## Untrusted Escrow