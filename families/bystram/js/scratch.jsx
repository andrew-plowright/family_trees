#include "json2.js";
#include "../paths.js"; 


// Read content
var data_file = File(data_path);
data_file.open('r');
var data = JSON.parse(data_file.read());
// data_file.close(); 

alert("helo")