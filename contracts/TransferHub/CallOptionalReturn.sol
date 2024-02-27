// SPDX-License-Identifier: -- WISE --
//@audit WISE license identifier is not recognized by the SPDX license list?

pragma solidity =0.8.24;

import "../InterfaceHub/IERC20.sol";

contract CallOptionalReturn {
    /**
     * @dev Helper function to do low-level call
     */
    function _callOptionalReturn(
        address token,
        // notes - "bytes" indicates a dynamic byte array in memory
        bytes memory data
    ) internal returns (bool call) {
        // @audit what if the token is malicious?
        (bool success, bytes memory returndata) = token.call(data);

        bool results = returndata.length == 0 || abi.decode(returndata, (bool));

        if (success == false) {
            revert();
        }

        call = success && results && token.code.length > 0;
    }
}
