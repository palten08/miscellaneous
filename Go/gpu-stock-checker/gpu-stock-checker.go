package main

import (
	"flag"
	"fmt"
	"github.com/gocolly/colly"
	"gopkg.in/toast.v1"
	"log"
	"regexp"
)

func main() {
	urlFlag := flag.String("URL", "https://www.microcenter.com/category/4294966937/video-cards", "The URL to scrape")
	storeFlag := flag.String("StoreID", "061", "The Microcenter store ID to check against")
	cardFlag := flag.String("CardType", "RTX 3090", "The card type to check for (Ex. RTX 3090)")

	flag.Parse()

	collector := colly.NewCollector()

	collector.OnHTML("#productGrid > ul > li.product_wrapper > div.result_right", func(element *colly.HTMLElement) {
		cardName := element.ChildText("h2 > a")
		regex, _ := regexp.Compile(*cardFlag)
		if regex.MatchString(cardName) {
			message := fmt.Sprintf("Microcenter may have a %s in stock", cardName)
			notification := toast.Notification{
				AppID:   "Microsoft.WindowsAlarms_8wekyb3d8bbwe!App",
				Title:   "Potential GPU in stock",
				Message: message,
				Audio:   toast.Default,
			}
			err := notification.Push()
			if err != nil {
				log.Fatalln(err)
			}
		}
	})

	collector.OnRequest(func(request *colly.Request) {
		request.Headers.Set("Cookie", fmt.Sprintf("storeSelected=%s;", *storeFlag))
	})

	collector.Visit(*urlFlag)
}
