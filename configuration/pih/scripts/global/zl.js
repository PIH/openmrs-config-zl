function setUpExpandableContacts(badPhoneNumberMsg) {
  var contactsToShow = 1;
  var elem = document.getElementsByClassName("contacts");
  var maxContacts = elem.length;

  var hideOtherContacts = function () {
    jq("#contact-2").hide();
    jq("#contact-3").hide();
    jq("#contact-4").hide();
    jq("#contact-5").hide();
    jq("#contact-6").hide();
    jq("#contact-7").hide();
    jq("#contact-8").hide();
    jq("#contact-9").hide();
    jq("#contact-10").hide();
  };

  jq("#contact-" + contactsToShow).show();
  hideOtherContacts();
  jq("#show-less-contacts-button").hide();

  jq("#show-more-contacts-button").click(function () {
    if (maxContacts > contactsToShow) {
      contactsToShow++;
      jq("#contact-" + contactsToShow).show();
      if (contactsToShow > 1) {
        jq("#show-less-contacts-button").show();
      }
      if (contactsToShow == 10) {
        jq("#show-more-contacts-button").hide();
      }
    }
  });

  jq("#show-less-contacts-button").click(function () {
    if (maxContacts > contactsToShow || contactsToShow == 10) {
      if (contactsToShow > 1) {
        jq("#contact-" + contactsToShow).hide();
        contactsToShow--;
        if (contactsToShow == 1) {
          jq("#show-less-contacts-button").hide();
        }
      }
      jq("#show-more-contacts-button").show();
    }
  });

  for (let i = 0; maxContacts > i; i++) {
    //showing contact if exist data
    let contactHasValues = false;
    jq(`#contact-${i} input:checked, #contact-${i} input[type=text]`).each(
      function (j, domEl) {
        const element = jq(domEl);
        if (element.val()) {
          contactHasValues = true;
        }
      }
    )
    if (contactHasValues) {
      jq(`#contact-${i}`).show();
      contactsToShow++;
    }

    // Phone Number Regex validation
    jq("#contact-hiv-phone-" + i)
      .children(":input")
      .change(function (e) {
        var val = e.target.value;
        phoneNumber(val, i);
      });
  }

  function phoneNumber(inputted, index) {

    var pattern1 = /^\d{8}$/;
    var pattern2 = /^\d{4}(?:\)|[-|\s])?\s*?\d{4}$/;

    if (inputted.match(pattern1) || inputted.match(pattern2)) {
      jq("#next").prop("disabled", false);
      jq("#submit").prop("disabled", false);
      jq("#contact-phone-error-message-" + index).text("");
    } else {
      jq("#contact-phone-error-message-" + index).text(badPhoneNumberMsg);
      jq("#next").prop("disabled", true);
      jq("#submit").prop("disabled", true);
    }
  }

}

/**
 * Given the widget ids of two obs of value dates, assures that the "start date" cannot be after the "end date"
 * and that the "end date" cannot be before the "start date" by updating the min and max dates of the respective
 * date pickers
 *
 * To use:
 *    1) Add the class "startDateEndDate" to a parent element in the DOM that includes both the start and end date widgets
 *    2) Apply "startDate" class to the start datepicker element, and "endDate" to the end datepicker element
 *    3) Call setupDatepickerStartAndEndDateValidation() upon page load
 */
function setUpDatepickerStartAndEndDateValidation() {

  jq(".startDateEndDate").each(function (j, domEl) {

    const startDatepicker = jq(jq(this).find('.startDate'));
    const endDatepicker = jq(jq(this).find('.endDate'));

    if (startDatepicker) {
      startDatepicker.change(function () {
        let startDate = startDatepicker.find('input[type=text]').datepicker('getDate');
        if (startDate) {
          endDatepicker.find('input[type=text]').datepicker('option', 'minDate', startDate);
        }
      });
    }

    if (endDatepicker) {
      endDatepicker.change(function () {
        let endDate = endDatepicker.find('input[type=text]').datepicker('getDate');
        if (endDate) {
          startDatepicker.find('input[type=text]').datepicker('option', 'maxDate', endDate);
        }
      });
    }
  });
}

