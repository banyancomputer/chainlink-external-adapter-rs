// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract BlockRate is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;
    uint256 private ;

    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0xF1a252307Ff9F3fbB9598c9a181385122948b8Ae);
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    function requestVerification(string memory _jobId, string memory _blocknum, string memory _offerid) public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfill.selector);
        req.add("block_num", _blocknum); // proof blocknum
        req.add("offer_id", _offerid);
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 requestId, uint256 _offer_id, uint256 _success_count, uint256 _num_windows, uint16 _status, string calldata _result) public recordChainlinkFulfillment(requestId) {
        emit RequestVerification(requestId, _offer_id);
        responses[_offer_id] = ResponseData(_offer_id, _success_count, _num_windows, _status, _result);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }

}
