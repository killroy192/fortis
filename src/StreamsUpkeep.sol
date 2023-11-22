// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IStreamsLookupCompatible} from "./interfaces/IStreamsLookupCompatible.sol";
import {ILogAutomation} from "./interfaces/ILogAutomation.sol";
import {IVerifierProxy} from "./interfaces/IVerifierProxy.sol";

contract StreamsUpkeep is ILogAutomation, IStreamsLookupCompatible {
    IVerifierProxy public verifier;

    struct BasicReport {
        // The feed ID the report has data for
        bytes32 feedId;
        // Earliest timestamp for which price is applicable
        uint32 validFromTimestamp;
        // Latest timestamp for which price is applicable
        uint32 observationsTimestamp;
        // Base cost to validate a transaction using the report, denominated in the chain’s native token (WETH/ETH)
        uint192 nativeFee;
        // Base cost to validate a transaction using the report, denominated in LINK
        uint192 linkFee;
        // Latest timestamp where the report can be verified on-chain
        uint32 expiresAt;
        // DON consensus median price, carried to 8 decimal places
        int192 price;
    }

    struct PremiumReport {
        // The feed ID the report has data for
        bytes32 feedId;
        // Earliest timestamp for which price is applicable
        uint32 validFromTimestamp;
        // Latest timestamp for which price is applicable
        uint32 observationsTimestamp;
        // Base cost to validate a transaction using the report, denominated in the chain’s native token (WETH/ETH)
        uint192 nativeFee;
        // Base cost to validate a transaction using the report, denominated in LINK
        uint192 linkFee;
        // Latest timestamp where the report can be verified on-chain
        uint32 expiresAt;
        // DON consensus median price, carried to 8 decimal places
        int192 price;
        // Simulated price impact of a buy order up to the X% depth of liquidity utilisation
        int192 bid;
        // Simulated price impact of a sell order up to the X% depth of liquidity utilisation
        int192 ask;
    }

    struct Quote {
        address quoteAddress;
    }

    event ReportVerified(BasicReport indexed report);
    event PriceUpdate(int192 price);

    address public immutable FEE_ADDRESS;
    string public constant STRING_DATASTREAMS_FEEDLABEL = "feedIDs";
    string public constant STRING_DATASTREAMS_QUERYLABEL = "timestamp";
    string[] public feedsHex = [
        "0x00023496426b520583ae20a66d80484e0fc18544866a5b0bfee15ec771963274"
    ];

    constructor(address _feeAddress, address _verifier) {
        verifier = IVerifierProxy(_verifier); //0xea9B98Be000FBEA7f6e88D08ebe70EbaAD10224c
        FEE_ADDRESS = _feeAddress; // 0xe39Ab88f8A4777030A534146A9Ca3B52bd5D43A3 (WETH)
    }

    function checkLog(
        Log calldata log,
        bytes memory
    )
        external
        view
        returns (bool /* upkeepNeeded */, bytes memory /* performData */)
    {
        revert StreamsLookup(
            STRING_DATASTREAMS_FEEDLABEL,
            feedsHex,
            STRING_DATASTREAMS_QUERYLABEL,
            log.timestamp,
            ""
        );
    }

    function checkCallback(
        bytes[] calldata values,
        bytes calldata extraData
    ) external pure returns (bool, bytes memory) {
        return (true, abi.encode(values, extraData));
    }

    function performUpkeep(bytes calldata performData) external override {
        (bytes[] memory signedReports, bytes memory extraData) = abi.decode(
            performData,
            (bytes[], bytes)
        );

        bytes memory report = signedReports[0];

        bytes memory bundledReport = bundleReport(report);

        BasicReport memory unverifiedReport = _getReportData(report);

        bytes memory verifiedReportData = verifier.verify{
            value: unverifiedReport.nativeFee
        }(bundledReport);
        BasicReport memory verifiedReport = abi.decode(
            verifiedReportData,
            (BasicReport)
        );

        emit PriceUpdate(verifiedReport.price);
    }

    function bundleReport(
        bytes memory report
    ) internal view returns (bytes memory) {
        Quote memory quote;
        quote.quoteAddress = FEE_ADDRESS;
        (
            bytes32[3] memory reportContext,
            bytes memory reportData,
            bytes32[] memory rs,
            bytes32[] memory ss,
            bytes32 raw
        ) = abi.decode(
                report,
                (bytes32[3], bytes, bytes32[], bytes32[], bytes32)
            );
        bytes memory bundledReport = abi.encode(
            reportContext,
            reportData,
            rs,
            ss,
            raw,
            abi.encode(quote)
        );
        return bundledReport;
    }

    function _getReportData(
        bytes memory signedReport
    ) internal pure returns (BasicReport memory) {
        (, bytes memory reportData, , , ) = abi.decode(
            signedReport,
            (bytes32[3], bytes, bytes32[], bytes32[], bytes32)
        );

        BasicReport memory report = abi.decode(reportData, (BasicReport));
        return report;
    }

    fallback() external payable {}
}
