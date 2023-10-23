
// Read content
function readJSON(path){
    var infile = File(path);
    infile.encoding = "UTF-8"
    infile.open('r');
    var data = JSON.parse(infile.read());
    infile.close(); 
    return(data)
}

function rgb(r, g, b){
    var col = new RGBColor();
    col.red = r;
    col.green = g;
    col.blue = b;
    return(col)
}

function bound_centre(bounds){
    return [((bounds[2] - bounds[0]) / 2) + bounds[0], ((bounds[3] - bounds[1]) / 2) + bounds[1]]
}

function node_centre(position, gen){
        
    x = (position - 1) * space_x + offset_x
    y = (gen -1) * -space_y - offset_y
    return [x,y]
}

function node_centre_get(id){
    try{
         node = lyr_nodes_ind.groupItems.getByName(id)
        bounds = node.geometricBounds
        return bound_centre(bounds)
    }catch(e){
        return null
    }
}

function spouse_centre_get(fam_id){
  fam = data_fams[fam_id]
    
    if(fam.HUSB != null & fam.WIFE != null){
        
        husb_centr = node_centre_get(fam.HUSB)
        wife_centr = node_centre_get(fam.WIFE)
        
        mid_pt = (husb_centr[0] +  wife_centr[0]) / 2
        coords = [mid_pt, husb_centr[1]]
        
        return coords
    }else{
        alert("Could not find HUSB and WIFE for id '" + fam_id, "'")
    }
}


function link_create(coords,  group, link_style){
    var link = lyr_links_fam.pathItems.add();
    var no_color = new NoColor();
    link.setEntirePath(coords);
    link.strokeWidth = link_style['width']
    link.strokeColor = link_style['strokeColor']
    link.fillColor = no_color
    link.moveToEnd(group)
    return link
}

function grp_item_translate(item_names, y){
    for(var i = 0; i < item_names.length; i ++){
        item_name = item_names[i]
        grp_items[item_name].translate(0,y)
    }
}

function grp_item_remove(item_names){
    for(var i = 0; i < item_names.length; i ++){
        item_name = item_names[i]
        if(item_name != null){
            grp_items[item_name].remove()
            delete grp_items[item_name]            
        }
    }
}

// Delete all groups within a layer
function clear_lyr(layer){
    
    var layerCount=layer.pageItems.length
    
    for (var i = layerCount - 1; i >= 0; i--) {
        
        var group = layer.pageItems[i];
        group.locked = false;
        group.visible = true;
        group.remove();
    }
}

