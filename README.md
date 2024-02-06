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

The function will provide you with three plots available via:

- steps: Steps count for the last year (default, changeable via the optional parameter view_year) with marks for days over 15.000 steps (default, changeable via the optional parameter min_steps)
- egym_cals: Burned calories over egym activities by day
- egym_count: Count of the egym activities by day


