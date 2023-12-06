// TODO: find more suitable wording for this enum
export enum ExchangePlatform {
  BINANCE = "BINANCE",
  COINBASE = "COINBASE",
}

export enum Pair {
  ETH_USD = "ETH-USD",
}

export const binancePairs = {
  [Pair.ETH_USD]: "ETHUSDT",
};

export const chainlinkPairToFeedId = {
  [Pair.ETH_USD]:
    "0x00029584363bcf642315133c335b3646513c20f049602fc7d933be0d3f6360d3",
};

export type PriceResponse = {
  feedId: string;
  observationTimestamp: number;
  benchmarkPrice: string;
};
