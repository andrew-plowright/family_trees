#include "functions/json2.js";
#include "../plowright_file_paths.js"; 
#include "functions/populate_tree.jsx";



 // Open file: blank_family_tree.ai

// Inputs (JSON):
// 1. The cleaned family data
// 2. A list of nodes that are "collapsed/discontinued" (i.e.: they will not branch off). This was created manually.
// 3. A list of repositioned nodes

// Outputs (AI)
// The final tree

// Read JSON
var data_tree = readJSON(data_path)
var data_repo = readJSON(reposition_path)

var data_inds = data_tree['individuals'] 
var data_fams = data_tree['families']
var data_disc = data_tree['collapse']

 // Get document
var doc = app.activeDocument;
var doc_w = doc.width;
var doc_h = doc.height;


var lyr_nodes_ind = doc.layers.getByName('Nodes').layers.getByName('Individuals')
var lyr_links_fam = doc.layers.getByName('Links').layers.getByName('Families')
var lyr_nodes_disc = doc.layers.getByName('Nodes').layers.getByName('Discontinued')
var lyr_links_disc = doc.layers.getByName('Links').layers.getByName('Discontinued')
var lyr_templates = doc.layers.getByName('Template')

lyr_templates.visible = true

clear_lyr(lyr_nodes_ind)
clear_lyr(lyr_links_fam)
clear_lyr(lyr_nodes_disc)
clear_lyr(lyr_links_disc)

// Set variables
var grid = 3
var space_x = 6
var space_y = 120
var offset_x = 120+6+18
var offset_y = 132+36+12+72
var link_vert_offset = 42
var link_lat_offset = 6

// Set style
var link_style = {
    width : 1,
    strokeColor: rgb(109, 110, 113)
}

// Get template
node_template = lyr_templates.groupItems.getByName('Node template')
node_template_bounds = node_template.geometricBounds
node_template_centre = bound_centre(node_template_bounds)

node_disc_template = {
    single: {
        obj: lyr_templates.groupItems.getByName('Disc template single'),
        centre: bound_centre(lyr_templates.groupItems.getByName('Disc template single').geometricBounds)
    },
    multi :{
        obj: lyr_templates.groupItems.getByName('Disc template multi'),
        centre: bound_centre(lyr_templates.groupItems.getByName('Disc template multi').geometricBounds)
    } 
}

// Colors
var node_col_fill = rgb(245, 245, 245);
var node_col_unknown = rgb(241, 242, 242);
var node_col_stroke = rgb(15, 15, 15); 
 
// Create nodes (individuals)
if(lyr_nodes_ind.pageItems.length == 0){
    for (id in data_inds) {

        var position = data_repo[id]        
       
        if(position != null){     
            var data_ind = data_inds[id]
             var gen = data_ind.gen
             var coords = node_centre(position, gen)
            node_create(coords, id, data_ind)
        }
    }
}

 
 // Create links (families)
if(lyr_links_fam.pageItems.length == 0){
    for (fam_id in data_fams) {
        draw_links(fam_id)
    }
}

//~ // Create discontinued branches
if(lyr_nodes_disc.pageItems.length == 0){
    for(id in data_disc){
        node_disc_create(id)
    }
}
if(lyr_links_disc.pageItems.length == 0){
    for(id in data_disc){
        draw_disc_link(id)
    }
}

lyr_templates.visible = false
