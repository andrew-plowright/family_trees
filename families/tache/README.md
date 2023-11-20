🌳 Taché Family Tree
======================================================================================================
Version **1.0.0**, by Andrew Plowright


# Summary

Creation of a printable family tree for my Pierre Tremblay (my uncle) using the data gathered by his relatives as well as data available on [nosorigines.qc.ca](https://www.nosorigines.qc.ca/).


# Updates

- **v.0.8.0, 2023-08-12**: Catherine Plowright transcribed data into [preliminary spreadsheet](<xlsx/Pierre's family data sent to Andrew August 12th.xlsx>)
- **v.0.8.1, 2023-10-14**: Finish manual clean-up off Excel data.
- **v.0.9.0, 2023-10-20**: First full draft of the family tree. Sent to Catherine Plowright for review.
- **v.0.9.1, 2023-10-23**: Correction of typos. Sent to Pierre Tremblay for review.
- **v.0.9.2, 2023-11-16**: Received feedback from Pierre. Added several missing people and birth dates.
- **v.1.0.0, 2023-11-20**: Final adjustments made. Ready for print.

# Processing

## 1. Manually clean up data

The [preliminary spreadsheet](<xlsx/Pierre's family data sent to Andrew August 12th.xlsx>) provided by Catherine Plowright was [manually cleaned up](xlsx/tache_data_cleaned.xlsx). This involved:
- Verifying the transcribed data
- Adding new family members based on findings from [nosorigines.qc.ca](https://www.nosorigines.qc.ca/)

## 2. Convert to JSON

The [tache_data_processing.R](tache_data_processing.R) file is used to convert the [manually cleaned-up spreadsheet](xlsx/tache_data_cleaned.xlsx) to JSON format, including [tache_data_cleaned.json](json/tache_data_cleaned.json) and [tache_collapsed_branches.json](json/tache_collapsed_branches.json), which defines which families will be collapsed (for future projects, I don't think it's necessary to have this as a second JSON file). 

## 3. Plot initial positions

The [1_graph_skeleton.jsx](js/1_graph_skeleton.jsx) script takes the data in [tache_data_cleaned.json](json/tache_data_cleaned.json) and graphs it into Illustrator. The next step is to:
1. Manually reposition the nodes
2. Manually trim out unwanted nodes (mostly in order to fit the tree into a legible layout)
4. Save the results as [tache_skeleton_trimmed.ai](ai/tache_skeleton_trimmed.ai)
4. Run the [2_get_repositions.jsx](js/2_get_repositions.jsx) script to grab this information from the AI file and save it in the [tache_repositions.json](json/tache_repositions.json) file

## 4. Plot the results into a family tree

The final step is to use the [3_populate_tree.jsx](js/3_populate_tree.jsx) script to create the final family tree, which is saved as [tache_family_tree.ai](ai/tache_family_tree.ai) and then saved as a PDF. 