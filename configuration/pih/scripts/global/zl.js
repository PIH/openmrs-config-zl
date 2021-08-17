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

        // get Contact values
        let contactValue = {}
        jq(`#contact-${i} input, #contact-${i} select, #contact-${i} textarea, #contact-${i} radio`).each(function (i, obj) {
            if (jq(obj).val().indexOf(5) && jq(obj).val().indexOf(448)) {
                contactValue[obj.name] = jq(obj).val();
            } else {
                delete contactValue[obj.name]
            }
        })

        //showing contact if exist data
        if (ifContactWithData(contactValue)) {
            jq(`#contact-${i}`).show();
            contactsToShow++;
        }

        // Phone Number Regex functionality
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

    function ifContactWithData(obj) {
        for (let key in obj) {
            if (obj[key] !== null && obj[key] != "")
                return true;
        }
        return false;
    }

}
