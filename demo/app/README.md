# Fortis Oracle | Demo dApp

> **Note**
>
> The project is implemented based on code from https://github.com/smartcontractkit/datastreams-demo/tree/main

> **Note**
>
> _This demo represents an non-production example to demonstrate how to use with Fortis Oracle. This template is provided “AS IS” and “AS AVAILABLE” without warranties of any kind. Do not use the code in this example in a production environment without completing your own adults and application of best practices. Neither Fortis Oracle developers, the Chainlink Foundation, nor Chainlink node operators are responsible for unintended outputs that are generated due to errors in the code._

This project demonstrates how to use Fortis ETH\USD Oracle - simple and powerful oracle on top of Chainlink Data Streams and Chainlink Data Feeds.

## Quick Start

Install all dependencies:

```bash
npm install
```

Set environment variables by copying `.env.example` to `.env` and filling in the values:

-   _NEXT_PUBLIC_ALCHEMY_API_KEY_ for the network you want to use. You can get one from [Alchemy](https://www.alchemy.com/).
-   _NEXT_PUBLIC_WALLET_CONNECT_ID_ for the wallet connector. You can get one from [WalletConnect](https://walletconnect.org/).

Run `npm run dev` in your terminal, and then open [localhost:3000](http://localhost:3000) in your browser.

## Tech Stack

-   [Next.js](https://nextjs.org/)
-   [TypeScript](https://www.typescriptlang.org/)
-   [Tailwind CSS](https://tailwindcss.com/)
-   [RainbowKit](https://www.rainbowkit.com/)
-   [wagmi](https://wagmi.sh/) & [viem](https://viem.sh/)
-   [shadcn/ui](https://ui.shadcn.com/)

## Questions?

You can [open an issue](https://github.com/killroy192/fortis-sdk/issues)
