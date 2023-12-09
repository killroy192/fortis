"use client";

import * as z from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import Image from "next/image";
import {
  Address,
  createPublicClient,
  http,
  parseEther,
} from "viem";
import {
  useAccount,
  useBalance,
  useContractEvent,
  useContractWrite,
  usePrepareContractWrite,
} from "wagmi";

import { toast } from "@/components/ui/use-toast";
import { Button } from "@/components/ui/button";
import { DialogFooter, DialogTrigger } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Form, FormField, FormItem, FormLabel } from "@/components//ui/form";
import { ExchangePlatform, Pair } from "@/_types";
import { useState } from "react";
import {
  wethConfig,
  swapAppConfig,
  usdcConfig,
  oracleConfig,
} from "@/config/contracts";
import { Check } from "lucide-react";
import { arbitrumSepolia } from "viem/chains";
import { ethers } from "ethers";
import { useSocket } from "@/app/socket-provider";

const formSchema = z.object({
  from: z.coerce.number().gt(0),
  to: z.coerce.number().gt(0),
});

const client = createPublicClient({
  chain: arbitrumSepolia,
  transport: http(),
});
const coder = new ethers.AbiCoder();

const TradeDialog = ({
  pair,
  isFallbacked = false,
  closeDialog,
}: {
  pair: Pair;
  isFallbacked: boolean;
  closeDialog: () => void;
}) => {
  const [isLoading, setIsLoading] = useState(false);
  let fallbackInterval: NodeJS.Timeout | undefined;
  const [txHash, setTxHash] = useState<Address | undefined>();
  const { address } = useAccount();
  const { prices: exchangePrices } = useSocket();
  const [fWETH] = useState<Address | undefined>(wethConfig.address);
  const [fUSDC] = useState<Address | undefined>(usdcConfig.address);
  const { data: wethBalance } = useBalance({ address, token: fWETH });
  const { data: usdcBalance } = useBalance({ address, token: fUSDC });
  const unwatchTradeExecuted = useContractEvent({
    ...swapAppConfig,
    eventName: "TradeExecuted",
    listener(event) {
      console.log(event);
      toast({
        title: "Swap completed:",
        description: `Successfully exchanged WETH for USDC`,
        variant: "success",
      });
      setIsLoading(false);
      setTxHash(event[1].transactionHash);
      unwatchTradeExecuted?.();
      clearInterval(fallbackInterval);
      closeDialog();
    },
  });

  const prices = exchangePrices[ExchangePlatform.COINBASE];

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      from: 0,
      to: 0,
    },
  });

  const fromAmount = form.watch("from");

  const { writeAsync: approveWeth } = useContractWrite({
    ...wethConfig,
    functionName: "approve",
    onError(error) {
      toast({
        variant: "destructive",
        title: error.name,
        description: error.message,
      });
    },
    onSuccess() {
      toast({
        title: "Approve transaction has been sent",
      });
    },
  });

  const { writeAsync: trade } = useContractWrite({
    ...swapAppConfig,
    functionName: isFallbacked ? "notAutomatedTrade" : "trade",
    onError(error) {
      toast({
        variant: "destructive",
        title: error.name,
        description: error.message,
      });
    },
    onSuccess() {
      toast({
        title: "Swap in progress",
      });
    },
  });

  const { writeAsync: fallback } = useContractWrite({
    ...oracleConfig,
    functionName: "fallbackCall",
  });

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setIsLoading(true);
    const amountIn = parseEther(`${values.from}`);
    console.log("submitting", amountIn);

    if (fWETH == wethConfig.address) {
      await approveWeth({
        args: [swapAppConfig.address, parseEther(`${fromAmount}`)],
      });
    }

    const nonce = BigInt(new Date().getTime());
    const tradeArgs = {
      recipient: address!,
      tokenIn: fWETH!,
      tokenOut: fUSDC!,
      amountIn,
    } as const;

    const result = await trade({
      args: [tradeArgs, nonce],
      value: parseEther("0.00025")
    });
    const swapAddress: `0x${string}` = swapAppConfig.address;
    const bytesCallbackArgs = coder.encode(
      [
        "tuple(address recipient, address tokenIn, address tokenOut, uint256 amountIn)",
      ],
      [tradeArgs],
    );
    fallbackInterval = setInterval(async () => {
      console.log("fallback interval in");
      const requestStatus = await client.readContract({
        ...oracleConfig,
        functionName: "previewFallbackCall",
        args: [swapAddress, bytesCallbackArgs, nonce, address!],
      });
      const isFallbackCallable = (requestStatus as [string, boolean, string])[1];
      if (isFallbackCallable) {
        clearInterval(fallbackInterval);
        const isCalled = confirm(
          "Fallback is callable, do you want to call it?",
        );
        if (isCalled) {
          const fallbackResult = await fallback({
            args: [swapAddress, bytesCallbackArgs, nonce, address!],
          });
          console.log(fallbackResult, result);
        }
      }
    }, 1000);
  }

  return txHash ? (
    <div className="flex h-96 flex-col items-center justify-center">
      <Check className="rounded-full bg-[#2FB96C] p-2" width={60} height={60} />
      <h3 className="my-3 text-xl font-medium">Swap completed!</h3>
      <a
        href={`https://sepolia.arbiscan.io/tx/${txHash}`}
        target="_blank"
        rel="noreferrer"
        className="mt-4 flex items-center space-x-[8px] text-base font-bold leading-4 underline hover:brightness-125"
      >
        <span className="text-sm font-bold leading-4 text-white">
          View on Explorer
        </span>
        <Image
          src="/external-link.svg"
          width={12}
          height={12}
          alt="external-link"
        />
      </a>
    </div>
  ) : (
    <>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
          <div className="grid w-full grid-cols-2">
            <FormField
              control={form.control}
              name="from"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-base font-[450] leading-4">
                    From
                  </FormLabel>
                  <Input
                    type="number"
                    className="rounded-none border-0 p-0 text-[40px] font-medium leading-[52px] -tracking-[0.8px] [appearance:textfield] focus-visible:ring-0 focus-visible:ring-offset-0 [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none"
                    {...field}
                    onChange={(e) => {
                      if (Number(e.target.value) < 0) {
                        return;
                      }
                      form.setValue(
                        "to",
                        fWETH === usdcConfig.address
                          ? Math.round(
                              (Number(e.target.value) + Number.EPSILON) * 100,
                            ) /
                              100 /
                              Number(prices[pair])
                          : Number(e.target.value) * Number(prices[pair]),
                      );
                      field.onChange(e);
                    }}
                  />
                </FormItem>
              )}
            />
            <div className="flex flex-col items-end space-y-4">
              <Label className="text-base font-[450] leading-4 text-muted-foreground">
                Balance:&nbsp;
                <span className="text-foreground">
                  {wethBalance?.formatted}
                </span>
              </Label>
              <div className="flex items-center space-x-2 rounded-md bg-muted px-4 py-2">
                <span className="text-base font-[450] leading-4">
                  {wethBalance?.symbol}
                </span>
              </div>
            </div>
          </div>
          <div className="flex w-full items-center space-x-6">
            <div className="h-[1px] flex-1 bg-border" />
          </div>
          <div className="grid w-full grid-cols-2">
            <FormField
              control={form.control}
              name="to"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-base font-[450] leading-4">
                    To
                  </FormLabel>
                  <Input
                    type="number"
                    className="rounded-none border-0 p-0 text-[40px] font-medium leading-[52px] -tracking-[0.8px] [appearance:textfield] focus-visible:ring-0 focus-visible:ring-offset-0 [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none"
                    {...field}
                    onChange={(e) => {
                      if (Number(e.target.value) < 0) {
                        return;
                      }
                      form.setValue(
                        "from",
                        fWETH === usdcConfig.address
                          ? Number(e.target.value) * Number(prices[pair])
                          : Math.round(
                              (Number(e.target.value) + Number.EPSILON) * 100,
                            ) /
                              100 /
                              Number(prices[pair]),
                      );
                      field.onChange(e);
                    }}
                  />
                </FormItem>
              )}
            />
            <div className="flex flex-col items-end space-y-4">
              <Label className="text-base font-[450] leading-4 text-muted-foreground">
                Balance:&nbsp;
                <span className="text-foreground">
                  {usdcBalance?.formatted}
                </span>
              </Label>
              <div className="flex items-center space-x-2 rounded-md bg-muted px-4 py-2">
                <span className="text-base font-[450] leading-4">
                  {usdcBalance?.symbol}
                </span>
              </div>
            </div>
          </div>
          <div className="mt-2 text-xs font-[450] text-secondary-foreground">
            Note: swap values are approximate
          </div>
          <Button
            disabled={isLoading}
            type="submit"
            className="w-full bg-[#375BD2] text-base font-black leading-4 text-foreground hover:bg-[#375BD2]/90"
          >
            Swap
          </Button>
        </form>
      </Form>
      <DialogFooter>
        <DialogTrigger asChild>
          <Button className="w-full border-2 border-border bg-background text-base font-medium leading-4 text-foreground hover:bg-background/90 hover:text-muted-foreground">
            Cancel
          </Button>
        </DialogTrigger>
      </DialogFooter>
    </>
  );
};

export default TradeDialog;