function setUpPhoneNumberRegex(badPhoneNumberMsg) {

  jq('.phoneRegex').each(function (j, domEl) {

    jq(this).change(function (e) {
      let phone = e.target.value;
      if (phoneNumberRegex(phone)) {
        jq(this).find('span').first().hide();
        jq(this).find('span').first().text('');
      } else {
        jq(this).find('span').first().show();
        jq(this).find('span').first().text(badPhoneNumberMsg);
      }
    })
  })
}

function phoneNumberRegex(phone) {
  return phone.match(phoneNumberPattern().pattern1) || phone.match(phoneNumberPattern().pattern2) || phone.match(phoneNumberPattern().pattern3);
}

function phoneNumberPattern() {
  return {
    pattern1: /^\d{8}$/,
    pattern2: /^\d{4}(?:\)|[-|\s])?\s*?\d{4}$/,
    pattern3: /^\+?(?:\d ?){6,14}\d$/
  }
}

/**
 * This function provides specific client-side functionality for with "checkbox" style obs with an obs date component;
 * It is currently used for the "screening for syphilis", and configured by applying a class "dateDatepickerInTheFuture" to the relevant obs
 *
 * It does two main things:
 *   ** Hide/show the datepicker input based on whether the checkbox is checked
 *   ** Doesn't allow date selected to be ahead of the current date
 *
 * Ideally, 1) The HTML Form Entry module would handle this validation client-side (currently it only handles it
 * server-side) and 2) would not allow the date to after the *encounter date* (not just the current date)
 *
 * We have a ticket for the above work, see: https://issues.openmrs.org/browse/HTML-799 , and if we implement this
 * we could potentially rework this function to just be about hiding/showing the date
 *
 * @param widgetId
 */
function setUpObsWithObsDateTime(widgetId) {
  if (getField(widgetId + '.date') && getField(widgetId + '.value')) {
    getField(widgetId + '.date').hide();
    getField(widgetId + '.date').datepicker('option', 'maxDate', new Date());

    getField(widgetId + '.value').change(function () {
      const isChecked = getValue(widgetId + '.value');
      if (isChecked) {
        getField(widgetId + '.date').show();
      } else {
        setValue(widgetId + '.date', '')
        getField(widgetId + '.date').hide();
      }
    })
  }
}

function setupReturnVisitDateValidation(encounterDate, returnVisitDateLessThanEncounterDateMsg, badReturnVisitDateMsg) {

  const domEl = getField('apptDate.value');
  const yrRange = encounterDate.getFullYear() + ":" + (new Date().getFullYear() + 1);
  domEl.datepicker('option', 'yearRange', yrRange);
  domEl.prop("readonly", "readonly");

  const returnVisitDateValidation = function () {
    const nextVisitDate = domEl.datepicker('getDate');
    if (nextVisitDate) {
      const differnenceInYears = nextVisitDate.getFullYear() - encounterDate.getFullYear();

      if (differnenceInYears < 1 && nextVisitDate > encounterDate) {
        getField('apptDate.error').text('').hide();
        return true;
      }
      else if (differnenceInYears == 1 && nextVisitDate.getMonth() <= encounterDate.getMonth()) {
        getField('apptDate.error').text('').hide();
        return true;
      }
      else if (differnenceInYears <= 0 && encounterDate > nextVisitDate) {
        getField('apptDate.error').text(returnVisitDateLessThanEncounterDateMsg).show();
        return false;
      }
      else {
        getField('apptDate.error').text(badReturnVisitDateMsg).show();
        return false;
      }
    } else {
      return true;
    }
  }

  jq(domEl).change(returnVisitDateValidation);
  beforeSubmit.push(returnVisitDateValidation);



}

function restrictInputOnlyNumber(input_id) {

  // Track the id of the input and change the type to number
  jq(`#${input_id} input`).attr('type', 'number')


}


