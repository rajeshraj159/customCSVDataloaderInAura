({
  createCSVObject: function (component, csv) {
    var action = component.get("c.getCSVObject");
    action.setParams({
      csv_str: csv
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.csvObject", response.getReturnValue());
      }
    });
    console.log("action==>" + action);
    $A.enqueueAction(action);
  },
  columnHeader: function (component, csv) {
    alert("===>" + component.get("v.selectedValue"));
    var action = component.get("c.columnHeader");
    action.setParams({
      csv_str: csv,
      objectName: component.get("v.selectedValue")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var columnHeader = response.getReturnValue();
        console.log("columnHeader==>" + columnHeader);
        //cmp.set("v.csvObject", response.getReturnValue());

        // display a message of successfully imported the records
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          title: "Success",
          message: columnHeader, // Calling from Apex Controller
          mode: "dismissible",
          duration: "2000"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },

  getAllObjectNameInPicklist: function (component) {
    var action = component.get("c.getObjectName");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var allValues = response.getReturnValue();
        component.set("v.options", allValues);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown Error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});