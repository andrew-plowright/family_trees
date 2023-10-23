// Read content
// var data_file = File(data_path);
// data_file.open('r');
// var data = JSON.parse(data_file.read());
// data_file.close(); 




if(false){
    
    alert(app.activeDocument.selection[0].fillColor)

    var link = app.activeDocument.activeLayer.pathItems.add();
    
    link.setEntirePath([[1,1],[100,-100], [200,0]]);
    link.strokeWidth = 2
    link.strokeColor = rgb(100,255,50)
    
 }

var doc = app.activeDocument;
lyr_templates = doc.layers.getByName('Template')

lyr_templates.visible = false
        
    
   