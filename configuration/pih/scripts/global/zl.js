function setUpEdd(currentEncounterDate, msgWeeks) {
  function updateEdd() {
    const lastPeriodDateValue = htmlForm.getValueIfLegal("lastPeriodDate.value");
    if (lastPeriodDateValue) {
      const lastPeriodDate = new Date(lastPeriodDateValue);
      const today = currentEncounterDate ? new Date(+currentEncounterDate) : new Date();
      const gestAgeMs = today.getTime() - lastPeriodDate.getTime();
      const gestAgeDays = Math.floor(gestAgeMs / (1000 * 3600 * 24))
      const gestAgeWeeks = Math.floor(gestAgeDays / 7);
      const gestAgeRemainderDays = gestAgeDays % 7;
      const locale = window.sessionContext.locale || navigator.language;
      const edd = new Date(lastPeriodDate.getTime() + 1000 * 60 * 60 * 24 * 280);
      jq("#calculated-edd-and-gestational").show();
      getField("edd.value").datepicker("setDate", edd);
      jq("#calculated-edd").text((Intl.DateTimeFormat(locale, { dateStyle: "full" })).format(edd));
      const gestAgeText = gestAgeWeeks + " " +
        (gestAgeRemainderDays ? gestAgeRemainderDays + "/7 " : " ") +
        msgWeeks;
      jq("#calculated-gestational-age-value").text(gestAgeText);
    } else {
      jq("#calculated-edd-and-gestational").hide();
    }
  };

  jq("#calculated-edd-and-gestational").hide();
  jq("#lastPeriodDate input[type='hidden']").change(function () {
    updateEdd();
  });

  updateEdd();
}

function setUpNextButtonForSections() {
  // handle our custom functionality for triggering going to the next section when the "Next" button is clicked
  jq("#next").click(function () {
    window.htmlForm.getBeforeSubmit().push(function () {
      window.htmlForm.setReturnUrl(
        window.htmlForm.getReturnUrl() + "&amp;goToNextSection=pmtct-history"
      );
      return true;
    });

    window.htmlForm.submitHtmlForm();
  });

  jq("#submit").click(function () {
    window.htmlForm.submitHtmlForm();
  });
}

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

  // Phone Number Regex functionality
  for (let i = 0; maxContacts > i; i++) {
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
