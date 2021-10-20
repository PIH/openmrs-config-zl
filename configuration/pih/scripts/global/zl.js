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

function setUpDatepickerStartAndEndDateValidation(badDateInTheFutureMsg,badStartDateGreaterThanEndDateMsg){

    jq(".startDateEndDate").each(function(j, domEl){
        setUpDatepickers(this);
    });

    function setUpDatepickers(containerNode) {
        const startDatepicker = jq(jq(containerNode).find('.startDate'));
        const endDatepicker = jq(jq(containerNode).find('.endDate'));

        startDatepicker.change(function (e) {
          let startDate = Date.parse(e.target.value);
          let endDate = Date.parse(endDatepicker.find('input[type=text]').val());

          if (startDate > Date.now()) {
              jq(this).find('span').show();
              jq(this).find('span').text(badDateInTheFutureMsg);
              setButtonsDisabled(true)
          } else {
              jq(this).find('span').hide();
              jq(this).find('span').text('');
              setButtonsDisabled(false)
          }

          if (endDate > Date.now()) {
              endDatepicker.find('span').show();
              endDatepicker.find('span').text(badDateInTheFutureMsg);
              setButtonsDisabled(true)
          }
          if (startDate > endDate) {
              endDatepicker.find('span').show();
              endDatepicker.find('span').text(badStartDateGreaterThanEndDateMsg);
              setButtonsDisabled(true)
          }
          if (startDate < endDate && endDate < Date.now()) {
              endDatepicker.find('span').hide();
              endDatepicker.find('span').text('');
              setButtonsDisabled(false)
          }
        });

        endDatepicker.change(function (e) {
            let endDate = Date.parse(e.target.value);
            let startDate = Date.parse(startDatepicker.find('input[type=text]').val());

            if (endDate > Date.now()) {
                jq(this).find('span').show();
                jq(this).find('span').text(badDateInTheFutureMsg);
                setButtonsDisabled(true)
            }
            if (startDate > endDate) {
                jq(this).find('span').show();
                jq(this).find('span').text(badStartDateGreaterThanEndDateMsg);
                setButtonsDisabled(true)
            }
            if (startDate < endDate && endDate < Date.now()){
                jq(this).find('span').hide();
                jq(this).find('span').text('');
                setButtonsDisabled(false)
            }
        });
    }

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

function setButtonsDisabled(val){
    jq("#next").prop("disabled", val);
    jq("#submit,.confirm").prop("disabled", val);
}

function setUpDatepickerInTheFutureValidation(badDateInTheFutureMsg){

    jq('.dateDatepickerInTheFuture').each(function(j, domEl){
        jq(this).find('input[type=text]').hide();
        jq(this).change(function (e) {
            const  date=Date.parse(jq(this).find('input[type=text]').val())
            const  isCheched=Date.parse(jq(this).find('input:checked').val())
            if(isCheched) {
                if (date > Date.now()) {
                    jq(this).find('span').show();
                    jq(this).find('span').text(badDateInTheFutureMsg);
                    setButtonsDisabled(true)
                } else {
                    jq(this).find('span').hide();
                    jq(this).find('span').text('');
                    setButtonsDisabled(false)
                }
                jq(this).find('input[type=text]').show();
            }else {
                jq(this).find('input[type=text]').prop('value', '')
                jq(this).find('span').text('');
                jq(this).find('input[type=text]').hide();
                setButtonsDisabled(false)
            }
        })
    });

}
