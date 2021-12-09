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
function setUpDatepickerStartAndEndDateValidation(){

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

function setUpExpandableTransferAndReferralDetails(){
    jq("#transfer-referral-spots").each(function(j, domEl){
        jq("#transfer-referral-out-details").hide()
        let elem=jq(domEl).find('input:checked').val()
        if(elem){
            jq("#transfer-referral-out-details").show()
        }
        jq(this).change(function (e){
            if(e.target.value){
            jq("#transfer-referral-out-details").show()
            }
        })
    });
}

function setUpPhoneNumberRegex(badPhoneNumberMsg) {

    jq('.phoneRegex').each(function (j, domEl) {

        jq(this).change(function (e) {
            let phone = e.target.value;
            if (phone.match(phoneNumberPattern().pattern1) || phone.match(phoneNumberPattern().pattern2)) {
                jq(this).find('span').first().hide();
                jq(this).find('span').first().text('');
                setButtonsDisabled(false);
            } else {
                jq(this).find('span').first().show();
                jq(this).find('span').first().text(badPhoneNumberMsg);
                setButtonsDisabled(true);
            }
        })
    })
}

function phoneNumberPattern(){
    return{
        pattern1:/^\d{8}$/,
        pattern2:/^\d{4}(?:\)|[-|\s])?\s*?\d{4}$/
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
function setUpObsWithObsDateTime(widgetId){
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
