# Load the linear model
load("forest.model.RDA")

# Select one of the output dataframes from the previous step (e.g., the first one)
new_data <- split_list[[1]]

# Predict the outcome variable using the linear model
prediction <- predict(forest, newdata = new_data)

# Combine the coordinates, predicted values, and actual values into a dataframe
result_df <- data.frame(z = prediction)

# Save the dataframe as a CSV file without headers
write.csv(result_df, file = "result.csv", row.names = FALSE, quote = FALSE, col.names = FALSE)
