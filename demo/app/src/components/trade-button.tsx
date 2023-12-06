"use client";

import { useState } from "react";

import { useAccount } from "wagmi";

import { Button } from "@/components/ui/button";
import { toast } from "@/components/ui/use-toast";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogTrigger,
} from "@/components/ui/dialog";
import TradeDialog from "@/components/trade-dialog";

import { Pair } from "@/_types";

export const TradeButton = ({
  pair,
  isFallbacked = false,
}: {
  pair: Pair;
  isFallbacked?: boolean;
}) => {
  const { isConnected } = useAccount();

  const [open, setOpen] = useState(false);

  const buttonName = isFallbacked ? "Trade using Fallback" : "Trade";

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      {isConnected ? (
        <DialogTrigger asChild>
          <Button
            // disabled={!prices[pair]}
            className="w-[156px] bg-[#375BD2] py-3 text-base font-black leading-4 hover:bg-[#375BD2]/90"
          >
            {buttonName}
          </Button>
        </DialogTrigger>
      ) : (
        <Button
          className="w-[156px] bg-[#375BD2] py-3 text-base font-black leading-4 hover:bg-[#375BD2]/90"
          onClick={() =>
            toast({
              title: "Connect wallet:",
              description: "To place a trade, please connect",
            })
          }
        >
          {buttonName}
        </Button>
      )}
      <DialogContent className="max-w-[400px] bg-[#181D29] pt-8 sm:max-w-[400px]">
        <TradeDialog
          pair={pair}
          isFallbacked={isFallbacked}
          closeDialog={() => {
            setOpen(false);
          }}
        />
      </DialogContent>
    </Dialog>
  );
};
