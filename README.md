[![Circle CI](https://circleci.com/gh/HipchecksAndHistograms/stats_scraper/tree/master.png?style=badge)](https://circleci.com/gh/HipchecksAndHistograms/stats_scraper/tree/master)

stats_scraper
=============

NHL.com Statistics Scraper. WIP.

### Intro
The goal of this project is to be able to scrape an NHL.com's play-by-play game sheet and insert it into a database for further analysis. I'd love to set this up in production for my own use, but also so that those without programming experience can download this dataset and analyze it using their tool of choice.

For now, there are no plans to do any further modelling / processing of the data. However, I do plan on writing a seperate tool (or possibly extend this one) to take the scraped data, apply some transforms, and spit out new data that is easier to use in analysis tools.

### What's done
- The scraper can scrape a [game day](http://www.nhl.com/ice/scores.htm) page and find the IDs of all games on that page. This ID (in combination with the season descriptor) is used to find the game sheet.
- The scraper can scrape a game sheet and get the home and visiting teams' name, the venue, and the number in attendance.
- The scraper can parse the events from the game sheet.

### What's left
- The ability to scrape a range of days.
- Storage of game / event information.
- The ability to remember where the scraper left off, so it can know which games it has already scraped, and which it needs to scrape.
- A command line interface that is cron-able.
- Anything else?

### Contributing
I welcome any contributions that will make this scraper better. If you can make it easier to read or if you find a bug in my code, please create an issue or send me a PR. While performance tweaks aren't very high on my list of concerns, I also welcome PRs of those kind so long as they keep the codebase readable and resilient to structural changes in the NHL.com website.

If you're sending me a PR:
1. Fork this repo;
2. Make commits to a feature branch; and,
3. Send me a PR.
