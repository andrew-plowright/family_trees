Taché Family Tree
======================================================================================================
Version 0.9.0, by Andrew Plowright


# Summary

Creation of a printable family tree for my Pierre Tremblay (my uncle) using the data gathered by his relatives as well as data availab on [nosorigines.qc.ca](https://www.nosorigines.qc.ca/).


# Updates

- **v0.9.0, 2023-08-12**: Catherine Plowright transcribes data into [preliminary Excel spreadsheet](R/xlsx/Pierre's family data sent to Andrew August 12th.xlsx)
- **v0.9.0, 2023-10-14**: Finish manual clean-up off Excel data.

# Processing

## 1. Manually clean up data

I took the [preliminary Excel spreadsheet](xlsx/Pierre's family data sent to Andrew August 12th.xlsx) provided by Catherine Plowright and [manually it cleaned up](xlsx/tache_data_cleaned.xlsx). This involved:
- Verifying the transcribed data
- Adding new family members based on findings from [nosorigines.qc.ca](https://www.nosorigines.qc.ca/)

## 2. Convert to JSON

1. Launch ExtendScript Toolkit CC
2. At the top-left corner, select "Adobe Illustrator 2022". Click the little chain icon to launch Adobe Illustrator.
3. Open the 'skeleton_blank.ai' file
4. Plot the initial skeleton of the family tree
5. "Prune" the tree and reposition nodes as needed