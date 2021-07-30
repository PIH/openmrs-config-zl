function setUpEdd(currentEncounterDate, msgWeeks) {
  var updateEdd = function () {
    var lastPeriodDate = htmlForm.getValueIfLegal("lastPeriodDate.value");
    if (
      typeof lastPeriodDate !== "undefined" &&
      lastPeriodDate !== null &&
      lastPeriodDate.length > 0
    ) {
      var today = new Date();
      if (
        typeof currentEncounterDate !== "undefined" &&
        currentEncounterDate !== null &&
        currentEncounterDate.length > 0
      ) {
        // calculate the gestational age at the time of the encounter
        today = new Date(+currentEncounterDate);
      }

      var dateObj = getField("lastPeriodDate.value").datepicker("getDate");
      var newDate = new Date(dateObj);
      // time difference
      var timeDiff = Math.abs(today.getTime() - newDate.getTime());
      // weeks difference = gestational age
      var diffWeeks = Math.ceil(timeDiff / (1000 * 3600 * 24 * 7));

      // Estimated Delivery Date = (LMP - 3 months) + 12 months + 7 days
      newDate.setMonth(newDate.getMonth() - 3);
      newDate.setFullYear(newDate.getFullYear() + 1);
      newDate.setDate(newDate.getDate() + 7);

      var widgetDate = getField("lastPeriodDate.value")
        .datepicker("setDate", newDate)
        .val();
      getField("lastPeriodDate.value").datepicker("setDate", dateObj);

      jq("#calculated-edd-and-gestational").show();
      jq("#calculated-edd").text(widgetDate);
      jq("#calculated-gestational-age-value").text(diffWeeks + " " + msgWeeks);
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

function setUpExpandableContacts() {
  var x = 1;
  var elem = document.getElementsByClassName("contacts");
  var contactSize = elem.length;

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

  jq("#contact-" + x).show();
  hideOtherContacts();
  jq("#show-less-contacts-button").hide();

  jq("#show-more-contacts-button").click(function () {
    if (contactSize > x) {
      x++;
      jq("#contact-" + x).show();
      if (x > 1) {
        jq("#show-less-contacts-button").show();
      }
      if (x == 10) {
        jq("#show-more-contacts-button").hide();
      }
    }
  });

  jq("#show-less-contacts-button").click(function () {
    if (contactSize > x || x == 10) {
      if (x > 1) {
        jq("#contact-" + x).hide();
        x--;
        if (x == 1) {
          jq("#show-less-contacts-button").hide();
        }
      }
      jq("#show-more-contacts-button").show();
    }
  });

  // Phone Number Regex functionality
  for (let i = 0; contactSize > i; i++) {
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
      jq("#contact-phone-error-message-" + index).text(
        '<uimessage code="pihcore.invalid.phoneNumber"/>'
      );
      jq("#next").prop("disabled", true);
      jq("#submit").prop("disabled", true);
    }
  }
}
