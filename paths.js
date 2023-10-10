var family = 'bystram'

var root_folder = File($.fileName).parent
var data_folder = root_folder + '/families/' + family + "/JSON/"

var data_path = data_folder + "data_cleaned.json"
var reposition_path = data_folder + "repositions.json"
var discontinued_path = data_folder + "discontinued_branches.json"