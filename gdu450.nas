# Copyright 2020 Julio Santa Cruz (Barta)
#
# This program is free software: you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation, either version 3 of the License, or 
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# GDU450 - FG1000 implementation

var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
var aircraft_dir = getprop("/sim/aircraft-dir");
var power_listener = nil;
var gdu450_dir = "/home/julio/.fgfs/aircraft/Instruments-3d" ~ "/GDU-450/";
var fg1000system = nil;

var load_gdu450 = func() {
	
	io.load_nasal(nasal_dir ~ 'FG1000.nas', "fg1000");
	io.load_nasal(gdu450_dir ~ 'Constants.nas', "fg1000");
	io.load_nasal(gdu450_dir ~ 'MFDPageController.nas', "fg1000");
	io.load_nasal(gdu450_dir ~ 'Interfaces/GDU450InterfaceController.nas', "fg1000");
	io.load_nasal(gdu450_dir ~ 'GDU450D.nas', "fg1000");

	# Patch fg1000 to support events
	fg1000.FG1000.display = func(index, target_object=nil) {
		if (me.displays[index] == nil) {
			print("displayMFD: unknown display index " ~ index);
			return;
		}

		if (target_object == nil) target_object = "Screen" ~ index;

		var targetcanvas = me.displays[index].getCanvas();
		targetcanvas.addPlacement({"node": target_object, "capture-events":1});
	};
	
	# Load the custom controller
	var interfaceController = fg1000.GDU450InterfaceController.getOrCreateInstance();

	interfaceController.start();

	var EIS ={engineMenu:"",systemMenu:""}; # Empty EIS to fool FG1000
	var svg_path = gdu450_dir ~ 'SVG/';
	fg1000system = fg1000.FG1000.getOrCreateInstance(EIS, nil, svg_path);
	
	# Custom widgets
	io.load_nasal(gdu450_dir ~ 'BarElement.nas', "fg1000");
	io.load_nasal(gdu450_dir ~ 'SelectableElement.nas', "fg1000");
	
	# Overide Surround controller
	io.load_nasal(gdu450_dir ~ 'MDFPages/Surround/SurroundController.nas', "fg1000");
	io.load_nasal(gdu450_dir ~ 'MDFPages/Surround/Surround.nas', "fg1000");

	var targetcanvas = canvas.new({
	"name" : "MFD Canvas",
	"size" : [1024, 639],
	"view" : [1024, 639],
	"mipmapping": 0,
	});

	targetcanvas.set("visible", 0);

	var mfd = fg1000.GDU450Display.new(fg1000system, fg1000system.EIS_Class, fg1000system.EIS_SVG, fg1000system.SVG_Path, targetcanvas, 1);
	fg1000system.displays[1] = mfd;
	fg1000system.display(index:1);
	setprop("/instrumentation/gdu450/loaded",true);
	print("GDU450 loaded");

}
# Turn on/off the displays 
var fg1000_power = func(n) {
	if (n.getValue() > 6) {
		# Show the device
		fg1000system.show(index:1);
		
		# Hack: Some nasal scripts and add-ons looks for this switch to
		# detect if the radio is serviceable...
		setprop("/instrumentation/comm/power-btn",1);
		setprop("/instrumentation/nav/power-btn",1);
	} elsif (fg1000system) {		
		fg1000system.hide(index:1);	        
		setprop("/instrumentation/comm/power-btn",0);
		setprop("/instrumentation/nav/power-btn",0);
    }
};

setlistener("sim/signals/fdm-initialized", load_gdu450);
setlistener("/systems/electrical/outputs/gps", fg1000_power);


