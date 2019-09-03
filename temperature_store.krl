ruleset temperature_store{
  meta {
    use module sensor_profile
    shares __testing, pragma, temperatures, threshold_violations, inrange_temperatures, current_temperature
    provides pragma
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                                {"name": "temperatures"},
                                {"name": "threshold_violations"},
                                {"name": "inrange_temperatures"}],
                  "events": [ { "domain": "wovyn", "type": "new_temperature_reading",
                              "attrs": [ "temperature", "timestamp" ] },
                              {"domain": "sensor", "type": "reading_reset"} ] }

    clear_temperatures = []

    clear_threshold_violations = []

    temperatures = function() {
      ent:temperatures
    }

    threshold_violations = function() {
      //ent:threshold_violations
      ent:temperatures.filter(function(x){x{"temperature"} > sensor_profile:temperature_threshold()});
    }

    inrange_temperatures = function() {
      ent:temperatures.filter(function(x){x{"temperature"} < sensor_profile:temperature_threshold()});
    }

    current_temperature = function() {
      ent:temperatures[ent:temperatures.length() - 1]
    }
  }

  rule collect_temperatures {
    select when wovyn new_temperature_reading
    pre {
      temperature = event:attr("temperature")
      timestamp = event:attr("timestamp")
    }
    send_directive("New Temperature Reading - ent")
    always {
      ent:temperatures := ent:temperatures.append({"temperature": temperature, "timestamp": timestamp})
    }
  }

  rule collect_threshold_violations {
    select when wovyn threshold_violation
    pre {
      temperature = event:attr("temperature")
      timestamp = event:attr("timestamp")
    }
    send_directive("Threshold Violation - ent")
    always {
      ent:threshold_violations := ent:threshold_violations.append({"temperature": temperature, "timestamp": timestamp})
    }
  }

  rule clear_temperatures {
    select when sensor reading_reset
    always {
      ent:temperatures := clear_temperatures;
      ent:threshold_violations := clear_threshold_violations;
    }
  }


}
