#include "json2.js";
#include "../paths.js";  

alert(reposition_path)
 
 var out_file = new File(reposition_path)
 
 // Get document
 var doc = app.activeDocument;
 
var skel = doc.layers.getByName('Skeleton')
var skel_nodes = skel.layers.getByName('Nodes')

var interval = 25

var reposition = {}

function get_centre(bounds){
    return [((bounds[2] - bounds[0]) / 2) + bounds[0], ((bounds[3] - bounds[1]) / 2) + bounds[1]]
}   

// Minimum left
lefts = []
for(var i = 0; i < skel_nodes.groupItems.length; i++){
    node = skel_nodes.groupItems[i]
    
    lefts.push(get_centre(node.geometricBounds)[0])
}
lefts.sort()
min_left = lefts[0]

for(var i = 0; i < skel_nodes.groupItems.length; i++){
    
    node = skel_nodes.groupItems[i]
    id = node.name
    bounds = node.geometricBounds
    centre = get_centre(bounds)
    x = centre[0]
    
    repo = ((x - min_left) / interval) + 1
    
    reposition[id] = repo
}

out_file.open("w");
out_file.write(JSON.stringify(reposition));
out_file.close();
    