# Copyright 2018 Stuart Buchanan
# Copyright 2020 Julio Santa Cruz
# This file is part of FlightGear.
#
# FlightGear is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
# GDU450 Interface controller.

var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
var aircraft_dir = "/home/julio/.fgfs/aircraft/Instruments-3d" ~ "/GDU-450/";
io.load_nasal(nasal_dir ~ 'Interfaces/PropertyPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/PropertyUpdater.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/NavDataInterface.nas', "fg1000");
io.load_nasal(aircraft_dir ~ 'Interfaces/GDU450NavComPublisher.nas', "fg1000");
io.load_nasal(aircraft_dir ~ 'Interfaces/GDU450NavComUpdater.nas', "fg1000");
#io.load_nasal(nasal_dir ~ 'Interfaces/GenericNavComPublisher.nas', "fg1000");
#io.load_nasal(nasal_dir ~ 'Interfaces/GenericNavComUpdater.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericFMSPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericFMSUpdater.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericADCPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericFuelInterface.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericFuelPublisher.nas', "fg1000");
#io.load_nasal(nasal_dir ~ 'Interfaces/GFC700Publisher.nas', "fg1000");#
#io.load_nasal(nasal_dir ~ 'Interfaces/GFC700Interface.nas', "fg1000");
print("All intefaces loaded");

var GDU450InterfaceController = {

  _instance : nil,

  INTERFACE_LIST : [
    "NavDataInterface",
    #"GenericEISPublisher",
    "GDU450NavComPublisher",
    "GDU450NavComUpdater",
    #"GenericNavComPublisher",
    #"GenericNavComUpdater",
    "GenericFMSPublisher",
    "GenericFMSUpdater",
    "GenericADCPublisher",
    "GenericFuelInterface",
    "GenericFuelPublisher",
#    "GFC700Publisher",
#    "GFC700Interface",
  ],

  # Factory method
  getOrCreateInstance : func() {
    if (GDU450InterfaceController._instance == nil) {
      GDU450InterfaceController._instance = GDU450InterfaceController.new();
    }

    return GDU450InterfaceController._instance;
  },

  new : func() {
    var obj = {
      parents : [GDU450InterfaceController],
      running : 0,
    };

    return obj;
  },

  start : func() {
    if (me.running) return;

    foreach (var interface; GDU450InterfaceController.INTERFACE_LIST) {
      var code = sprintf("me.%sInstance = fg1000.%s.new();", interface, interface);
      var instantiate = compile(code);
      instantiate();
      print("InterfaceController: loaded " ~ interface);
    }

    foreach (var interface; GDU450InterfaceController.INTERFACE_LIST) {
      var code = 'me.' ~ interface ~ 'Instance.start();';
      var start_interface = compile(code);
      start_interface();
      print("InterfaceController: started " ~ interface);
    }

    me.running = 1;
  },

  stop : func() {
    if (me.running == 0) return;

    foreach (var interface; GDU450InterfaceController.INTERFACE_LIST) {
      var code = 'me.' ~ interface ~ 'Instance.stop();';
      var stop_interface = compile(code);
      stop_interface();
      print("InterfaceController: stopped " ~ interface);
    }
  },

  restart : func() {
    me.stop();
    me.start();
  }
};
