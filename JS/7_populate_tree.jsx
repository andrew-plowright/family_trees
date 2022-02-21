#include "json2.js";
#include "../paths.js";  
#include "populate_tree_functions.jsx";
 
// Read JSON
var data_tree = readJSON(data_path)
var data_drop = readJSON(dropped_path)
var data_repo = readJSON(reposition_path)
var data_inds = data_tree['individuals'] 
var data_fams = data_tree['families']
 
 // Get document
var doc = app.activeDocument;
var doc_w = doc.width;
var doc_h = doc.height;
var lyr_nodes = doc.layers.getByName('Nodes')
var lyr_links = doc.layers.getByName('Links')
var lyr_templates = doc.layers.getByName('Template')

// Set variables
var space_x = 25
var space_y = 75
var offset_x = 150
var offset_y = 150
var link_offset = 30

// Set style
var link_style = {
    width : 0.25
}

// Get template
node_template = lyr_templates.groupItems.getByName('Node template')
node_template_bounds = node_template.geometricBounds
node_template_centre = bound_centre(node_template_bounds)

// Colors
var node_col_fill = rgb(245, 245, 245);
var node_col_unknown = rgb(241, 242, 242);
var node_col_stroke = rgb(15, 15, 15); 
 

// Create nodes
if(lyr_nodes.pageItems.length == 0){
    for (id in data_inds) {
        
        var data_ind = data_inds[id]
        
        var gen = data_ind.gen
        var position = data_repo[id]        
        var coords = node_centre(position, gen)
        
        if(position != null){     
            node_create(coords, id, data_ind)
        }
    }
}
 
 // Create links
if(lyr_links.pageItems.length == 0){
    for (fam_id in data_fams) {
        draw_links(fam_id)
    }
}