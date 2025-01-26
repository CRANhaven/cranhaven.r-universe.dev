#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod); // specified in get_mod.cpp

[[cpp11::register]]
strings get_ctls_(SEXP mod) {
  module * my_mod = get_mod(mod);
  std::vector< std::string > temp = my_mod->get_ctls();
  writable::strings result((R_xlen_t)temp.size());
  for (int i = 0; i < (int)temp.size(); i++) {
    result.at(i) = r_string(temp.at(i));
  }
  return(result);
}

[[cpp11::register]]
SEXP ctl_get_(SEXP mod, std::string ctl) {
  module * my_mod = get_mod(mod);
  try {
    return as_sexp(my_mod->ctl_get_boolean(ctl));
  } catch (...) {
    try {
      return as_sexp(my_mod->ctl_get_integer(ctl));
    } catch (...) {
      try {
        return as_sexp(my_mod->ctl_get_floatingpoint(ctl));
      } catch (...) {
        try {
          return as_sexp(my_mod->ctl_get_text(ctl));
        } catch (...) {
          cpp11::stop("Failed to retrieve control key");
        }
      }
    }
  }
  return R_NilValue;
}

[[cpp11::register]]
SEXP ctl_set_(SEXP mod, std::string ctl, SEXP value) {
  if (Rf_length(value) != 1)
    cpp11::stop("Replacement should have length 1");
  SEXP required = ctl_get_(mod, ctl);
  if (TYPEOF(required) != TYPEOF(value))
    cpp11::stop("Incorrect replacement type. Expected '%s', but got '%s'",
             Rf_type2char(TYPEOF(required)), Rf_type2char(TYPEOF(value)));
  module * my_mod = get_mod(mod);
  bool success = true;
  switch(TYPEOF(value)) {
  case LGLSXP:
  {
    logicals replacement_b = as_cpp<logicals>(value);
    if (replacement_b.at(0) == NA_LOGICAL) {
      success = false;
      break;
    }
    try {
      my_mod->ctl_set_boolean(ctl, (bool)(replacement_b.at(0)));
    } catch(...) {
      success = false;
    }
    break;
  }
  case INTSXP:
  {
    integers replacement_i = as_cpp<integers>(value);
    if (replacement_i.at(0) == NA_INTEGER) {
      success = false;
      break;
    }
    try {
      my_mod->ctl_set_integer(ctl, replacement_i.at(0));
    } catch(...) {
      success = false;
    }
    break;
  }
  case REALSXP:
  {
    doubles replacement_f = as_cpp<doubles>(value);
    if (ISNA(replacement_f.at(0))) {
      success = false;
      break;
    }
    try {
      my_mod->ctl_set_floatingpoint(ctl, replacement_f.at(0));
    } catch(...) {
      success = false;
    }
    break;
  }
  case STRSXP:
  {
    strings replacement_t = as_cpp<strings>(value);
    if (replacement_t.at(0) == NA_STRING) {
      success = false;
      break;
    }
    try {
      my_mod->ctl_set_text(ctl, (std::string)(replacement_t.at(0)));
    } catch(...) {
      success = false;
    }
    break;
  }
  default:
    break;
  }
  if (!success)
    cpp11::stop("Failed to assign control value");
  return mod;
}
