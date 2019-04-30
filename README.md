Starting point:
	
There is a fake application, which manages the process of ordering and printing/sending deposit slips.
	Something went wrong a couple of times and the user didn't received the correct number of deposit slips he ordered.
	Each step the user/system does is logged and now we have a bunch of log files from different users, where we need to identify the lines where the user "saved" and order.

Implementation:
	
Identify the lines where more than 1 and less than 12 copies were ordered.
	Identify the lines with the corresponding file path
	Identify the user (the files are in a folder structure where you can see the user)
	Script must be run every 30mins
	Write the identified information in the Event Log
	Use REGULAR Expression for searching the content