function node_create(coords, id, data){
    
    var delta = [coords[0] - node_template_centre[0] , coords[1] - node_template_centre[1]]

    // Copy template
    var grp = node_template.duplicate()
    
    // Name node and move
    grp.name = id
    grp.move(lyr_nodes_ind, ElementPlacement.PLACEATEND)
    grp.translate(delta[0], delta[1])
             
    // Get node items
    grp_items = {}
    grp_fields = ['GIVEN NAME', 'SUR NAME', 'BIRTH DATE', 'BIRTH PLACE', 'DEATH DATE']
    for(var i = 0; i < grp_fields.length; i ++){
        field = grp_fields[i]
        grp_items[field] = grp.textFrames.getByName(field)
    }
    
    // NOTE
    var note = grp.groupItems.getByName("NOTE")

    if(data['note'] != null){
        note_num = note.pageItems.getByName("NUM")
        note_num.contents = data['note']
    }else{
        note.remove()        
    }    
    
    // CONTENT
    
    recentre = 0        
   
    if(data['NAME'] != null){
        
        // GIVEN NAME
        if(data['NAME']['GIVN'] != null){
        
            grp_items['GIVEN NAME'].contents = data['NAME']['GIVN'].replace('-', '-\n')

            if(grp_items['GIVEN NAME'].lines.length < 2){
                grp_item_translate(['GIVEN NAME'], grid * -2) 
//~                 recentre += grid * 1
            }
           if(grp_items['GIVEN NAME'].lines.length > 2){
                grp_item_translate(['SUR NAME'], grid * -1) 
//~                 recentre += grid * 1
            }
    
        }else{
             grp_item_remove(['GIVEN NAME'])
//~             grp_item_translate(['SUR NAME',  'BIRTH PLACE', 'BIRTH DATE', 'DEATH DATE'], grid * 2)
//~             recentre += grid * 2
        }

        // SUR NAME
        if(data['NAME']['SURN'] != null){
            
            // SUR NAME (forcing a line break wherever hyphens are found
            grp_items['SUR NAME'].contents = data['NAME']['SURN'].replace('-', '-\n')
            
            if(grp_items['SUR NAME'].lines.length < 2){
                 grp_item_translate(['SUR NAME'], grid * -1)
                 grp_item_translate(['BIRTH DATE', 'DEATH DATE', 'BIRTH PLACE'], grid * 1)
//~                 recentre += grid * 1
            }            
        } else{
            grp_item_remove(['SUR NAME'])
        }
        
    }else{
        grp_item_remove(['GIVEN NAME'])     
        grp_items['SUR NAME'].contents = 'Unknown'
        grp.pathItems.getByName('Box').fillColor = node_col_unknown
        
    }  
 
    // BIRTH
    if(data['BIRT'] != null && data['BIRT']['YEAR'] != null){
            
            
            grp_items['BIRTH DATE'].contents = 'B: ' + data['BIRT']['YEAR']
            
            if(data['BIRT']['PLAC'] != null){
                grp_items['BIRTH PLACE'].contents = data['BIRT']['PLAC']
            }else{
                grp_item_remove(['BIRTH PLACE']) 
            }
    }else{
        
        grp_item_remove(['BIRTH DATE', 'BIRTH PLACE'])
//~         grp_item_translate(['DEATH DATE'], grid * 2)
//~         recentre += grid * 2

    }   
        
    // DEATH
    if(data['DEAT'] != null && data['DEAT']['YEAR'] != null){  
                
        grp_items['DEATH DATE'].contents = 'D: ' + data['DEAT']['YEAR']
        
    }else{
         grp_item_remove(['DEATH DATE'])
//~          recentre += grid * 2

    }

    // Apply recenteringz
    if(recentre > 0){
        for(grp_field in grp_items){
            grp_items[grp_field].translate(0,-(recentre/2))
        }
    }

}

