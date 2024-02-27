// SPDX-License-Identifier: -- WISE --

pragma solidity =0.8.24;

error AmountTooSmall();
error SendValueFailed();

contract SendValueHelper {
    bool public sendingProgress;

    function _sendValue(address _recipient, uint256 _amount) internal {
        //@audit - how could address(this).balance be manipulated by a force send? other accounting issues?
        if (address(this).balance < _amount) {
            revert AmountTooSmall();
        }

        sendingProgress = true;

        //@audit - reentrancy / malicious callback possible? i don't see reentrancy protection implemented. need to look at how the function is implemented overall
        (bool success, ) = payable(_recipient).call{value: _amount}("");

        sendingProgress = false;

        if (success == false) {
            revert SendValueFailed();
        }
    }
}
