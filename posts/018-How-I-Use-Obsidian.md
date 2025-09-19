# How I Use Obsidian for Organisation
For my day to day work I use Obsidian for note taking and organisation. My process is as follows:
- For each independent unit of work (e.g. a ticket) I will have a specific Obsidian page dedicated to it. I subdivide based on their status:
```
📂 Tickets
└ 📂 In Progress
  └ #133
	#211
└ 📂 In Review
  └ #93
└ 📂 Merged
  └ 📂 For test
    └ #31
  └ 📂 Complete
    └ #412
```
- These pages will contain notes and links, but crucially, no TODOs
	- TODOs are stored in a day file linking to the ticket notes page:
```
📂 Day Notes
└ 📂 2025
  └ 📂 09 September
    └ 17th Wednesday
    └ 18th Thursday
```
- A day note looks like:
  
___
___

##### Notes from Yesterday *Update at EoD*
- ~~Spoke to person about thing~~ *These are any non-todo notes from the day before that are copied over and struckthrough at the end of the day*
- Prioritise #211 testing notes 
- Monitor flickering getting worse *These are notes for tomorrow that aren't necessarily TODOs*
##### TODOs *Updated throughout the day*
- [x] Finish #344
- [ ] Finish #211 *I will link to the ticket note page here if required*

___
___

- At the end of the day I will add any non-todo notes into the "Notes from Yesterday" section, then copy over the full contents to tomorrows note
- I will remove any completed TODOs
### Key Benefits
- I wanted this process to be as simple and idiot proof as possible - I often have to keep track of multiple streams of work and having this structure makes it easy to do so
- Uses Obsidian native features like links
- One source of TODOs with links to ticket notes - makes it easy to keep track of all outstanding work and reduces risk of losing track of things
- Ticket organisation is drag and drop (just move the ticket note to the corresponding state)
- I have a running record of all the work I have completed on each day, including any notes from that day
- The overhead for managing this setup is very small, just create a new file for the new day and copy over the contents of the previous day, removing all completed stuff - this means I can't lose anything from the previous day without explicitly deleting it