 #include "json2.js";

 var outFile = new File("C:/Users/andre/Dropbox/Work/Personal/BystramGeneology/JSON/dropped_branches.json")
 var doc = app.activeDocument;
 
var selectedObjects = app.activeDocument.selection; 
 
var selectedIDs = {}
 
for(var i = 0; i < selectedObjects.length; i++){
    id = selectedObjects[i].name
    selectedIDs[id] = ""
}

alert(JSON.stringify(selectedIDs))

 outFile.open("w");

    outFile.write(JSON.stringify(selectedIDs));

    outFile.close();
    
