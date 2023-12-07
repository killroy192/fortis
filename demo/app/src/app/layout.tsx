import "@/styles/globals.css";
import "@rainbow-me/rainbowkit/styles.css";

import Image from "next/image";
import { Figtree } from "next/font/google";
import { siteConfig } from "@/config/site";
import { Metadata } from "next";
import { Providers } from "./providers";
import { cn } from "@/lib/utils";
import { ConnectWallet } from "@/components/connect-wallet";
import Link from "next/link";
import { SocketProvider } from "./socket-provider";
import { Toaster } from "@/components/ui/toaster";
import MobileConnectWallet from "@/components/mobile-connect-wallet";
import { isTradeEnabled } from "@/config/trade";

const figtree = Figtree({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: siteConfig.name,
  description: siteConfig.description,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body
        className={cn(
          "min-h-screen bg-background bg-[url('/honeycomb.svg')] bg-left-bottom bg-no-repeat",
          figtree.className,
        )}
      >
        <SocketProvider>
          <Providers>
            <div className="flex flex-col items-center justify-center border-b bg-accent">
              <header className="container flex max-w-[1440px] flex-row items-center justify-between px-6 py-5 md:px-16">
                <div className="flex flex-row items-center space-x-4">
                  <Image src="/logo.svg" height={32} width={32} alt="logo" />
                  <h1 className="hidden font-medium leading-7 md:inline-block">
                    Fortis Oracle | Demo
                  </h1>
                  <h1 className="font-medium leading-7 md:hidden">
                    Fortis Oracle | Demo
                  </h1>
                </div>
                {isTradeEnabled && (
                  <>
                    <div className="hidden md:inline-block">
                      <ConnectWallet />
                    </div>
                    <div className="md:hidden">
                      <MobileConnectWallet />
                    </div>
                  </>
                )}
              </header>
            </div>
            <div className="container max-w-[1440px] bg-[url('/honeycomb.svg')] bg-right-top bg-no-repeat px-6 md:px-16">
              <Toaster />
              <main>{children}</main>
              <footer>
                <div className="mb-4 mt-6 rounded-md border bg-[rgb(24,29,41)]/60 p-10 md:mb-4">
                  <div
                    className={cn(
                      "space-y-6 md:grid md:space-y-0",
                      isTradeEnabled ? "md:grid-cols-3" : "md:grid-cols-2",
                    )}
                  >
                    <div
                      className={cn(
                        "pb-10 md:pb-0 md:pr-10",
                        isTradeEnabled
                          ? ""
                          : "border-b md:border-b-0 md:border-r",
                      )}
                    >
                      <h3 className="mb-6 text-xl font-medium">Purpose</h3>
                      <p className="text-base font-[450] text-muted-foreground">
                        This dApp will show you how to use Fortis Oracle. Fortis
                        Oracle uses Chainlink Data Streams as a main data source
                        with Data Fees as a fallback logic.
                      </p>
                    </div>
                    {isTradeEnabled && (
                      <div className="border-y py-10 md:border-x md:border-y-0 md:px-10 md:py-0">
                        <h3 className="mb-6 text-xl font-medium">
                          Getting started
                        </h3>
                        <div className="space-y-4 text-base font-[450] text-muted-foreground">
                          <p className="flex space-x-2">
                            <span>1. Connect your wallet</span>
                            <span className="flex space-x-2 rounded bg-muted px-2 py-1">
                              <Image
                                src="/metamask.svg"
                                width={16}
                                height={16}
                                alt="metamask"
                              />
                              <Image
                                src="/walletconnect.svg"
                                width={16}
                                height={16}
                                alt="walletconnect"
                              />
                            </span>
                          </p>
                          <p>2. Select a token pair to trade</p>
                          <p>3. Swap the amount of tokens desired</p>
                        </div>
                      </div>
                    )}
                    <div className="md:pl-10">
                      <h3 className="mb-6 text-xl font-medium">
                        For Researchers
                      </h3>
                      <p className="text-base font-[450] text-muted-foreground">
                        This dApp is built using Fortis Oracle. Fortis Oracle
                        leverages Chainlink infrastructure (Data Streams and
                        Data Feeds) and provides simple and useful Oracle for
                        next-level high-performant dApps.
                      </p>
                      <a
                        href="https://github.com/killroy192/fortis-sdk"
                        target="_blank"
                        rel="noreferrer"
                        className="mt-4 flex items-center space-x-[8px] text-base font-bold leading-4 underline hover:brightness-125"
                      >
                        <Image
                          src="/github.svg"
                          width={16}
                          height={16}
                          alt="github"
                        />
                        <span className="text-sm font-bold leading-4 text-white">
                          Go to Repository
                        </span>
                        <Image
                          src="/external-link.svg"
                          width={12}
                          height={12}
                          alt="external-link"
                        />
                      </a>
                    </div>
                  </div>
                </div>
                <div className="mb-4 mt-6 rounded-md border bg-[rgb(24,29,41)]/60 p-10 md:mb-16">
                  <h3 className="mb-6 text-xl font-medium">Disclaimer</h3>
                  <p className="text-sm italic">
                    This demo represents an non-production example to
                    demonstrate how to use with Fortis Oracle. This template is
                    provided “AS IS” and “AS AVAILABLE” without warranties of
                    any kind. Do not use the code in this example in a
                    production environment without completing your own adults
                    and application of best practices. Neither Fortis Oracle
                    developers, the Chainlink Foundation, nor Chainlink node
                    operators are responsible for unintended outputs that are
                    generated due to errors in the code.
                  </p>
                </div>
              </footer>
            </div>
          </Providers>
        </SocketProvider>
      </body>
    </html>
  );
}
