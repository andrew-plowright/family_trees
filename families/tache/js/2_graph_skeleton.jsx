#include "json2.js";
#include "../paths.js"; 
 
// Open file: blank_skeleton.ai  
 
// Graph the initial skeleton of the family tree based on "cleaned" data 

// The next step is to manually reposition nodes within the AI file

// Read content
var data_file = File(data_path);
var open_res = data_file.open('r');
if(!data_file){alert("Data file is not found")}

var data = JSON.parse(data_file.read());
data_file.close(); 
 
 // Get document
var doc = app.activeDocument;
var doc_w = doc.width;
var doc_h = doc.height;
var skel = doc.layers.getByName('Skeleton')
var skel_nodes = skel.layers.getByName('Nodes')
var skel_links = skel.layers.getByName('Links')

// Set variables
var space_x = 50
var space_y = 100
var offset_x = 100
var offset_y = 100

// Colors
var node_col_fill = new RGBColor();
node_col_fill.red = 245;
node_col_fill.green = 245;
node_col_fill.blue = 245;
var node_col_stroke = new RGBColor();
node_col_stroke.red = 15;
node_col_stroke.green = 15;
node_col_stroke.blue = 15;

function node_centre(position, gen){
        
    x = (position - 1) * space_x + offset_x
    y = (gen - 1) * -space_y - offset_y 
    return [x,y]
    }

function node_centre_get(id){
    try{
         node = skel_nodes.groupItems.getByName(id)
        bounds = node.geometricBounds
        return [((bounds[2] - bounds[0]) / 2) + bounds[0], ((bounds[3] - bounds[1]) / 2) + bounds[1]]
    }catch(e){
        return null
    }

 }

function node_create(coords, radius, id){
    
    left = coords[0] - radius
    top = coords[1] + radius
    diam = radius * 2
    
    // Make group
    grp = skel_nodes.groupItems.add()
    grp.name = id

    // Make text
    txt = skel_nodes.textFrames.pointText(coords)
    txt.contents = id
    txt.textRange.justification = Justification.CENTER;
    txt.moveToEnd(grp)

    // Make ellipse

    ell = skel_nodes.pathItems.ellipse(top, left, diam, diam)
    ell.moveToEnd(grp)
    ell.fillColor = node_col_fill
    ell.strokeColor = node_col_stroke

}

function draw_links(fam_id){
    
    fam = fams[fam_id]
    
    if(fam.HUSB != null & fam.WIFE != null){
        
        husb_centr = node_centre_get(fam.HUSB[0])
        wife_centr = node_centre_get(fam.WIFE[0])
        
         if(husb_centr != null & wife_centr != null){
        
            // Determine midpoint between spouses
            mid_pt = [(husb_centr[0] +  wife_centr[0]) / 2, (husb_centr[1] +  wife_centr[1]) / 2]
            
            // Make group
            fam_grp = skel_links.groupItems.add()
            fam_grp.name = fam_id
            
            // Make spouse line
            var spouse_line = skel_links.pathItems.add();
            spouse_line.setEntirePath([ 
                husb_centr,
                wife_centr
            ]);
            spouse_line.strokeWidth = 2
            spouse_line.moveToEnd(fam_grp)
            
            if(fam.collapse){
            }else{
            
            
            }
            // Make children lines
            if(fam.CHIL != null){
                
                
                if(fam.collapse[0] === true){
                    var collapse_line = skel_links.pathItems.add();
                   
                    // Create point below couple
                    collapse_pt = [mid_pt[0], mid_pt[1] - space_y/2]
                    collapse_line.setEntirePath([collapse_pt,mid_pt]);
                            
                    collapse_line.strokeWidth = 2
                    collapse_line.moveToEnd(fam_grp)
                    
                }else{
                    for(var i = 0; i < fam.CHIL.length; i ++){
                
                        chil_id = fam.CHIL[i]
                        chil_pt =  node_centre_get(chil_id)
                    
                        if(chil_pt != null){
                            var chil_line = skel_links.pathItems.add();
                            chil_line.setEntirePath([ chil_pt,mid_pt]);
                            
                            chil_line.strokeWidth = 2
                            chil_line.moveToEnd(fam_grp)
                        }
                    }
                }
            }
        }
    }
 }

// Create nodes
var inds = data['individuals']
if(skel_nodes.pageItems.length == 0){
    for (id in inds) {
    ind = inds[id]

        if(ind.graph[0] === true){
            
            node_create(node_centre(ind.position, ind.gen), 20, id)
        }
    }
}
 
 // Create links
var fams = data['families']
if(skel_links.pageItems.length == 0){
    for (fam_id in fams) {
        draw_links(fam_id)
    }
}

//~ alert('skel_nodes: ' + skel_nodes.pageItems.length)