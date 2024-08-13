🌳 Plowright Family Tree
======================================================================================================
Version **1.0.0**, by Andrew Plowright


# Summary

Creation of a printable family tree for my Pierre Tremblay (my uncle) using the data gathered by his relatives as well as data available on [nosorigines.qc.ca](https://www.nosorigines.qc.ca/).

# Updates

- **v.0.9.1, 2024-07-06**: First draft sent to Catherine Plowright for review.

# Processing

## 1. Manually clean up data

The [preliminary spreadsheet](<xlsx/Plowright Fowler tree for Andrew v.1.xlsx>) provided by Catherine Plowright was [manually cleaned up](xlsx/plowright_data_cleaned.xlsx).

## 2. Convert to JSON

The [plowright_data_processing.R](plowright_data_processing.R) file is used to convert the [manually cleaned-up spreadsheet](xlsx/plowright_data_cleaned.xlsx) to JSON format, including [plowright_data_cleaned.json](json/plowright_data_cleaned.json) and [plowright_collapsed_branches.json](json/plowright_collapsed_branches.json), which defines which families will be collapsed (for future projects, I don't think it's necessary to have this as a second JSON file). 

## 3. Plot initial positions

The [1_graph_skeleton.jsx](js/1_graph_skeleton.jsx) script takes the data in [plowright_data_cleaned.json](json/plowright_data_cleaned.json) and graphs it into Illustrator. The next step is to:
1. Manually reposition the nodes
2. Manually trim out unwanted nodes (mostly in order to fit the tree into a legible layout)
4. Save the results as [plowright_skeleton_trimmed.ai](ai/plowright_skeleton_trimmed.ai)
4. Run the [2_get_repositions.jsx](js/2_get_repositions.jsx) script to grab this information from the AI file and save it in the [plowright_repositions.json](json/plowright_repositions.json) file

## 4. Plot the results into a family tree

The final step is to use the [3_populate_tree.jsx](js/3_populate_tree.jsx) script to create the final family tree, which is saved as [plowright_family_tree.ai](ai/plowright_family_tree.ai) and then saved as a PDF. 