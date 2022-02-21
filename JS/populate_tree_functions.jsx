
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

function link_create(coords,  group, link_style){
    var link = lyr_links_fam.pathItems.add();
    link.setEntirePath(coords);
    link.strokeWidth = link_style['width']
    link.strokeColor = link_style['strokeColor']
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
    grp_fields = ['GIVEN NAME', 'SUR NAME', 'BIRTH DATE', 'BIRTH PLACE', 'DEATH DATE', 'DEATH PLACE']
    for(var i = 0; i < grp_fields.length; i ++){
        field = grp_fields[i]
        grp_items[field] = grp.textFrames.getByName(field)
    }
        
    // Recentre
    recentre = 0        
        
    // GIVEN NAME
    if(data['NAME']['GIVN'] != null){
        
        grp_items['GIVEN NAME'].contents = data['NAME']['GIVN'][0]
        
        if(grp_items['GIVEN NAME'].lines.length < 2){
            grp_item_translate(['SUR NAME',  'BIRTH PLACE', 'BIRTH DATE', 'DEATH DATE', 'DEATH PLACE'], 2.5) 
            recentre += 2.5
        }
    
    }else{
        grp_item_remove(['GIVEN NAME'])
        grp_item_translate(['SUR NAME',  'BIRTH PLACE', 'BIRTH DATE', 'DEATH DATE', 'DEATH PLACE'], 7.5)
        recentre += 7.5
    }

    // SUR NAME
    if(data['NAME']['SURN'] != null){
        
        // SUR NAME (forcing a line break wherever hyphens are found
        grp_items['SUR NAME'].contents = data['NAME']['SURN'][0].replace('-', '-\n')
        
        if(grp_items['SUR NAME'].lines.length < 2){
            grp_item_translate(['BIRTH PLACE', 'BIRTH DATE', 'DEATH DATE', 'DEATH PLACE'], 2.5)
            recentre += 2.5
        }            
        
    }else{
        grp_items['SUR NAME'].contents = 'Unknown'
        grp.pathItems.getByName('Box').fillColor = node_col_unknown
        
    }
 
    // BIRTH
    if(data['BIRT'] != null && data['BIRT']['YEAR'] != null){
            
            var born_circa = ''
            if(data['BIRT']['CIRCA'][0]){
                born_circa = 'ca. '
            }
            
            grp_items['BIRTH DATE'].contents = 'B: ' + born_circa + data['BIRT']['YEAR'][0]
            
            if(data['BIRT']['PLAC'] != null){
                grp_items['BIRTH PLACE'].contents = data['BIRT']['PLAC'][0]
            }else{
                grp_item_remove(['BIRTH PLACE'])         
                grp_item_translate(['DEATH DATE', 'DEATH PLACE'], 5)
                recentre += 5

            }
    }else{
        
        grp_item_remove(['BIRTH DATE', 'BIRTH PLACE'])
        grp_item_translate(['DEATH DATE', 'DEATH PLACE'], 10)
        recentre += 10

    }   
        
    // DEATH
    if(data['DEAT'] != null && data['DEAT']['YEAR'] != null){  
        
        var deat_circa = ''
        if(data['DEAT']['CIRCA'][0]){
            deat_circa = 'ca. '
        }        
        
        grp_items['DEATH DATE'].contents = 'D: ' + deat_circa + data['DEAT']['YEAR'][0]
        
        if(data['DEAT']['PLAC'] != null){
            grp_items['DEATH PLACE'].contents = data['DEAT']['PLAC'][0]
        }else{
             grp_item_remove(['DEATH PLACE'])
             recentre += 5

        }
    }else{
         grp_item_remove(['DEATH DATE', 'DEATH PLACE'])
         recentre += 10

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
        
        husb_centr = node_centre_get(fam.HUSB[0])
        wife_centr = node_centre_get(fam.WIFE[0])
               
         if(husb_centr != null & wife_centr != null){
        
            // Nudge centres to the side
            if(husb_centr[0] > wife_centr[0]){
                husb_centr[0] = husb_centr[0] - 10
                wife_centr[0] = wife_centr[0]+ 10
            }else{
                husb_centr[0] = husb_centr[0] + 10
                wife_centr[0] = wife_centr[0] - 10
            }
        
            // Make group
            fam_grp = lyr_links_fam.groupItems.add()
            fam_grp.name = fam_id
            
            // Spouse link
            link_create([ 
                husb_centr,
                [husb_centr[0], husb_centr[1] - link_offset],
                [wife_centr[0], wife_centr[1] - link_offset],
                wife_centr
            ],  fam_grp, link_style)            
            
            // Make children lines
            if(fam.CHIL != null){
                
				// Holders
				var chil_lines_x = []
				var chil_lines_y = []
				
                for(var i = 0; i < fam.CHIL.length; i ++){
                
                    chil_id = fam.CHIL[i]
                    chil_centr =  node_centre_get(chil_id)
                
                    if(chil_centr != null){
                        
                        chil_lines_x.push(chil_centr[0])
                        chil_lines_y.push(chil_centr[1])
                        
                        // Child link
                        link_create([ 
                            [chil_centr[0], chil_centr[1] + link_offset],
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

                       // Line that spans siblings
                       link_create([ 
							[chil_lines_x_min, chil_lines_y_mid + link_offset],
							[chil_lines_x_max, chil_lines_y_mid + link_offset]
                        ],  fam_grp, link_style)   

                        // Determine midpoint between spouses
                        mid_pt = (husb_centr[0] +  wife_centr[0]) / 2
                     
                        if(mid_pt >= chil_lines_x_min & mid_pt <= chil_lines_x_max){
                            chilspouse_coords = [
                                [mid_pt, husb_centr[1] - link_offset],
                                [mid_pt, chil_lines_y_mid + link_offset]
                            ]
                        }else if(mid_pt < chil_lines_x_min){
                            chilspouse_coords = [
                                [mid_pt, husb_centr[1] - link_offset],
                                [mid_pt, husb_centr[1] - (link_offset * 1.25)],
                                [chil_lines_x_min,  chil_lines_y_mid + (link_offset * 1.25)],
                                [chil_lines_x_min, chil_lines_y_mid + link_offset]	   
                            ]
                        }else if(mid_pt > chil_lines_x_max){
                            chilspouse_coords = [
                                [mid_pt, husb_centr[1] - link_offset],
                                [mid_pt, husb_centr[1] - (link_offset * 1.25)],
                                [chil_lines_x_max,  chil_lines_y_mid + (link_offset * 1.25)],
                                [chil_lines_x_max, chil_lines_y_mid + link_offset]	   
                            ]
                        }
                     
                        // Link that connects children to spouse
                        link_create(chilspouse_coords,  fam_grp, link_style)   
                }
            }
        }
    }
 }
 
 function node_disc_create(id){
 
    var coords = node_centre_get(id)
    var chil = data_disc[id]
         
     if(coords != null & chil > 0){
         
        type = 'single'
        contents = '1 child'
        if(chil > 1){
            type = 'multi' 
            contents = chil + ' children'
        }

        disc_coords = [coords[0], coords[1] - space_y]

        var delta = [disc_coords[0] - node_disc_template[type]['centre'][0] , disc_coords[1] - node_disc_template[type]['centre'][1]]

        // Copy template
        var grp =  node_disc_template[type]['obj'].duplicate()

        // Name node and move
        grp.name = id
        grp.move(lyr_nodes_disc, ElementPlacement.PLACEATEND)
        grp.translate(delta[0], delta[1])
        
        // Contents
         grp.textFrames.getByName('CHILDREN').contents = contents
     }
 }

function draw_disc_link(id){
    
    var coords = node_centre_get(id)
    var chil = data_disc[id]
         
     if(coords != null & chil > 0){
         
        disc_coords = [coords[0], coords[1] - space_y]

        var link = link_create([ 
            coords,
            disc_coords
        ],  lyr_links_disc, link_style)      
        
        link.name = id
     }
}