/**
 * Manages the activation of widget inputs based on the state of a radio button.
 *
 * @param {string|null} checkboxId - The ID of the checkbox associated with the radio button (optional).
 * @param {string} radioButtonId - The ID of the radio button controlling the widget inputs.
 * @param {string[]} widgetIds - The IDs of the widgets whose inputs should be enabled or disabled.
 * @param {string[]} requiredWidgetIds - The IDs of the input widgets that may be required based on the radio button state.
 */
function manageInputActivationForRadioButton(checkboxId = null, radioButtonId, widgetIds, requiredWidgetIds) {

  let isRequired = true;
  let checkboxValue = null;

  setRequiredForTextInputs(requiredWidgetIds)

  const radioButtonValue = jq(radioButtonId).find('input:checked').val();
  // Check if the radio button has a value (i.e., it is checked).
  if (radioButtonValue) {
    setInputWidgetsDisabled(widgetIds, false)
  } else {
    setInputWidgetsDisabled(widgetIds, true)
  }

  //Check if the radio button displays when the checkbox button is checked.
  if (checkboxId) {

    checkboxValue = jq(checkboxId).find('input:checked').val();

    jq(checkboxId).change(function () {
      const elem = jq(this).find('input:checked');
      if (elem.val() == undefined) {
        setInputWidgetsDisabled(widgetIds, true)
        checkboxValue = elem.val();
      } else {
        checkboxValue = elem.val();
        setRequiredForRadioButton(radioButtonId, "true")
      }
    })
  }

  // Enable input when the radio button is checked.
  jq(radioButtonId).change(function () {
    const elem = jq(this).find('input:checked');
    if (elem.val()) {
      setInputWidgetsDisabled(widgetIds, false)
    } else {
      setInputWidgetsDisabled(widgetIds, true)
    }
  })

  // Function to determine if the input widgets specified by requiredWidgetIds are required.
  const returnRequiredInputWidgets = function () {

    // Loop through each input widget of type text under the elements specified by widgetRequiredIds.
    jq(requiredWidgetIds + ' input[type=text]').each(function (i, domEl) {

      const elem = jq(domEl);
      if (checkboxValue == undefined) {
        isRequired = true
      }
      else if (elem.val()) {
        isRequired = true
      } else {
        isRequired = false
      }
    })

    return isRequired;
  }

  // Attach the returnInputWidgetsRequired function as a change event handler to each element specified by requiredWidgetIds
  jq(requiredWidgetIds).each(function (i, domEl) {
    jq(domEl).change(returnRequiredInputWidgets)
  })
  beforeSubmit.push(returnRequiredInputWidgets);
}

/**
 * Disables the input fields of the specified widgets.
 *
 * @param {string[]} widgetIds - The IDs of the widgets whose input fields should be disabled.
 * @param {boolean} disabled - Indicates whether the input fields should be disabled (true) or enabled (false).
 */
function setInputWidgetsDisabled(widgetIds, disabled) {

  if (disabled) {
    jq(widgetIds).each(function (i, domEl) {
      jq(domEl).find('input').first().prop('disabled', disabled);

    })
  } else {
    jq(widgetIds).each(function (i, domEl) {
      jq(domEl).find('input').first().prop('disabled', disabled);
    })
  }
}

// Function to set 'required' attribute for input[type=text] elements under elements specified by requiredWidgetIds.
function setRequiredForTextInputs(requiredWidgetIds) {
  jq(requiredWidgetIds + ' input[type=text]').each(function (i, domEl) {
    if (i >= 0) {
      jq(domEl).prop('required', true);
    }
  })
}


/** Function to set the 'required' attribute for radio buttons under the specified radioButtonId.
* @param {string} radioButtonId - The ID of the radio button element containing the radio buttons to set the 'required' attribute for.
* @param {boolean} value - A boolean value indicating whether to set the 'required' attribute to true or false.
*/
function setRequiredForRadioButton(radioButtonId, value) {
  jq(radioButtonId).find("input[type=radio]").prop('required', value);
}