function draw_links(fam_id){
    
    fam = data_fams[fam_id]
    
    if(fam.HUSB != null & fam.WIFE != null){
        
        husb_centr = node_centre_get(fam.HUSB)
        wife_centr = node_centre_get(fam.WIFE)
               
         if(husb_centr != null & wife_centr != null){
        
            // Nudge centres to the side
            if(husb_centr[0] > wife_centr[0]){
                husb_centr[0] = husb_centr[0] - link_lat_offset
                wife_centr[0] = wife_centr[0]+link_lat_offset
            }else{
                husb_centr[0] = husb_centr[0] + link_lat_offset
                wife_centr[0] = wife_centr[0] - link_lat_offset
            }
        
            // Make group
            fam_grp = lyr_links_fam.groupItems.add()
            fam_grp.name = fam_id
            
            // Lateral link between spouses
            link_create([ 
                husb_centr,
                [husb_centr[0], husb_centr[1] - link_vert_offset],
                [wife_centr[0], wife_centr[1] - link_vert_offset],
                wife_centr
            ],  fam_grp, link_style)            
            
            // Children
            if(fam.CHIL != null){
                
				var chil_lines_x = []
				var chil_lines_y = []
				
                for(var i = 0; i < fam.CHIL.length; i ++){
                
                    chil_id = fam.CHIL[i]
                    chil_centr =  node_centre_get(chil_id)
                
                    // Vertical link stemming upwards from child node
                    if(chil_centr != null){
                        
                        chil_lines_x.push(chil_centr[0])
                        chil_lines_y.push(chil_centr[1])
                        
                        // Child link
                        link_create([ 
                            [chil_centr[0], chil_centr[1] + link_vert_offset],
                            chil_centr
                        ],  fam_grp, link_style)   
                    }
                }
            
                 if(chil_lines_x.length > 0){
                     
					chil_lines_x.sort(function(a, b){return a-b})
					chil_lines_y.sort(function(a, b){return a-b})
                      chil_lines_x_min = chil_lines_x[0]
                      chil_lines_x_max = chil_lines_x[chil_lines_x.length - 1]
                      chil_lines_y_mid = chil_lines_y[0]

                       // Vertical link that spans siblings
                       link_create([ 
							[chil_lines_x_min, chil_lines_y_mid + link_vert_offset],
							[chil_lines_x_max, chil_lines_y_mid + link_vert_offset]
                        ],  fam_grp, link_style)   

                        // Determine midpoint between spouses
                        mid_pt = (husb_centr[0] +  wife_centr[0]) / 2
                     
                        if(mid_pt >= chil_lines_x_min & mid_pt <= chil_lines_x_max){
                            chilspouse_coords = [
                                [mid_pt, husb_centr[1] - link_vert_offset],
                                [mid_pt, chil_lines_y_mid + link_vert_offset]
                            ]
                        }else if(mid_pt < chil_lines_x_min){
                            chilspouse_coords = [
                                [mid_pt, husb_centr[1] - link_vert_offset],
                                [mid_pt, chil_lines_y_mid + link_vert_offset],
                                [chil_lines_x_min,  chil_lines_y_mid + link_vert_offset],

                            ]
                        }else if(mid_pt > chil_lines_x_max){
                            chilspouse_coords = [
                                [mid_pt, husb_centr[1] - link_vert_offset],
                                [mid_pt, chil_lines_y_mid + link_vert_offset],
                                [chil_lines_x_max,  chil_lines_y_mid + link_vert_offset],
                            ]
                        }
                     
                        // Link that connects children to spouse
                        link_create(chilspouse_coords,  fam_grp, link_style)   
                }
            }
        }
    }
 }
 
 function node_disc_create(fam_id){
 
    spouse_coords = spouse_centre_get(fam_id)
                
    var chil_num= data_disc[fam_id]

    if(chil_num > 0){
         
        type = 'single'
        contents = '1 enfant'
        if(chil_num > 1){
            type = 'multi' 
            contents = chil_num + ' enfants'
        }

        disc_coords = [spouse_coords[0], spouse_coords[1] - (space_y/2)]

        var template_coords = node_disc_template[type]['centre']
        var delta = [disc_coords[0] - template_coords[0] , disc_coords[1] - template_coords[1]]

        // Copy template
        var grp =  node_disc_template[type]['obj'].duplicate()

        // Name node and move
        grp.name = fam_id
        grp.move(lyr_nodes_disc, ElementPlacement.PLACEATEND)
        grp.translate(delta[0], delta[1])

        // Contents
        grp.textFrames.getByName('CHILDREN').contents = contents   
    }else{
        alert("No children for '" + fam_id, "'")
    }

 }

function draw_disc_link(fam_id){
    
    var spouse_coords = spouse_centre_get(fam_id)
    var chil_num = data_disc[fam_id]
         
     if(chil_num > 0){
         
         
         spouse_coords_link = [spouse_coords[0], spouse_coords[1] - link_vert_offset]
        disc_coords = [spouse_coords[0], spouse_coords[1] - (space_y/2)]

        var link = link_create([ 
            spouse_coords_link,
            disc_coords
        ],  lyr_links_disc, link_style)      
        
        link.name = id
    }else{
        alert("No children for '" + fam_id, "'")
    }
}