#include "functions/json2.js";
#include "../tache_file_paths.js"; 
 
// Open file: tache_skeleton_trimmed.ai 

// Run this step once to get the new positions of nodes on the tree
 
 var out_file = new File(reposition_path)
 
 // Get document
 var doc = app.activeDocument;
 
var skel = doc.layers.getByName('Skeleton')
var skel_nodes = skel.layers.getByName('Nodes')

var interval = 5

var reposition = {}

function get_centre(bounds){
    
    var x = Math.round(((bounds[2] - bounds[0]) / 2) + bounds[0])
    var y =  Math.round(((bounds[3] - bounds[1]) / 2) + bounds[1])
    return [x,y]
}   

// Minimum left
lefts = []
for(var i = 0; i < skel_nodes.groupItems.length; i++){
    node = skel_nodes.groupItems[i]
    
    lefts.push(get_centre(node.geometricBounds)[0])
}
lefts.sort(function(a, b) {return a - b;})

min_left = lefts[0]

for(var i = 0; i < skel_nodes.groupItems.length; i++){
    
    node = skel_nodes.groupItems[i]
    id = node.name
    bounds = node.geometricBounds
    centre = get_centre(bounds)
    x = centre[0]
    
    repo = ((x - min_left) / interval)
    
    reposition[id] = repo
}

out_file.open("w");
out_file.write(JSON.stringify(reposition));
out_file.close();
    