# text_classification
Shiny Dashboard  created for categorizing fuzzy data using string-distance algorithms 


#Application Interface, How it Works
	1. The Shiny application is designed to take in a csv file that contains a column with a variable length string for its values
	2. Then within those values, identify specific string patterns and return a logical vector on whether the specified string patterns exist

	1. To use the tool, you need a csv file that contains the column with the variable length string values
	2. Then you need another csv file that contains string patterns in which you want to identify

	3. String patterns do not need to be an exact match, and the user can adjust for string pattern similarities within the tool.



	3. Here is an example of how the tool works


Code Walkthrough

Shiny
	1. Shiny is a package/library developed for R so that you can easily deploy web applications 
	2. The package relies mainly on 3 scripts, the "front-end" for UI, the "back-end" for server, and the global script to load any code that needs to be universal such as libraries. 


UI

	1. When working with Shiny Dashboards, there are a few objects that are nested within the dashboardPage() command, these objects determine the larger ui categories like header, sidebar, etc. I've decided to use Header for displaying information regarding the application, sidebar for inputting parameters & selecting which body to display, and the Body() which shows larger formats of data graphs based on the parameters you have set, in my case I've set the body to display visual checks for data validation purposes. 

	2. The way in which the UI script communicates with the server script is through objects by labeling input Id's such as in_df, search_df etc. 
	3. These labels are then identified in the server script by using input_id$ind_df, 


Server
	1. The server is where you specify the functions associated with the input objects created in the UI script. 

	2. I begin the script by allowing the application to read in data files it needs to process, which is 1st the in_raw object which is the csv file that contains column with variable length string values 
	3. 2nd is the search_df wich is the csv file that contains the string patterns that is being searched. 

	4. Then I return the csv files as the body of the shiny dashboard so that the user can visually insect whether the data has been loaded correctly



	5. The meat of the tool is in the proceeding code where it cleans and transforms the data based the inputted paramotors. 
		a. I start with first defining objects based on the inputted parameters such as whether the user want's an exact match, if not, the specified string distance and the algorithm used to define what the distance means. 
