import { CircleHelp } from "lucide-react";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { cn } from "@/lib/utils";

interface HelpTipProps {
  content: React.ReactNode;
  side?: "top" | "bottom" | "left" | "right";
  className?: string;
}

export function HelpTip({ content, side = "top", className }: HelpTipProps) {
  return (
    <Popover>
      <PopoverTrigger asChild>
        <button
          type="button"
          aria-label="More information"
          className={cn(
            "inline-flex items-center justify-center rounded-full text-muted-foreground",
            "hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
            "min-h-[44px] min-w-[44px] -my-2 -mx-2",
            className,
          )}
        >
          <CircleHelp className="w-4 h-4" />
        </button>
      </PopoverTrigger>
      <PopoverContent
        side={side}
        className="max-w-[280px] text-sm leading-relaxed"
        onOpenAutoFocus={(e) => e.preventDefault()}
      >
        {content}
      </PopoverContent>
    </Popover>
  );
}