// Function to check if any checkboxes are selected
function anyCheckboxesSelected(containerSelector) {
  return jq(`${containerSelector} input[type="checkbox"]:checked`).length > 0;
}

/**
 * Updates the required attribute of the last checkbox in the given container.
 * @param {string} containerSelector - The selector for the container containing checkboxes.
 * @returns {boolean} - Returns true if the last checkbox is required, false otherwise.
 */
function updateLastCheckboxRequired(containerSelector) {
  // Initialize the flag to keep track of the last checkbox state.
  let islastCheckbox = true;

  // Function to update the required attribute of the last checkbox
  const updateLastCheckbox = function () {

    // Select the last checkbox within the container using the given selector
    let lastCheckbox = jq(`${containerSelector} input[type="checkbox"]`).last();

    // Check if any checkboxes are selected within the container using the anyCheckboxesSelected function.
    if (!anyCheckboxesSelected(containerSelector)) {
      lastCheckbox.prop('required', true);
      islastCheckbox = false;
    } else {
      lastCheckbox.prop('required', false);
      islastCheckbox = true;
    }
    return islastCheckbox;
  }

  // Initial call to updateLastCheckboxRequired to set the required attribute on page load.
  updateLastCheckbox()

  // Attach event listeners to the checkboxes in the container to update the required attribute dynamically.
  jq(`${containerSelector} input[type="checkbox"]`).change(updateLastCheckbox)
  jq(`${containerSelector} input[type="checkbox"]`).keyup(updateLastCheckbox)

  // Add the updateLastCheckboxRequired function to the beforeSubmit array to call it before form submission.
  beforeSubmit.push(updateLastCheckbox);
}

usePatientAddressAsContactAddress();
saveSelectedLocation();
patientDossierEditAlert();


function usePatientAddressAsContactAddress() {
  jq(document).ready(function () {

    // change the ckeckbox message based on the languade
    var message = '';
    var url = window.location.href;
    var urlParams = new URLSearchParams(new URL(url).search);
    var langParam = urlParams.get('lang');
    message = langParam === 'fr' ? "Utilisez l'adresse du patient ?" : "Use the patient address ?"

    //target the div containing the contact address
    const divElement = jq('#contactQuestionLabel div');

    //creating a check, to be checked if clinician wants to use patient address as contact one
    const checkboxElement = jq("<input>", {
      type: "checkbox",
      id: "question_address",
      name: "question_address"
    });

    //Creating a label to show the checkbox title
    const labelElement = jq("<label>", {
      for: "question_address",
      text: message
    });

    //creating a break line to push other elements a litle bit down
    const brElement = $("<br>");
    divElement.prepend(checkboxElement, labelElement, brElement);

    // checkbox event occurs here
    jq('#question_address').on('change', function () {
      if (this.checked) {
        // get and set the new address detail from patient to contact
        getPatienAddressInfo();

      } else {
        clearInputValue();
      }
    });
  });

}

function getPatienAddressInfo() {

  //creating an array to store patient adress
  var valuesArray = [];
  var manualEntryAddress;
  jq("#personAddressQuestion div input[type='text']").each(function () {
    valuesArray.push(jq(this).val());

  });

  console.table(valuesArray)
  manualEntryAddress = $("#personAddressQuestion div input[type='text']:last").val()
  jq("#contactQuestionLabel div input[type='text']:last").val(manualEntryAddress);

  // target the contact address input and set the new value
  jq("#contactQuestionLabel input[type='text']").each(function (index) {
    if (index < valuesArray.length) {
      jq(this).val(valuesArray[index]);
      jq(this).data('legalValues', [valuesArray[index]])
    }
  });
}

