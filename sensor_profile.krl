ruleset sensor_profile {
  meta {
    shares __testing, location, name, temperature_threshold, to_phonenumber, profile
    provides temperature_threshold, to_phonenumber
  }

  global {
    __testing = { "queries": [ { "name": "__testing" },
                              {"name": "location"},
                              {"name": "name"},
                              {"name": "temperature_threshold"},
                              {"name": "to_phonenumber"},
                              {"name": "profile"}],
                "events": [ { "domain": "sensor", "type": "profile_updated",
                            "attrs": [ "location", "name"] },
                            {"domain": "sensor", "type": "temp_update",
                              "attrs": ["tempThreshold"], },
                            {"domain": "sensor", "type": "phone_update",
                              "attrs": ["toPhoneNumber"], },  ] }

    location = function() {
      ent:location
    }
    name = function() {
      ent:name
    }
    temperature_threshold = function() {
      ent:temperature_threshold.defaultsTo(72, "defaulted to 72")
    }
    to_phonenumber = function() {
      ent:to_phonenumber
    }

    profile = function() {
      profile = {"name": ent:name,
                  "location": ent:location,
                  "temperature_threshold": ent:temperature_threshold,
                  "to_phonenumber": ent:to_phonenumber
                };
      profile
    }
  }

  rule profile_update {
    select when sensor profile_updated
    pre {
      location = event:attr("location")
      name = event:attr("name")
      phone = event:attr("toPhoneNumber")
      temperature_thresh = event:attr("tempThreshold")
    }
    send_directive("updating profile")
    always {
      ent:location := location;
      ent:name := name;
      ent:temperature_threshold := temperature_thresh;
      ent:to_phonenumber := phone
    }
  }

  rule profile_temperature_update {
    select when sensor temp_update
    pre {
      temperature_threshold = event:attr("tempThreshold")
    }
    send_directive("updating profile temperature threshold")
    always {
      ent:temperature_threshold := temperature_threshold
    }
  }

  rule profile_phonenumber_update {
    select when sensor phone_update
    pre {
      to_phonenumber = event:attr("toPhoneNumber")
    }
    send_directive("updating profile phone number")
    always {
      ent:to_phonenumber := to_phonenumber;
    }
  }

}
