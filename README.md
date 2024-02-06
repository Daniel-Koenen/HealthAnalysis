# HealtAnalysis

This repository provides function to extract the following data from the data collected by Apple Health. Purpose is to make the annual process for getting the health points as efficient as possible.

## How to use

The following steps should be done:

1. Clone this repository.
2. Export the data from your Apple Device via Health App.
3. Copy the data into the project folder under the subfolder data.
4. Use the following function:

```julia

data = get_data("NAME OF YOUR APPLE WATCH")

```

