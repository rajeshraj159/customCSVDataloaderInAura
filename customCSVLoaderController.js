({
  handleUploadFinished: function (component, event, helper) {
    //var fileInput = component.find("file").getElement(); //--1
    //var file = event.getSource().get("v.files");
    /*var files = event.getSource().get("v.files"); //--2
        console.log('files=>'+files[0]);
        console.log('files.length=>'+files.length);
        /*files.forEach((a)=>{
          console.log('files=>'+files[a]);
        });*/
    // var file = fileInput.files[0];*/
    var fileInput = component.find("file").get("v.files"); //--3
    var file = fileInput[0];
    if (file) {
      console.log("UPLOADED");
      var reader = new FileReader();
      reader.readAsText(file, "UTF-8");
      reader.onload = function (evt) {
        var csv = evt.target.result;
        component.set("v.csvString", csv);
        component.set("v.showcard", true);
      };
    }
  },

  handleGetCSV: function (component, event, helper) {
    var csv = component.get("v.csvString");
    if (csv != null) {
      helper.createCSVObject(component, csv);
    }
  },

  insertRecord: function (component, event, helper) {
    var varSelectedObject = component.get("v.selectedValue"); //component.find("onjId").get("v.value");
    console.log("varSelectedObject==>" + varSelectedObject);
    var csv = component.get("v.csvString");

    helper.columnHeader(component, csv);
  },

  cleanData: function (component, event, helper) {
    component.set("v.csvString", null);
    component.set("v.csvObject", null);
  },

  init: function (component, event, helper) {
    helper.getAllObjectNameInPicklist(component);
  }
});