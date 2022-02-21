 #include "json2.js";

 var doc = app.activeDocument;
var skel = doc.layers.getByName('Skeleton')
var skel_nodes = skel.layers.getByName('Nodes')

var beige = new RGBColor();
  beige.red = 245;
  beige.green = 240;
  beige.blue = 190;

// Read content
var scriptFile = File("C:/Users/andre/Dropbox/Work/Personal/BystramGeneology/JSON/dropped_branches.json");

scriptFile.open('r');
var data = JSON.parse(scriptFile.read());
scriptFile.close();

for(id in data){
    num = data[id]
    if(num > 0){
        node = skel_nodes.groupItems.getByName(idzz)
        circle = node.pathItems[0]
        circle.fillColor = beige
    }
}

// "I562":4, These guys have four children but there's no room in the tree

