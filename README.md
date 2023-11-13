# Text Classification Tool

Application Interface, How it Works
	1. The Shiny application is designed to take a vector with values containing strings with variable lengths, and return a boolean vector on whether a specific string pattern was detected. 
	2. It takes a csv file that contains a dataframe with the vector with variable string lengths 
	3. The user can specify the string pattern and how similar the string pattern needs to be 


To Use the Tool You need
	1. Searched Dataframe: A csv file containing the dataframe with the variable length vector
	2. Search Dataframe: Another csv file containing a dataframe with all the string patterns you want to detect

The Parameters
	1. Exact Match: this parameter dictates whether the string pattern in the Searched Dataframe needs to be an exact match with the strings provided in the Search Dataframe 
	2. Letter Distance: if Exact Match is set to No, the toggle specifies how similar the string in the Searched Dataframe needs to be to return "True" in the returned boolean vector
	3. Algorithm: Specifies the definition of a unit of distance 
