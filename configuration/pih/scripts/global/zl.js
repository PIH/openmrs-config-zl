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

function datepickerAsyncValidation(badDateInTheFutureMsg,badStartDateGreaterThanEndDateMsg){

  $("#startDate-0,#startDate-1").each(function(j, domEl){
    $(this).change(function (e){
      let startDate = Date.parse(e.target.value);
      let endDate = Date.parse(jq(`#endDate-${j} input[type=text]`).val());

        if (startDate > Date.now()){
          jq(`#${domEl.getAttribute('id')} span`).show();
          jq(`#${domEl.getAttribute('id')} span`).text(badDateInTheFutureMsg);
          buttonsDisabled(true)
        }else {
          jq(`#${domEl.getAttribute('id')} span`).hide();
          jq(`#${domEl.getAttribute('id')} span`).text('');
          buttonsDisabled(false)
        }
         if(startDate>endDate){
          jq(`#endDate-${j} span`).show();
          jq(`#endDate-${j} span`).text(badStartDateGreaterThanEndDateMsg);
          buttonsDisabled(true)
        }else{
          jq(`#endDate-${j} span`).hide();
          jq(`#endDate-${j} span`).text('');
          buttonsDisabled(false)
        }
    });
  });


  $("#endDate-0,#endDate-1").each(function(j, domEl){
    $(this).change(function (e){
      let endDate = Date.parse(e.target.value);
      let startDate = Date.parse(jq(`#startDate-${j} input[type=text]`).val());

      if (endDate > Date.now()) {
        jq(`#${domEl.getAttribute('id')} span`).show();
        jq(`#${domEl.getAttribute('id')} span`).text(badDateInTheFutureMsg);
        buttonsDisabled(true)
      }else if (startDate > endDate){
        jq(`#${domEl.getAttribute('id')} span`).show();
        jq(`#${domEl.getAttribute('id')} span`).text(badStartDateGreaterThanEndDateMsg);
        buttonsDisabled(true)
      }else {
        jq(`#${domEl.getAttribute('id')} span`).hide();
        jq(`#${domEl.getAttribute('id')} span`).text('');
        buttonsDisabled(false)
      }

    });
  });


  function buttonsDisabled(val){
    jq("#next").prop("disabled", val);
    jq("#submit").prop("disabled", val);
  }

}

