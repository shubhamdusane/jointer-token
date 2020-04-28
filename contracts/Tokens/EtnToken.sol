pragma solidity ^0.5.9;

import "./Exchangeable.sol";
import "../InterFaces/IWhiteList.sol";


contract EtnToken is Exchangeable {
    constructor(
        string memory _name,
        string memory _symbol,
        address _systemAddress,
        address _authorityAddress,
        address _registeryAddress,
        uint256 _tokenPrice,
        uint256 _tokenMaturityDays,
        uint256 _tokenHoldBackDays,
        address _returnToken
    )
        public
        TokenUtils(
            _name,
            _symbol,
            _systemAddress,
            _authorityAddress,
            _tokenPrice,
            _tokenMaturityDays,
            _tokenHoldBackDays,
            _registeryAddress
        )
        Exchangeable(_returnToken)
    {}

    function checkBeforeTransfer(address _from, address _to)
        internal
        view
        returns (bool)
    {
        address whiteListAddress = getAddressOf(WHITE_LIST);
        if (
            IWhiteList(whiteListAddress).isAddressByPassed(msg.sender) == false
        ) {
            require(
                IWhiteList(whiteListAddress).checkBeforeTransfer(_from, _to),
                "ERR_TRANSFER_CHECK_WHITELIST"
            );
            require(
                !isTokenMature() && isHoldbackDaysOver(),
                "ERR_ACTION_NOT_ALLOWED"
            );
        }
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool ok) {
        require(checkBeforeTransfer(msg.sender, _to));
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool)
    {
        require(checkBeforeTransfer(_from, _to));
        return super.transferFrom(_from, _to, _value);
    }

    function() external payable {
        revert();
    }
}