function clearInputValue() {
  jq("#contactQuestionLabel div input[type='text']").each(function () {
    jq(this).val('');
  });

}
//Creating this function to alert the clinician when He/She wants to modify
// Patient info which is not in the same location
function patientDossierEditAlert() {
  jq(document).ready(function () {

    //Track the previously saved loggeInUserLocation/Clinician from the localStorage
    let loggedInUserLocation = localStorage.getItem("location");
    let arraysValue=[]
 
    jq("li.float-left:eq(2)").click(function (e) {
      // Getting the patient location
      jq('fieldset.programstatus-fieldset').each(function () {
       // put all data from the fieldset in a array
        let firstPTag = jq(this).find('p.programstatus-field:nth-child(2):first');
        let locations = firstPTag.text().trim();
        arraysValue.push(locations)
     
    });
    //Remove duplication
    let uniqueArrays = arraysValue.filter((array, index, self) => {
  
      return self.indexOf(array) === index;
    });
      //get the location of the patient
      var patientLocation=uniqueArrays[1];

      if (loggedInUserLocation != patientLocation) {
        
        createOverlayAlert(function (){
          visit.showQuickVisitCreationDialog(0);
        });
        return false;
      } 
    });
  });
}
//Save teh clinician Location in localStorage
function saveSelectedLocation() {
  document.addEventListener("DOMContentLoaded", function () {

    var spanElement = document.getElementById("selected-location");
    var locationText = spanElement.textContent;
    localStorage.setItem("location", locationText);
  });
}
//Creating an overlay Alert 
 function createOverlayAlert(onContinue) {

  let messageEn = "You try to modify a patient who is not in your location";
  let messageF = "Vous essayez de modifier un patient qui n'est pas à votre emplacement.";

  let url = window.location.href;
  let urlParams = new URLSearchParams(new URL(url).search);
  let langParam = urlParams.get('lang');
  let message = langParam === 'fr' ? messageF : messageEn;
  
  
  jq(document).ready(function () {
    // Create overlay div with inline CSS styles
    const overlay = jq('<div class="overlay"></div>').css({
      position: 'fixed', // Use fixed position for better overlay behavior
      top: 0,
      left: 0,
      width: '100%',
      height: '100%',
      backgroundColor: 'rgba(0, 0, 0, 0.5)',
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      zIndex: 2000,
    });

    // Create overlay content with inline CSS styles
    const overlayContent = jq(`<div class="overlay-content">
    <div>${message}</div>
    <div class="actions">
    <button class="cancel-button">Cancel</button>
    <button class="overlay-close-button">Continue</button>
    </div>
    </div>`).css({
      display: 'flex',
      justifyContent: 'space-between',
      flexDirection:'column',
      alignItems: 'center',
      backgroundColor: 'white',
      textAlign:'center',
      fontweight:'bold',
      width: '500px',
      padding: '10px',
      borderRadius: '15px',
      gap:'20px',
      paddingTop:'30px',
      paddingBottom: '2px'
    });

    // Create close button for overlay
   jq('.overlay-close-button').css({
      position: 'absolute',
      bottom: '10px', // Position the button at the bottom
      right: '10px', // Adjust the right position as needed
      border: 'none',
      cursor: 'pointer',
      padding: '5px 5px',
      borderRadius: '5px',
      fontSize:'12px',
      zIndex: 1, // Ensure the close button is above the content
    });
 
  jq('.cancel-button').css({
      position: 'absolute',
      bottom: '10px', // Position the button at the bottom
      right: '10px', // Adjust the right position as needed
      backgroundColor: 'gray',
      border: 'none',
      cursor: 'pointer',
      padding: '5px 5px',
      borderRadius: '5px',
      fontSize:'12px',
      zIndex: 1, // Ensure the close button is above the content
    });
    jq('.actions').css({
      backgroundColor: 'red',
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
    })

    const redLine = jq('<hr class="red-line">').css({
      borderTop: '3px solid #ffc107',
      margin: '20px 5px', // Adjust margin as needed
    });
    // Append overlay content to overlay and overlay to .patient-header
    jq('.patient-header').append(overlay.append(overlayContent.append(redLine)));
    // Close overlay when close button is clicked
    jq('.overlay-close-button').click(function(){
      overlay.remove(); 
      if (typeof onContinue === 'function') {
    
        onContinue();
      }
    })
    
    jq('.cancel-button').click(function(){
      overlay.remove(); 
     jq(".quick-visit-creation-dialog").close();
    })
     
  });


}
