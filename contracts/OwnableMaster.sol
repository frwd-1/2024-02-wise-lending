// SPDX-License-Identifier: -- WISE --

pragma solidity =0.8.24;

error NoValue();
error NotMaster();
error NotProposed();

// @audit add natspecc, follow conventions
// state variables
// master
// proposedMaster
// zero address

// promises / invariants
// contract OwnableMaster manages the master of the contract
// _onlyMaster --> if msg.sender == master, continue
// _onlyProposed --> if msg.sender == proposedMaster, continue
// constructor --> deployer of the contract sets the master, but the master cannot be the zero address
// proposeOwner --> the current master can propose a new master, ie the proposedOwner becomes proposed Master
// claimOwnership --> in order for the proposedMaster to become the master, the proposedMaster must call this function
// renounceOwnership --> the current master can renounce ownership, ie the master becomes the zero address

contract OwnableMaster {
    address public master;
    address public proposedMaster;

    address internal constant ZERO_ADDRESS = address(0x0);

    modifier onlyProposed() {
        _onlyProposed();
        _;
    }

    function _onlyMaster() private view {
        if (msg.sender == master) {
            return;
        }

        revert NotMaster();
    }

    modifier onlyMaster() {
        _onlyMaster();
        _;
    }

    function _onlyProposed() private view {
        if (msg.sender == proposedMaster) {
            return;
        }

        revert NotProposed();
    }

    event MasterProposed(
        address indexed proposer,
        address indexed proposedMaster
    );

    event RenouncedOwnership(address indexed previousMaster);

    constructor(address _master) {
        if (_master == ZERO_ADDRESS) {
            revert NoValue();
        }
        master = _master;
    }

    /**
     * @dev Allows to propose next master.
     * Must be claimed by proposer.
     * // @audit *correction - must be claimed by the proposee (proposedMaster)
     */
    function proposeOwner(address _proposedOwner) external onlyMaster {
        if (_proposedOwner == ZERO_ADDRESS) {
            revert NoValue();
        }

        proposedMaster = _proposedOwner;

        emit MasterProposed(msg.sender, _proposedOwner);
    }

    /**
     * @dev Allows to claim master role.
     * Must be called by proposer.
     * // @audit *correction - must be called by the proposedMaster
     */
    function claimOwnership() external onlyProposed {
        master = proposedMaster;
    }

    /**
     * @dev Removes master role.
     * No ability to be in control.
     */
    function renounceOwnership() external onlyMaster {
        master = ZERO_ADDRESS;
        proposedMaster = ZERO_ADDRESS;

        emit RenouncedOwnership(msg.sender);
    }
}
