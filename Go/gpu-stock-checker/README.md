![GitHub go.mod Go version (branch & subdirectory of monorepo)](https://img.shields.io/github/go-mod/go-version/palten08/miscellaneous/master?filename=Go%2Fgpu-stock-checker%2Fgo.mod&style=flat-square)

# GPU Stock Checker
## GPU shortages suck

I wrote this to run as a scheduled task every day to check my local Microcenter's inventory for RTX 3090 cards. If found, it creates a Windows 10 toast notification.

### Usage

 Run the binary directly from your shell of choice, or schedule it through cron / Windows task scheduler.

 Flags include:

 - URL: The Microcenter URL to check against. This defaults to https://www.microcenter.com/category/4294966937/video-cards
 - StoreID: The ID of the Microcenter store to use in the request so that local inventories can be returned. Defaults to "061" for the St. Davids, PA location
   - To find your store ID, check your browser storage for the "storeSelected" cookie. You can also obtain it in the header of the request when you refresh the results page.
 - CardType: The card type to search for. This uses a regex search, so be as general or specific as you'd like. Defaults to "RTX 3090"

### Building from source

1. Clone this repository
2. Run `go build gpu-stock-checker.go` to build the binary (If on Windows, feel free to use `-ldflags -H=windowsgui` to suppress the console window when the binary is ran)
